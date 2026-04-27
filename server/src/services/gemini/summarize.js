const { GoogleGenerativeAI } = require('@google/generative-ai');

const { env } = require('../../config/env');

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function parseRetryDelayMs(message) {
  if (!message) return null;
  const match = String(message).match(/Please retry in\s+([0-9.]+)s/i);
  if (!match) return null;
  const seconds = Number.parseFloat(match[1]);
  if (Number.isNaN(seconds) || seconds <= 0) return null;
  return Math.ceil(seconds * 1000);
}

function isRateLimitOrQuotaError(err) {
  const msg = String(err?.message || '').toLowerCase();
  return msg.includes('429') || msg.includes('too many requests') || msg.includes('quota');
}

function isTransientGeminiError(err) {
  const msg = String(err?.message || '').toLowerCase();
  return (
    isRateLimitOrQuotaError(err) ||
    msg.includes('503') ||
    msg.includes('service unavailable') ||
    msg.includes('overloaded') ||
    msg.includes('fetch failed') ||
    msg.includes('econnreset') ||
    msg.includes('etimedout')
  );
}

function buildPrompt({ author, title, url, text }) {
  const clipped = text.length > 15000 ? text.slice(0, 15000) : text;
  return [
    'You are an expert news summarizer.',
    'Return ONLY valid JSON. Do not wrap in markdown. Do not include backticks.',
    'Output schema:',
    '{',
    '  "author": string|null,',
    '  "title": string,',
    '  "url": string,',
    '  "points": [',
    '    { "heading": string, "bullets"?: string[], "paragraph"?: string }',
    '  ],',
    '  "categories": string[]',
    '}',
    'Rules:',
    '- points MUST contain exactly 10 items.',
    '- Each point must have a short heading and either (a) 2-5 bullets OR (b) one concise paragraph.',
    '- Bullets must be factual, concise, and derived from the article text.',
    '- No speculation, no ads, no CTAs.',
    '- Assign one or more categories from the following list that best fit the article:',
    '- Only use categories from this list. If none fit, use "Miscellaneous".',
    '- Category list:',
    'Science & Technology: Acoustics, Aerospace Engineering, Agronomy, Artificial Intelligence, Astronomy, Astrophysics, Automation, Bioinformatics, Biotechnology, Blockchain, Botany, Chemical Engineering, Civil Engineering, Cloud Computing, Computer Vision, Consumer Electronics, Cryptography, Cybersecurity, Data Science, Ecology, Electrical Engineering, Entomology, Epidemiology, Evolutionary Biology, Forensic Science, Game Development, Genetics, Geology, Hacking, Hydrology, Immunology, Information Technology, Internet of Things (IoT), Machine Learning, Marine Biology, Materials Science, Mechanical Engineering, Meteorology, Microbiology, Nanotechnology, Neuroscience, Nuclear Physics, Oceanography, Optics, Organic Chemistry, Paleontology, Particle Physics, Pharmacology, Quantum Mechanics, Robotics, Software Engineering, Space Exploration, Sustainability, Telecommunications, Thermodynamics, Toxicology, Virtual Reality (VR), Web Development, Zoology',
    'Humanities & Social Sciences: Anthropology, Archaeology, Cognitive Science, Criminology, Demography, Developmental Psychology, Epistemology, Ethics, Ethnography, Gender Studies, Genealogy, Geography, Geopolitics, History (Ancient, Medieval, Modern), Human Rights, International Relations, Law (Constitutional, Corporate, Criminal), Linguistics, Logic, Media Studies, Metaphysics, Military History, Mythology, Pedagogy, Philosophy, Political Science, Psychology (Clinical, Social, Behavioral), Public Administration, Religious Studies, Social Work, Sociology, Theology, Urban Planning',
    'Business & Economics: Accounting, Advertising, Behavioral Economics, Branding, Business Ethics, Corporate Governance, Cryptocurrency, Digital Marketing, E-commerce, Entrepreneurship, Finance (Personal, Corporate), Human Resources, Industrial Relations, Insurance, International Trade, Investing, Logistics, Macroeconomics, Management, Microeconomics, Operations Management, Project Management, Real Estate, Sales, Stock Market, Supply Chain Management, Taxation, Venture Capital',
    'Arts, Culture & Media: Animation, Architecture, Art History, Calligraphy, Cinematography, Creative Writing, Culinary Arts, Dance, Design (Graphic, Industrial, Interior), Fashion, Film Studies, Fine Arts, Journalism, Literature, Music Theory, Performing Arts, Photography, Poetry, Pop Culture, Publishing, Sculpture, Stand-up Comedy, Television, Textile Design, Theater, Video Games, Visual Arts',
    'Health, Lifestyle & Sports: Alternative Medicine, Athletic Training, Biohacking, Dental Hygiene, Dermatology, Dietetics, Emergency Medicine, Ergonomics, Fitness, Gastronomy, Geriatrics, Holistic Health, Kinesiology, Meditation, Mental Health, Minimalism, Nursing, Nutrition, Occupational Therapy, Parenting, Pediatrics, Personal Development, Physical Therapy, Productivity, Psychiatry, Public Health, Sports Management, Sports Psychology, Sports Science, Survivalism, Travel & Tourism, Veterinary Medicine, Wellness, Yoga',
    'Niche & Miscellaneous: Astrology, Aviation, Bibliophilia, Carpentry, Chess, Collecting (Philately, Numismatics), Conspiracy Theories, Cryptozoology, DIY & Making, Esotericism, Etiquette, Futurism, Gardening, Genealogy, Horticulture, Magic (Illusion), Maritime Studies, Military Strategy, Numismatics, Occultism, Parapsychology, Philanthropy, Survival Skills, Transhumanism, True Crime, Vexillology (Flags)',
    '',
    `Author: ${author || ''}`,
    `Title: ${title || ''}`,
    `URL: ${url}`,
    'Article text:',
  ].join('\n');
}

