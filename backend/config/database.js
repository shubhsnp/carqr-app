require('dotenv').config();
const { Pool } = require('pg');

// Create a Postgres pool
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'carqr_db',
  max: 10
});

// Compatibility wrapper to mimic mysql2's pool.getConnection()/connection.execute()
const convertPlaceholders = (sql) => {
  let i = 0;
  return sql.replace(/\?/g, () => {
    i += 1;
    return `$${i}`;
  });
};

const getConnection = async () => {
  // Get a dedicated client from the pool for transaction support
  const client = await pool.connect();
  
  return {
    execute: async (sql, params = []) => {
      const text = convertPlaceholders(sql);
      const res = await client.query(text, params);
      return [res.rows, res.fields || []];
    },
    beginTransaction: async () => {
      await client.query('BEGIN');
    },
    commit: async () => {
      await client.query('COMMIT');
    },
    rollback: async () => {
      await client.query('ROLLBACK');
    },
    release: () => {
      client.release();
    }
  };
};

module.exports = {
  getConnection,
  query: async (sql, params = []) => {
    const text = convertPlaceholders(sql);
    return pool.query(text, params);
  },
  pool
};
