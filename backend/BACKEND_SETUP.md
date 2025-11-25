# CarQR Backend Setup Guide

## Quick Start (5 minutes)

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Setup Environment
```bash
# Copy example env file
cp .env.example .env

# Edit .env with your configuration
# Important: Update DB_PASSWORD, JWT_SECRET, and Razorpay keys
```

### 3. Create Database
```bash
# Initialize MySQL database and tables
node database.sql.js
```

### 4. Start Server
```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

Server runs on: `http://localhost:3000`

---

## Environment Variables

Create a `.env` file in the `backend` directory:

```bash
# Server
NODE_ENV=development
PORT=3000
BASE_URL=http://localhost:3000

# Database (MySQL)
DB_HOST=localhost
DB_PORT=3306
DB_USER=carqr_user
DB_PASSWORD=carqr_password_123
DB_NAME=carqr_db

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_this
JWT_EXPIRY=24h
REFRESH_TOKEN_EXPIRY=7d

# Redis (for OTP caching)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Razorpay Payment
RAZORPAY_KEY_ID=rzp_live_your_key_here
RAZORPAY_KEY_SECRET=your_secret_key_here

# AWS S3 (for QR storage)
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_BUCKET_NAME=carqr-qr-codes
AWS_REGION=ap-south-1

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Twilio (SMS for OTP)
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE=+1234567890

# CORS
CORS_ORIGIN=http://localhost:5000,https://carqr.app
```

---

## Project Structure

```
backend/
├── server.js                 # Main server file
├── database.sql.js          # Database initialization
├── package.json
├── .env.example
├── config/
│   ├── database.js          # MySQL connection pool
│   └── redis.js             # Redis client
├── middleware/
│   └── auth.js              # JWT verification
├── controllers/
│   ├── authController.js    # Authentication logic
│   ├── userController.js    # User management
│   ├── carController.js     # Car management
│   ├── scanController.js    # Scan logging
│   ├── qrController.js      # QR generation
│   └── paymentController.js # Payment processing
├── routes/
│   ├── auth.js
│   ├── users.js
│   ├── cars.js
│   ├── scans.js
│   ├── qr.js
│   └── payments.js
└── utils/
    └── validators.js        # Validation helpers
```

---

## API Endpoints

### Authentication
- `POST /api/v1/auth/otp/request` - Request OTP
- `POST /api/v1/auth/otp/verify` - Verify OTP & Register
- `POST /api/v1/auth/email/login` - Email login
- `POST /api/v1/auth/logout` - Logout
- `POST /api/v1/auth/refresh` - Refresh token

### Users
- `GET /api/v1/users/me` - Get profile (Protected)
- `PUT /api/v1/users/me/template` - Update template (Protected)
- `POST /api/v1/users/me/upgrade-premium` - Upgrade to premium (Protected)

### Cars
- `POST /api/v1/cars` - Save car info (Protected)
- `GET /api/v1/cars/me` - Get user's car (Protected)
- `GET /api/v1/cars/qr/:qrCode` - Get car by QR code (Public)
- `PUT /api/v1/cars/:carId` - Update car (Protected)

### Scans
- `POST /api/v1/scans` - Log scan activity (Public)
- `GET /api/v1/scans/:carId/scans` - Get scan history (Protected)

### QR Codes
- `POST /api/v1/qr/generate` - Generate QR code (Protected)
- `GET /api/v1/qr/:qrId` - Get QR code info (Public)

### Payments
- `POST /api/v1/payments/razorpay/create` - Create payment order (Protected)
- `POST /api/v1/payments/razorpay/verify` - Verify payment (Protected)

---

## Database Requirements

### MySQL Installation

**Windows:**
```bash
# Using Chocolatey
choco install mysql

# Or download from https://dev.mysql.com/downloads/mysql/
```

**macOS:**
```bash
brew install mysql
brew services start mysql
```

**Linux (Ubuntu):**
```bash
sudo apt-get install mysql-server
sudo mysql_secure_installation
```

### Create Database User

