const { startTelemetry } = require('./telemetry');

startTelemetry('users-service');

const express = require('express');
const cors = require('cors');
const logger = require('./logger');

const app = express();
const port = process.env.PORT || 3001;

const users = [
  { id: 1, name: 'Alice', role: 'student' },
  { id: 2, name: 'Bruno', role: 'student' },
  { id: 3, name: 'Carla', role: 'instructor' },
];

app.use(express.json());
app.use(cors());

app.get('/health', (req, res) => res.json({ service: 'users', status: 'ok' }));
app.get('/metrics', (req, res) => res.type('text/plain').send('users_service_up 1\n'));
app.get('/users', (req, res) => {
  logger.info({ route: '/users', count: users.length }, 'listing users');
  res.json(users);
});

app.listen(port, () => logger.info({ port }, 'users service started'));