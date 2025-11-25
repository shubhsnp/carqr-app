# CarQR Integration Startup Guide

## Quick Start (Recommended)

### **Option 1: Automated (Fastest)**
```powershell
cd C:\src\car_QR
.\START_APP.ps1
```
This script handles everything:
- ✓ Checks PostgreSQL is running
- ✓ Creates database (if needed)
- ✓ Starts backend API on port 3000
- ✓ Installs Flutter dependencies
- ✓ Starts Flutter app in Chrome

**Or use batch file:**
```cmd
C:\src\car_QR\START_APP.bat
```

---

## Manual Step-by-Step

### **Prerequisites**
- PostgreSQL installed and accessible via `psql` command
- Node.js installed
- Flutter SDK installed

### **Step 1: Verify Database Credentials**
File: `C:\src\car_QR\backend\.env`
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=Trushal@1234    # ← Your password configured
DB_NAME=carqr_db
```

### **Step 2: Create Database & Initialize Schema**
```powershell
cd C:\src\car_QR\backend

# Create database
createdb -U postgres -E UTF8 carqr_db

# Initialize schema
psql -U postgres -d carqr_db -f schema_postgres.sql
```

### **Step 3: Start Backend API**
```powershell
cd C:\src\car_QR\backend

# Install dependencies (first time only)
npm install

# Start server
node server.js

# Expected output:
# CarQR API Server running on port 3000
# Environment: development
```

**Verify it's running:**
```powershell
curl http://localhost:3000/health
# Should return: {"status":"ok","timestamp":"2025-11-20T..."}
```

### **Step 4: Start Flutter App (new terminal)**
```powershell
cd C:\src\car_QR

flutter pub get
flutter run -d chrome
```

---

## Architecture Overview

### **Data Flow**
```
Flutter App
    ↓
ApiService (http://localhost:3000/api/v1)
    ↓
Node.js Backend (server.js)
    ↓
PostgreSQL Database (carqr_db)
```

### **Key Files**
| File | Purpose |
|------|---------|
| `lib/services/api_service.dart` | HTTP client for all API calls |
| `lib/providers/user_provider.dart` | State management with API integration |
| `backend/server.js` | Express.js server with routes |
| `backend/.env` | Database credentials |
| `backend/schema_postgres.sql` | Database schema |

### **API Endpoints (v1)**
- **Auth**: `/api/v1/auth/otp/request`, `/api/v1/auth/otp/verify`
- **Users**: `/api/v1/users/me`, `/api/v1/users/template`
- **Cars**: `/api/v1/cars` (POST, GET, PUT)
- **QR**: `/api/v1/qr/scan`, `/api/v1/qr/generate`
- **Payments**: `/api/v1/payments/create-order`, `/api/v1/payments/verify`

---

## Troubleshooting

### **"PostgreSQL NOT found"**
```powershell
# Check if PostgreSQL is installed
psql --version

# If not found, install from: https://www.postgresql.org/download/windows/
# Then add to PATH or restart terminal after installation
```

### **"Database already exists / role already exists"**
Skip the creation steps, they're safe to ignore.

### **"Failed to connect to localhost:3000"**
1. Verify backend is running: Check terminal window
2. Check port 3000 is free: `netstat -ano | findstr :3000`
3. Restart backend if needed

### **"API call timeout"**
1. Ensure PostgreSQL is running: `psql -U postgres -c "SELECT 1"`
2. Check backend console for errors
3. Verify `.env` database credentials

### **"Flutter app won't start"**
```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

---

## Development Notes

### **Hot Reload**
While app is running in Chrome:
- **Save file** → Hot reload automatically
- **Ctrl+R** → Manual reload

### **Backend Hot Reload**
Install nodemon for auto-restart:
```bash
npm install --save-dev nodemon
node_modules\.bin\nodemon server.js
```

### **Database Testing**
```powershell
# Connect to database
psql -U postgres -d carqr_db

# List tables
\dt

# Check users table
SELECT id, email, phone, isPremium FROM users;

# Exit
\q
```

---

## What Gets Integrated

### **User Registration Flow**
1. User enters email + phone in app
2. ApiService sends to `/api/v1/auth/otp/request`
3. Backend generates OTP, stores in Redis
4. User verifies OTP
5. Backend creates user in PostgreSQL
6. Returns JWT token
7. App stores user in UserProvider

### **Scanning QR Code**
1. User scans or enters QR code
2. ApiService sends to `/api/v1/qr/scan`
3. Backend queries cars table for QR data
4. Returns owner info (if user is premium)
5. App displays in ScanResultScreen

### **Premium Upgrade**
1. User clicks "Upgrade to Premium"
2. ApiService initiates payment: `/api/v1/payments/create-order`
3. Frontend handles Razorpay payment
4. Backend verifies payment and updates users.isPremium
5. App shows premium features

---

## Configuration Reference

### **.env File** (Backend)
```env
NODE_ENV=development              # Environment
PORT=3000                         # Server port
BASE_URL=http://localhost:3000    # For CORS

# Database (PostgreSQL)
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=Trushal@1234
DB_NAME=carqr_db

# JWT Authentication
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRY=24h
REFRESH_TOKEN_EXPIRY=7d

# Redis (for OTP storage)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Razorpay (Payment Gateway)
RAZORPAY_KEY_ID=rzp_live_your_key_here
RAZORPAY_KEY_SECRET=your_secret_key_here
```

### **Flutter API Configuration** (app.dart)
```dart
// Base URL is hardcoded in lib/services/api_service.dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

---

## Next Steps

1. ✓ Run `START_APP.ps1` or `START_APP.bat`
2. ✓ Wait for Flutter app to open in Chrome
3. ✓ Register with phone number (e.g., 9876543210)
4. ✓ Verify OTP (check backend console for generated OTP)
5. ✓ Scan QR code (try: QR001, QR002, QR003)
6. ✓ Upgrade to Premium and view owner info

---

## Success Indicators

✓ Backend terminal shows: `CarQR API Server running on port 3000`
✓ Flutter app opens in Chrome
✓ OTP verification works with real database
✓ Premium gate shows actual owner data from database
✓ User data persists after app restart (in same session)

---