function safeJsonParse(text) {
  try {
    return JSON.parse(text);
  } catch {
    // Try to salvage JSON object from surrounding text
    const start = text.indexOf('{');
    const end = text.lastIndexOf('}');
    if (start === -1 || end === -1 || end <= start) return null;
    const slice = text.slice(start, end + 1);
    try {
      return JSON.parse(slice);
    } catch {
      return null;
    }
  }
}

function validateSummaryJson(json) {
  if (!json || typeof json !== 'object') return null;
  if (!json.title || !json.url || !Array.isArray(json.points)) return null;
  if (json.points.length !== 10) return null;
  for (const p of json.points) {
    if (!p || typeof p.heading !== 'string') return null;
    const hasBullets = Array.isArray(p.bullets) && p.bullets.length > 0;
    const hasParagraph = typeof p.paragraph === 'string' && p.paragraph.trim().length > 0;
    if (!hasBullets && !hasParagraph) return null;
  }
  return json;
}

async function generateOnce({ modelName, prompt }) {
  const genAI = new GoogleGenerativeAI(env.GEMINI_API_KEY);
  const model = genAI.getGenerativeModel({ model: modelName });
  const result = await model.generateContent(prompt);
  return result.response.text();
}

async function summarizeWithGemini({ author, title, url, text }) {
  const prompt = buildPrompt({ author, title, url, text });

  // NOTE: Railway env vars are easy to misconfigure. If a model name is invalid/unsupported
  // (404 / not supported for generateContent), we'll fall through to the next candidate.
  const builtinFallbackModels = [
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  const modelCandidates = Array.from(
    new Set([env.GEMINI_MODEL, env.GEMINI_FALLBACK_MODEL, ...builtinFallbackModels].filter(Boolean))
  );

  let lastErr;

  for (const modelName of modelCandidates) {
    for (let attempt = 0; attempt <= env.GEMINI_MAX_RETRIES; attempt += 1) {
      try {
        const outputText = await generateOnce({ modelName, prompt });

        const parsed = validateSummaryJson(safeJsonParse(outputText));
        if (!parsed) {
          const err = new Error('Gemini did not return valid summary JSON');
          err.details = { outputText: outputText.slice(0, 2000), modelName };
          throw err;
        }

        parsed._model = modelName;
        return parsed;
      } catch (err) {
        lastErr = err;

        if (!isTransientGeminiError(err)) break;

        const waitMs =
          parseRetryDelayMs(err.message) || Math.min(30000, 2000 * 2 ** Math.max(0, attempt));
        await sleep(waitMs);
      }
    }
  }

  throw lastErr || new Error('Gemini request failed');
}

/**
 * Batch summarize multiple articles at once.
 * @param {Array<{author, title, url, text}>} articles
 * @returns {Promise<Array>} Array of summary objects (same order)
 */
async function summarizeBatchWithGemini(articles) {
  if (!Array.isArray(articles) || articles.length === 0) return [];
  // Build a batch prompt
  const batchPrompt = [
    'You are an expert news summarizer.',
    'Return ONLY valid JSON. Do not wrap in markdown. Do not include backticks.',
    'Output schema:',
    '[',
    '  {',
    '    "author": string|null,',
    '    "title": string,',
    '    "url": string,',
    '    "points": [',
    '      { "heading": string, "bullets"?: string[], "paragraph"?: string }',
    '    ],',
    '    "categories": string[]',
    '  }',
    ']',
    'Rules:',
    '- For each article, output an object matching the schema above.',
    '- Each object must have exactly 10 points.',
    '- Assign one or more categories from the provided list for each article.',
    '- Only use categories from this list. If none fit, use "Miscellaneous".',
    '- Category list:',
    'Science & Technology: Acoustics, Aerospace Engineering, Agronomy, Artificial Intelligence, Astronomy, Astrophysics, Automation, Bioinformatics, Biotechnology, Blockchain, Botany, Chemical Engineering, Civil Engineering, Cloud Computing, Computer Vision, Consumer Electronics, Cryptography, Cybersecurity, Data Science, Ecology, Electrical Engineering, Entomology, Epidemiology, Evolutionary Biology, Forensic Science, Game Development, Genetics, Geology, Hacking, Hydrology, Immunology, Information Technology, Internet of Things (IoT), Machine Learning, Marine Biology, Materials Science, Mechanical Engineering, Meteorology, Microbiology, Nanotechnology, Neuroscience, Nuclear Physics, Oceanography, Optics, Organic Chemistry, Paleontology, Particle Physics, Pharmacology, Quantum Mechanics, Robotics, Software Engineering, Space Exploration, Sustainability, Telecommunications, Thermodynamics, Toxicology, Virtual Reality (VR), Web Development, Zoology',
    'Humanities & Social Sciences: Anthropology, Archaeology, Cognitive Science, Criminology, Demography, Developmental Psychology, Epistemology, Ethics, Ethnography, Gender Studies, Genealogy, Geography, Geopolitics, History (Ancient, Medieval, Modern), Human Rights, International Relations, Law (Constitutional, Corporate, Criminal), Linguistics, Logic, Media Studies, Metaphysics, Military History, Mythology, Pedagogy, Philosophy, Political Science, Psychology (Clinical, Social, Behavioral), Public Administration, Religious Studies, Social Work, Sociology, Theology, Urban Planning',
    'Business & Economics: Accounting, Advertising, Behavioral Economics, Branding, Business Ethics, Corporate Governance, Cryptocurrency, Digital Marketing, E-commerce, Entrepreneurship, Finance (Personal, Corporate), Human Resources, Industrial Relations, Insurance, International Trade, Investing, Logistics, Macroeconomics, Management, Microeconomics, Operations Management, Project Management, Real Estate, Sales, Stock Market, Supply Chain Management, Taxation, Venture Capital',
    'Arts, Culture & Media: Animation, Architecture, Art History, Calligraphy, Cinematography, Creative Writing, Culinary Arts, Dance, Design (Graphic, Industrial, Interior), Fashion, Film Studies, Fine Arts, Journalism, Literature, Music Theory, Performing Arts, Photography, Poetry, Pop Culture, Publishing, Sculpture, Stand-up Comedy, Television, Textile Design, Theater, Video Games, Visual Arts',
    'Health, Lifestyle & Sports: Alternative Medicine, Athletic Training, Biohacking, Dental Hygiene, Dermatology, Dietetics, Emergency Medicine, Ergonomics, Fitness, Gastronomy, Geriatrics, Holistic Health, Kinesiology, Meditation, Mental Health, Minimalism, Nursing, Nutrition, Occupational Therapy, Parenting, Pediatrics, Personal Development, Physical Therapy, Productivity, Psychiatry, Public Health, Sports Management, Sports Psychology, Sports Science, Survivalism, Travel & Tourism, Veterinary Medicine, Wellness, Yoga',
    'Niche & Miscellaneous: Astrology, Aviation, Bibliophilia, Carpentry, Chess, Collecting (Philately, Numismatics), Conspiracy Theories, Cryptozoology, DIY & Making, Esotericism, Etiquette, Futurism, Gardening, Genealogy, Horticulture, Magic (Illusion), Maritime Studies, Military Strategy, Numismatics, Occultism, Parapsychology, Philanthropy, Survival Skills, Transhumanism, True Crime, Vexillology (Flags)',
    '',
    'Articles:',
    ...articles.map((a, i) => [
      `Article #${i + 1}:`,
      `Author: ${a.author || ''}`,
      `Title: ${a.title || ''}`,
      `URL: ${a.url}`,
      `Text: ${(a.text && a.text.length > 15000) ? a.text.slice(0, 15000) : a.text}`,
      ''
    ].join('\n')),
  ].join('\n');

  const genAI = new GoogleGenerativeAI(env.GEMINI_API_KEY);
  const modelCandidates = [env.GEMINI_MODEL, env.GEMINI_FALLBACK_MODEL, 'gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-1.5-flash', 'gemini-1.5-pro'].filter(Boolean);
  let lastErr;
  for (const modelName of modelCandidates) {
    for (let attempt = 0; attempt <= env.GEMINI_MAX_RETRIES; attempt += 1) {
      try {
        const model = genAI.getGenerativeModel({ model: modelName });
        const result = await model.generateContent(batchPrompt);
        const text = result.response.text();
        let parsed;
        try {
          parsed = JSON.parse(text);
        } catch {
          // Try to salvage JSON array
          const start = text.indexOf('[');
          const end = text.lastIndexOf(']');
          if (start !== -1 && end !== -1 && end > start) {
            try {
              parsed = JSON.parse(text.slice(start, end + 1));
            } catch {}
          }
        }
        if (!Array.isArray(parsed) || parsed.length !== articles.length) {
          const err = new Error('Gemini did not return valid batch summary JSON');
          err.details = { outputText: text.slice(0, 2000), modelName };
          throw err;
        }
        parsed.forEach((item, idx) => { item._model = modelName; });
        return parsed;
      } catch (err) {
        lastErr = err;
        if (!isTransientGeminiError(err)) break;
        const waitMs = parseRetryDelayMs(err.message) || Math.min(30000, 2000 * 2 ** Math.max(0, attempt));
        await sleep(waitMs);
      }
    }
  }
  throw lastErr || new Error('Gemini batch request failed');
}

module.exports = { summarizeWithGemini, summarizeBatchWithGemini };
