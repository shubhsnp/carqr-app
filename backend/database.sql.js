const { Client } = require('pg');
require('dotenv').config();

const createDatabase = async () => {
  const dbName = process.env.DB_NAME || 'carqr_db';
  const adminClient = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: 'postgres'
  });

  try {
    await adminClient.connect();

    // Check if database exists
    const check = await adminClient.query('SELECT 1 FROM pg_database WHERE datname = $1', [dbName]);
    if (check.rowCount === 0) {
      await adminClient.query(`CREATE DATABASE "${dbName}"`);
      console.log('✓ Database created successfully');
    } else {
      console.log('✓ Database already exists');
    }

    await adminClient.end();

    // Connect to the created database to create tables
    const client = new Client({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5432,
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || '',
      database: dbName
    });

    await client.connect();

    // Create users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(100) PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(10) UNIQUE NOT NULL,
        isPremium BOOLEAN DEFAULT FALSE,
        plan VARCHAR(20) DEFAULT 'basic',
        hasCarInfo BOOLEAN DEFAULT FALSE,
        selectedTemplate VARCHAR(50) DEFAULT 'modern',
        premiumExpiryDate TIMESTAMP NULL,
        createdAt TIMESTAMP DEFAULT NOW(),
        updatedAt TIMESTAMP DEFAULT NOW()
      )
    `);
    await client.query('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_users_createdAt ON users(createdAt)');
    console.log('✓ Users table created');

    // Create cars table
    await client.query(`
      CREATE TABLE IF NOT EXISTS cars (
        id VARCHAR(100) PRIMARY KEY,
        "userId" VARCHAR(100) NOT NULL UNIQUE,
        "carNumber" VARCHAR(50) NOT NULL,
        "carModel" VARCHAR(100) NOT NULL,
        "customMessage" TEXT,
        "customFields" JSON,
        "selectedTemplate" VARCHAR(50) DEFAULT 'modern',
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        CONSTRAINT fk_user FOREIGN KEY("userId") REFERENCES users(id) ON DELETE CASCADE
      )
    `);
    await client.query('CREATE INDEX IF NOT EXISTS idx_cars_userId ON cars("userId")');
    await client.query('CREATE INDEX IF NOT EXISTS idx_cars_carNumber ON cars("carNumber")');
    console.log('✓ Cars table created');

    // Create scans table
    await client.query(`
      CREATE TABLE IF NOT EXISTS scans (
        id VARCHAR(100) PRIMARY KEY,
        "carId" VARCHAR(100) NOT NULL,
        "scannerPhone" VARCHAR(10),
        "scannerEmail" VARCHAR(255),
        notes TEXT,
        "timestamp" TIMESTAMP DEFAULT NOW(),
        CONSTRAINT fk_car_scans FOREIGN KEY("carId") REFERENCES cars(id) ON DELETE CASCADE
      )
    `);
    await client.query('CREATE INDEX IF NOT EXISTS idx_scans_carId ON scans("carId")');
    await client.query('CREATE INDEX IF NOT EXISTS idx_scans_timestamp ON scans("timestamp")');
    console.log('✓ Scans table created');

    // Create qr_codes table
    await client.query(`
      CREATE TABLE IF NOT EXISTS qr_codes (
        id VARCHAR(100) PRIMARY KEY,
        "carId" VARCHAR(100) NOT NULL,
        size VARCHAR(10),
        format VARCHAR(10),
        qrValue TEXT,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        CONSTRAINT fk_car_qr FOREIGN KEY("carId") REFERENCES cars(id) ON DELETE CASCADE
      )
    `);
    await client.query('CREATE INDEX IF NOT EXISTS idx_qr_carId ON qr_codes("carId")');
    console.log('✓ QR Codes table created');

    // Create payments table
    await client.query(`
      CREATE TABLE IF NOT EXISTS payments (
        id VARCHAR(100) PRIMARY KEY,
        "userId" VARCHAR(100) NOT NULL,
        "orderId" VARCHAR(100),
        "paymentId" VARCHAR(100),
        amount INT,
        currency VARCHAR(3) DEFAULT 'INR',
        status VARCHAR(20) DEFAULT 'pending',
        "planDuration" INT DEFAULT 365,
        "verifiedAt" TIMESTAMP NULL,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        CONSTRAINT fk_user_payments FOREIGN KEY("userId") REFERENCES users(id) ON DELETE CASCADE
      )
    `);
    await client.query('CREATE INDEX IF NOT EXISTS idx_payments_userId ON payments("userId")');
    await client.query('CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_payments_createdAt ON payments("createdAt")');
    console.log('✓ Payments table created');

    // Create otp_sessions table
    await client.query(`
      CREATE TABLE IF NOT EXISTS otp_sessions (
        "sessionId" VARCHAR(100) PRIMARY KEY,
        phone VARCHAR(10) NOT NULL,
        otp VARCHAR(6) NOT NULL,
        "expiresAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    await client.query('CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_sessions(phone)');
    console.log('✓ OTP Sessions table created');

    await client.end();
    console.log('\n✓ Database initialization completed successfully!');
  } catch (error) {
    console.error('✗ Database initialization error:', error.message);
    process.exit(1);
  }
};

createDatabase();