```sql
-- Login to MySQL
mysql -u root -p

-- Create user (replace password)
CREATE USER 'carqr_user'@'localhost' IDENTIFIED BY 'carqr_password_123';

-- Grant privileges
GRANT ALL PRIVILEGES ON carqr_db.* TO 'carqr_user'@'localhost';
FLUSH PRIVILEGES;
```

---

## Redis Installation (Optional for Development)

### Windows
```bash
# Using Chocolatey
choco install redis-64

# Or use Windows Subsystem for Linux (WSL)
wsl
sudo apt-get install redis-server
```

### macOS
```bash
brew install redis
brew services start redis
```

### Linux (Ubuntu)
```bash
sudo apt-get install redis-server
sudo service redis-server start
```

---

## Testing the API

### Using cURL

**Request OTP:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/otp/request \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543210"}'
```

**Verify OTP:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/otp/verify \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "9876543210",
    "otp": "123456",
    "email": "user@example.com",
    "sessionId": "session_xyz"
  }'
```

### Using Postman

1. Import collection from `API_REQUIREMENTS.md`
2. Set environment variables for auth tokens
3. Test each endpoint sequentially

### Using Thunder Client (VS Code)

1. Install Thunder Client extension
2. Create new request with test scenarios
3. Generate code snippets for frontend integration

---

## Deployment

### Deploy to Heroku

```bash
# Login
heroku login

# Create app
heroku create carqr-backend

# Add MySQL (using JawsDB)
heroku addons:create jawsdb:kitefin

# Deploy
git push heroku main
```

### Deploy to DigitalOcean

```bash
# Create droplet (Ubuntu 20.04)
# SSH into droplet

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install MySQL
sudo apt install -y mysql-server
sudo mysql_secure_installation

# Clone repo
git clone <your-repo>
cd carqr/backend

# Setup
npm install
cp .env.example .env
# Edit .env with production values
node database.sql.js

# Run with PM2
sudo npm install -g pm2
pm2 start server.js --name "carqr-api"
pm2 startup
pm2 save
```

---

## Troubleshooting

### Database Connection Failed
```
Error: connect ECONNREFUSED 127.0.0.1:3306

Solution:
- Check MySQL is running: sudo service mysql status
- Verify credentials in .env
- Ensure database user exists
```

### OTP Not Sending
```
For development, OTP is logged to console:
[DEV] OTP for 9876543210: 123456

For production:
- Setup Twilio account
- Add TWILIO_* to .env
- Implement SMS sending in authController.js
```

### Redis Connection Error
```
Error: Error: connect ECONNREFUSED 127.0.0.1:6379

Solution (use database for OTP fallback):
- Fallback OTP storage implemented in database.sql.js
- Or: Start Redis: redis-server
```

### JWT Token Expired
```
Error: invalid token

Solution:
- Use refreshToken endpoint to get new token
- Update auth header with new token
- Implement token refresh in Flutter app
```

---

## Performance Tips

1. **Add Database Indexes**: Already included in database.sql.js
2. **Enable Caching**: Use Redis for OTP and sessions
3. **Use Connection Pooling**: Already configured in config/database.js
4. **Implement Rate Limiting**: Add express-rate-limit package
5. **Enable Compression**: Add compression middleware

---

## Security Checklist

- [ ] Change JWT_SECRET in production
- [ ] Use strong DB_PASSWORD
- [ ] Enable HTTPS in production
- [ ] Add rate limiting
- [ ] Validate all inputs (already done)
- [ ] Use environment variables for secrets
- [ ] Enable CORS only for trusted domains
- [ ] Add request logging
- [ ] Setup database backups
- [ ] Monitor error logs

---

## Next Steps

1. ✅ Setup database and server
2. ✅ Test API endpoints with Postman/cURL
3. ✅ Connect Flutter app to API (update MockService)
4. ✅ Setup Razorpay for payments
5. ✅ Deploy to production
6. ⏭️ Setup monitoring and analytics
7. ⏭️ Create admin dashboard

---

## Support

For issues or questions:
1. Check error logs: `console output`
2. Review API_REQUIREMENTS.md
3. Check GitHub issues
4. Contact development team

