const axios = require('axios');
const { JSDOM, VirtualConsole } = require('jsdom');
const { Readability } = require('@mozilla/readability');

const { env } = require('../../config/env');

function stripStyles(html) {
  if (!html) return html;
  // JSDOM's CSS parser can choke on modern CSS (e.g. :has()) and will spew huge logs.
  // Styles are not needed for Readability() extraction, so remove them.
  return String(html)
    .replace(/<style[\s\S]*?<\/style>/gi, '')
    .replace(/<link\b[^>]*rel=["']?stylesheet["']?[^>]*>/gi, '');
}

function createDom(html, url) {
  const virtualConsole = new VirtualConsole();
  // Swallow noisy jsdom errors (e.g. CSS parse failures). We handle extraction failure separately.
  virtualConsole.on('jsdomError', () => {});

  return new JSDOM(stripStyles(html), {
    url,
    virtualConsole,
  });
}

function normalizeMaybeUrl(raw, baseUrl) {
  if (!raw) return undefined;
  const s = String(raw).trim();
  if (!s) return undefined;
  try {
    return new URL(s, baseUrl).toString();
  } catch {
    return undefined;
  }
}

function pickFromSrcset(srcset) {
  if (!srcset) return undefined;
  const first = String(srcset)
    .split(',')
    .map((part) => part.trim())
    .filter(Boolean)[0];
  if (!first) return undefined;
  return first.split(/\s+/)[0];
}

function extractMetaImageUrl(document, baseUrl) {
  const selectors = [
    'meta[property="og:image"]',
    'meta[property="og:image:url"]',
    'meta[name="twitter:image"]',
    'meta[name="twitter:image:src"]',
    'link[rel="image_src"]',
  ];

  for (const sel of selectors) {
    const el = document.querySelector(sel);
    if (!el) continue;
    const raw = el.getAttribute('content') || el.getAttribute('href');
    const u = normalizeMaybeUrl(raw, baseUrl);
    if (u) return u;
  }
  return undefined;
}

function extractContentImageUrl(articleContentHtml, baseUrl) {
  if (!articleContentHtml) return undefined;
  try {
    const dom = createDom(articleContentHtml, baseUrl);
    const doc = dom.window.document;
    const img = doc.querySelector('img');
    if (!img) return undefined;

    const fromSrcset = pickFromSrcset(img.getAttribute('srcset'));
    const src = fromSrcset || img.getAttribute('src');
    return normalizeMaybeUrl(src, baseUrl);
  } catch {
    return undefined;
  }
}

async function fetchHtml(url) {
  const response = await axios.get(url, {
    timeout: env.HTTP_TIMEOUT_MS,
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; BackEndExpress-RSS-Summarizer/1.0)',
      Accept: 'text/html,application/xhtml+xml',
    },
    maxRedirects: 5,
  });

  return response.data;
}

function extractReadableText(html, url) {
  const dom = createDom(html, url);
  const document = dom.window.document;
  const reader = new Readability(document);
  const article = reader.parse();
  if (!article || !article.textContent) return null;

  const text = article.textContent.replace(/\s+/g, ' ').trim();
  if (!text) return null;

  const imageUrl =
    extractMetaImageUrl(document, url) || extractContentImageUrl(article.content, url);

  return {
    title: article.title,
    excerpt: article.excerpt,
    text,
    imageUrl,
  };
}

async function extractArticle(url) {
  const html = await fetchHtml(url);
  const readable = extractReadableText(html, url);
  return readable;
}

module.exports = { extractArticle };
