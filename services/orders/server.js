const { startTelemetry } = require('./telemetry');

startTelemetry('orders-service');

const express = require('express');
const axios = require('axios');
const cors = require('cors');
const logger = require('./logger');

const app = express();
const port = process.env.PORT || 3002;
const usersUrl = process.env.USERS_URL || 'http://localhost:3001';
const catalogUrl = process.env.CATALOG_URL || 'http://localhost:3003';

app.use(cors());

const orders = [
  { id: 101, userId: 1, itemId: 11, status: 'created' },
  { id: 102, userId: 2, itemId: 12, status: 'processing' },
];

app.get('/health', (req, res) => res.json({ service: 'orders', status: 'ok' }));
app.get('/metrics', (req, res) => res.type('text/plain').send('orders_service_up 1\n'));

app.get('/orders', async (req, res) => {
  try {
    const [usersResponse, catalogResponse] = await Promise.all([
      axios.get(`${usersUrl}/users`),
      axios.get(`${catalogUrl}/items`),
    ]);

    logger.info({ route: '/orders', count: orders.length }, 'listing orders');
    res.json({ orders, users: usersResponse.data, catalog: catalogResponse.data });
  } catch (error) {
    logger.error({ error: error.message }, 'failed to compose order data');
    res.status(500).json({ error: 'failed to fetch dependent services' });
  }
});

app.listen(port, () => logger.info({ port }, 'orders service started'));