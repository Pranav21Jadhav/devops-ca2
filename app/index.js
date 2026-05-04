const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', uptime: process.uptime() });
});

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from DevOps Demo App!',
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Metrics stub endpoint (for Prometheus integration)
app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send(`# HELP app_requests_total Total HTTP requests\n# TYPE app_requests_total counter\napp_requests_total 42\n`);
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
