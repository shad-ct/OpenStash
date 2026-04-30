const express = require('express');
const cors = require('cors');

const summariesRouter = require('./routes/summaries.route');
const { runOnce } = require('./jobs/fetchAndSummarize.job');

function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json({ limit: '1mb' }));

  app.get('/health', (req, res) => {
    res.json({ ok: true });
  });

  app.post('/api/refresh', async (req, res) => {
    const force = Boolean(req.query.force || req.body?.force);
    try {
      await runOnce({ force });
      res.json({ message: 'Fetch and summarize job completed', force });
    } catch (err) {
      console.error('Manual trigger error:', err);
      res.status(500).json({ message: 'Job failed', error: err.message });
    }
  });

  app.use('/api/summaries', summariesRouter);

  // Basic error handler
  // eslint-disable-next-line no-unused-vars
  app.use((err, req, res, next) => {
    const status = err.statusCode || err.status || 500;
    res.status(status).json({ message: err.message || 'Internal Server Error' });
  });

  return app;
}

module.exports = { createApp };
