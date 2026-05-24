const { startTelemetry } = require('./telemetry');

startTelemetry('catalog-service');

const express = require('express');
const cors = require('cors');
const logger = require('./logger');

const app = express();
const port = process.env.PORT || 3003;

app.use(cors());

const items = [
  { id: 11, name: 'Kubernetes Fundamentals', type: 'course' },
  { id: 12, name: 'Incident Response 101', type: 'lab' },
  { id: 13, name: 'Observability Basics', type: 'workshop' },
];

app.get('/health', (req, res) => res.json({ service: 'catalog', status: 'ok' }));
app.get('/metrics', (req, res) => res.type('text/plain').send('catalog_service_up 1\n'));
app.get('/items', (req, res) => {
  logger.info({ route: '/items', count: items.length }, 'listing catalog items');
  res.json(items);
});

app.listen(port, () => logger.info({ port }, 'catalog service started'));