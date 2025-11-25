const redis = require('redis');
require('dotenv').config();

const host = process.env.REDIS_HOST || 'localhost';
const port = process.env.REDIS_PORT || 6379;
const password = process.env.REDIS_PASSWORD;

const client = redis.createClient({
  url: password ? `redis://:${password}@${host}:${port}` : `redis://${host}:${port}`
});

client.on('error', (err) => console.error('Redis Client Error', err));

// Connect asynchronously without blocking server startup
client.connect().catch((err) => {
  console.warn('Redis connection failed (this is OK for testing):', err.message);
});

module.exports = client;
