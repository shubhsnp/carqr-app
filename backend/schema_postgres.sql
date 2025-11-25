-- PostgreSQL schema extracted from database.sql.js
-- Usage: psql -h <host> -p <port> -U <user> -d <database> -f schema_postgres.sql

-- Note: This file assumes the target database already exists.

-- users
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
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_createdAt ON users(createdAt);

-- cars
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
);
CREATE INDEX IF NOT EXISTS idx_cars_userId ON cars("userId");
CREATE INDEX IF NOT EXISTS idx_cars_carNumber ON cars("carNumber");

-- scans
CREATE TABLE IF NOT EXISTS scans (
  id VARCHAR(100) PRIMARY KEY,
  "carId" VARCHAR(100) NOT NULL,
  "scannerPhone" VARCHAR(10),
  "scannerEmail" VARCHAR(255),
  notes TEXT,
  "timestamp" TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_car_scans FOREIGN KEY("carId") REFERENCES cars(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_scans_carId ON scans("carId");
CREATE INDEX IF NOT EXISTS idx_scans_timestamp ON scans("timestamp");

-- qr_codes
CREATE TABLE IF NOT EXISTS qr_codes (
  id VARCHAR(100) PRIMARY KEY,
  "carId" VARCHAR(100) NOT NULL,
  size VARCHAR(10),
  format VARCHAR(10),
  qrValue TEXT,
  "createdAt" TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_car_qr FOREIGN KEY("carId") REFERENCES cars(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_qr_carId ON qr_codes("carId");

-- payments
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
);
CREATE INDEX IF NOT EXISTS idx_payments_userId ON payments("userId");
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_createdAt ON payments("createdAt");

-- otp_sessions
CREATE TABLE IF NOT EXISTS otp_sessions (
  "sessionId" VARCHAR(100) PRIMARY KEY,
  phone VARCHAR(10) NOT NULL,
  otp VARCHAR(6) NOT NULL,
  "expiresAt" TIMESTAMP,
  "createdAt" TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_sessions(phone);
