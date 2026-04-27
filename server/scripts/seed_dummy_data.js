require('dotenv').config({ path: require('path').resolve(__dirname, '../src/.env') });
const mongoose = require('mongoose');
const crypto = require('crypto');
const ArticleSummary = require('../src/models/ArticleSummary');

async function main() {
  if (!process.env.MONGODB_URI) {
    throw new Error('Missing MONGODB_URI in environment variables');
  }

  await mongoose.connect(process.env.MONGODB_URI);
  console.log('Connected to MongoDB');

  const dummyData = Array.from({ length: 5 }).map((_, i) => {
    const url = `https://example.com/dummy-article-${Date.now()}-${i}`;
    const urlHash = crypto.createHash('sha256').update(url).digest('hex');

    return {
      title: `Dummy Article ${i + 1}: The Future of AI`,
      author: 'John Doe',
      url: url,
      feed: {
        feedUrl: 'https://example.com/rss',
        title: 'Example Tech Blog',
      },
      source: {
        domain: 'example.com',
      },
      publishedAt: new Date(Date.now() - i * 86400000), // i days ago
      content: {
        excerpt: 'This is a short excerpt for the dummy article. It provides a brief overview of what the article is about.',
        wordCount: 1500,
        imageUrl: `https://picsum.photos/seed/${Date.now()}${i}/800/600`,
      },
      status: 'summarized',
      summary: {
        version: 1,
        points: [
          {
            heading: 'Introduction to AI Advancements',
            bullets: [
              'AI models have grown significantly in size.',
              'New architectures are being explored.',
            ],
            paragraph: 'The field of Artificial Intelligence has seen tremendous growth over the past few years, with new models breaking records in various benchmarks.',
          },
          {
            heading: 'Impact on Industry',
            bullets: [
              'Automation of repetitive tasks.',
              'Enhanced decision-making capabilities.',
              'Creation of new job roles.',
            ],
          },
          {
            heading: 'Future Prospects',
            paragraph: 'Looking ahead, we can expect even more integration of AI into our daily lives, making technology more intuitive and accessible.',
          },
        ],
      },
      llm: {
        provider: 'dummy',
        model: 'dummy-model-v1',
        promptVersion: 'v1',
        generatedAt: new Date(),
      },
      dedupe: {
        urlHash: urlHash,
      },
      categories: ['AI', 'Technology', 'Future'],
    };
  });

  try {
    const result = await ArticleSummary.insertMany(dummyData);
    console.log(`Successfully inserted ${result.length} dummy articles.`);
  } catch (error) {
    console.error('Error inserting dummy data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
