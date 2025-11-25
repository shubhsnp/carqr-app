# CarQR Clean - API Requirements Documentation

## Base URL
```
https://api.carqr.app/v1
```

---

## 1. Authentication Endpoints

### 1.1 Request OTP
**Endpoint:** `POST /auth/otp/request`

**Description:** Send OTP to user's phone number

**Request Body:**
```json
{
  "phone": "9876543210"
}
```

**Response (Success 200):**
```json
{
  "success": true,
  "message": "OTP sent to your phone",
  "expiresIn": 300,
  "sessionId": "session_abc123xyz"
}
```

**Response (Error 400/422):**
```json
{
  "success": false,
  "error": "Invalid phone number format",
  "code": "INVALID_PHONE"
}
```

**Notes:**
- Phone should be 10 digits (India format: 9876543210)
- OTP valid for 5 minutes (300 seconds)
- Return sessionId for next step verification

---

### 1.2 Verify OTP & Register
**Endpoint:** `POST /auth/otp/verify`

**Description:** Verify OTP and create/login user

**Request Body:**
```json
{
  "phone": "9876543210",
  "otp": "123456",
  "email": "user@example.com",
  "sessionId": "session_abc123xyz"
}
```

**Response (Success 200):**
```json
{
  "success": true,
  "user": {
    "id": "user_1234567890",
    "email": "user@example.com",
    "phone": "9876543210",
    "isPremium": false,
    "plan": "basic",
    "hasCarInfo": false,
    "selectedTemplate": "modern",
    "premiumExpiryDate": null,
    "createdAt": "2025-11-16T10:30:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_xyz..."
}
```

**Response (Error 400/401):**
```json
{
  "success": false,
  "error": "Invalid or expired OTP",
  "code": "INVALID_OTP"
}
```

**Notes:**
- Email is optional (if not provided, generate email as: `user_{phone}@carqr.app`)
- Return JWT token for authenticated requests
- Return refreshToken for token renewal
- New users: `isPremium=false, plan="basic"`
- Demo: Auto-premium if email contains "premium"

---

### 1.3 Email Login
**Endpoint:** `POST /auth/email/login`

**Description:** Login with email (for existing users)

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (Success 200):**
```json
{
  "success": true,
  "user": {
    "id": "user_1234567890",
    "email": "user@example.com",
    "phone": "9876543210",
    "isPremium": false,
    "plan": "basic",
    "hasCarInfo": false,
    "selectedTemplate": "modern",
    "premiumExpiryDate": null,
    "createdAt": "2025-11-16T10:30:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_xyz..."
}
```

**Response (Error 404):**
```json
{
  "success": false,
  "error": "User not found",
  "code": "USER_NOT_FOUND"
}
```

---

### 1.4 Logout
**Endpoint:** `POST /auth/logout`

**Authentication:** Required (Bearer Token)

**Request Header:**
```
Authorization: Bearer {token}
```

**Response (Success 200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 2. User Management Endpoints

### 2.1 Get User Profile
**Endpoint:** `GET /users/me`

**Authentication:** Required (Bearer Token)

**Response (Success 200):**
```json
{
  "success": true,
  "user": {
    "id": "user_1234567890",
    "email": "user@example.com",
    "phone": "9876543210",
    "isPremium": false,
    "plan": "basic",
    "hasCarInfo": true,
    "selectedTemplate": "modern",
    "premiumExpiryDate": null,
    "createdAt": "2025-11-16T10:30:00Z"
  }
}
```

---

### 2.2 Update User Template
**Endpoint:** `PUT /users/me/template`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "templateId": "modern"
}
```

**Valid Values:**
- `"modern"` - Gradient, emojis, colorful
- `"classic"` - Bordered, traditional layout
- `"minimal"` - Clean, compact design

**Response (Success 200):**
```json
{
  "success": true,
  "user": {
    "id": "user_1234567890",
    "selectedTemplate": "modern",
    "updatedAt": "2025-11-16T10:35:00Z"
  }
}
```

---

### 2.3 Upgrade to Premium
**Endpoint:** `POST /users/me/upgrade-premium`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "paymentId": "razorpay_pay_123abc",
  "planDuration": 365
}
```

**Request Body (Alternative - Free Upgrade for Testing):**
```json
{
  "isTest": true
}
```

**Response (Success 200):**
```json
{
  "success": true,
  "user": {
    "id": "user_1234567890",
    "isPremium": true,
    "plan": "premium",
    "premiumExpiryDate": "2026-11-16T10:35:00Z",
    "updatedAt": "2025-11-16T10:35:00Z"
  }
}
```

**Response (Error 400):**
```json
{
  "success": false,
  "error": "Invalid payment",
  "code": "INVALID_PAYMENT"
}
```

---

## 3. Car Information Endpoints

### 3.1 Save Car Information
**Endpoint:** `POST /cars`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "carNumber": "MH01AB1234",
  "carModel": "Honda City 2022",
  "customMessage": "Call me if blocking your way",
  "selectedTemplate": "modern",
  "customFields": {
    "color": "silver",
    "insurance": "2026-12-31",
    "registrationNumber": "ABC123"
  }
}
```

**Response (Success 201):**
```json
{
  "success": true,
  "car": {
    "id": "car_abc123xyz",
    "userId": "user_1234567890",
    "carNumber": "MH01AB1234",
    "carModel": "Honda City 2022",
    "customMessage": "Call me if blocking your way",
    "selectedTemplate": "modern",
    "customFields": {
      "color": "silver",
      "insurance": "2026-12-31",
      "registrationNumber": "ABC123"
    },
    "createdAt": "2025-11-16T10:40:00Z"
  }
}
```

---

### 3.2 Get User's Car Info
**Endpoint:** `GET /cars/me`

**Authentication:** Required (Bearer Token)

**Response (Success 200):**
```json
{
  "success": true,
  "car": {
    "id": "car_abc123xyz",
    "userId": "user_1234567890",
    "carNumber": "MH01AB1234",
    "carModel": "Honda City 2022",
    "customMessage": "Call me if blocking your way",
    "selectedTemplate": "modern",
    "customFields": {
      "color": "silver",
      "insurance": "2026-12-31"
    },
    "createdAt": "2025-11-16T10:40:00Z"
  }
}
```

**Response (No Car 404):**
```json
{
  "success": false,
  "error": "No car information found",
  "code": "CAR_NOT_FOUND"
}
```

---

### 3.3 Update Car Information
**Endpoint:** `PUT /cars/{carId}`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "carModel": "Honda City 2023",
  "customMessage": "Updated message",
  "selectedTemplate": "classic",
  "customFields": {
    "color": "white",
    "insurance": "2027-12-31"
  }
}
```

**Response (Success 200):**
```json
{
  "success": true,
  "car": {
    "id": "car_abc123xyz",
    "carModel": "Honda City 2023",
    "customMessage": "Updated message",
    "selectedTemplate": "classic",
    "customFields": {
      "color": "white",
      "insurance": "2027-12-31"
    },
    "updatedAt": "2025-11-16T10:45:00Z"
  }
}
```

---

### 3.4 Get Car by QR Code
**Endpoint:** `GET /cars/qr/{qrCode}`

**Authentication:** Optional (Public endpoint, but owner info restricted)

**Path Parameters:**
- `qrCode` - QR code value (e.g., "QR001", "MH01AB1234")

**Response (Success 200):**
```json
{
  "success": true,
  "car": {
    "id": "car_abc123xyz",
    "carNumber": "MH01AB1234",
    "carModel": "Honda City 2022",
    "customMessage": "Call me if blocking your way",
    "customFields": {
      "color": "silver"
    },
    "owner": {
      "name": "John Doe",
      "phone": "9876543210",
      "email": "john@example.com"
    },
    "selectedTemplate": "modern"
  }
}
```

**Response (Error 404):**
```json
{
  "success": false,
  "error": "Car not found",
  "code": "CAR_NOT_FOUND"
}
```

**Notes:**
- Public endpoint - no auth required
- Returns owner info (phone, email) for any QR code
- Used by scanner flow to get car details

---

## 4. Scanner Activity Endpoints

### 4.1 Log Scan Activity
**Endpoint:** `POST /scans`

**Authentication:** Optional (Can be logged by anonymous users)

**Request Body:**
```json
{
  "carId": "QR001",
  "scannerPhone": "9876543210",
  "scannerEmail": "scanner@example.com",
  "notes": "Scanned via mobile app"
}
```

**Response (Success 201):**
```json
{
  "success": true,
  "activity": {
    "id": "scan_xyz789abc",
    "carId": "QR001",
    "scannerPhone": "9876543210",
    "scannerEmail": "scanner@example.com",
    "timestamp": "2025-11-16T10:50:00Z",
    "notes": "Scanned via mobile app"
  }
}
```

**Notes:**
- Log every scan for analytics
- scannerPhone & scannerEmail from form gate
- Used for lead generation tracking
- Optional authentication (useful for premium vs basic plan tracking)

---

### 4.2 Get Scan History
**Endpoint:** `GET /cars/{carId}/scans`

**Authentication:** Required (Bearer Token - Owner only)

**Query Parameters:**
- `limit` - Max results (default: 50)
- `offset` - Pagination offset (default: 0)
- `from` - Start date (ISO 8601: 2025-11-01)
- `to` - End date (ISO 8601: 2025-11-30)

**Example:**
```
GET /cars/car_abc123xyz/scans?limit=50&offset=0&from=2025-11-01&to=2025-11-30
```

**Response (Success 200):**
```json
{
  "success": true,
  "scans": [
    {
      "id": "scan_xyz789abc",
      "carId": "car_abc123xyz",
      "scannerPhone": "9876543210",
      "scannerEmail": "scanner@example.com",
      "timestamp": "2025-11-16T10:50:00Z",
      "notes": "Form gate submission"
    },
    {
      "id": "scan_abc456def",
      "carId": "car_abc123xyz",
      "scannerPhone": "8765432109",
      "scannerEmail": "other@example.com",
      "timestamp": "2025-11-15T15:20:00Z",
      "notes": "Basic plan user"
    }
  ],
  "pagination": {
    "total": 150,
    "limit": 50,
    "offset": 0
  }
}
```

---

## 5. QR Generation Endpoints

### 5.1 Generate QR Code
**Endpoint:** `POST /qr/generate`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "carId": "car_abc123xyz",
  "size": "3x3",
  "format": "pdf"
}
```

**Size Options:**
- `"3x3"` - 3×3 inches (compact)
- `"4x4"` - 4×4 inches (standard)

**Format Options:**
- `"pdf"` - PDF document
- `"svg"` - SVG vector format
- `"png"` - PNG image

**Response (Success 200):**
```json
{
  "success": true,
  "qr": {
    "id": "qr_xyz123abc",
    "carId": "car_abc123xyz",
    "size": "3x3",
    "format": "pdf",
    "qrValue": "https://carqr.app/cars/car_abc123xyz",
    "downloadUrl": "https://cdn.carqr.app/qr/qr_xyz123abc.pdf",
    "createdAt": "2025-11-16T10:55:00Z"
  }
}
```

---

### 5.2 Get QR Code Data
**Endpoint:** `GET /qr/{qrId}`

**Response (Success 200):**
```json
{
  "success": true,
  "qr": {
    "id": "qr_xyz123abc",
    "carId": "car_abc123xyz",
    "size": "3x3",
    "format": "pdf",
    "qrValue": "https://carqr.app/cars/car_abc123xyz",
    "downloadUrl": "https://cdn.carqr.app/qr/qr_xyz123abc.pdf",
    "createdAt": "2025-11-16T10:55:00Z"
  }
}
```

---

## 6. Payment Endpoints

### 6.1 Initiate Razorpay Payment
**Endpoint:** `POST /payments/razorpay/create`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "amount": 499,
  "currency": "INR",
  "planDuration": 365
}
```

**Response (Success 200):**
```json
{
  "success": true,
  "payment": {
    "id": "pay_xyz123abc",
    "orderId": "order_KyqOvzL59c8zJ1",
    "amount": 499,
    "currency": "INR",
    "key": "rzp_live_xxxxxxxxxx",
    "customerId": "user_1234567890"
  }
}
```

**Notes:**
- Return Razorpay order ID and API key
- Frontend will use Razorpay SDK to complete payment
- Amount in paise (499 = Rs. 4.99)

---

### 6.2 Verify Payment
**Endpoint:** `POST /payments/razorpay/verify`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "paymentId": "pay_xyz123abc",
  "orderId": "order_KyqOvzL59c8zJ1",
  "signature": "9ef4dffbfd84f1318f6739a3ce19f9d85851857ae648f114332d8401e0949a3d"
}
```

**Response (Success 200):**
```json
{
  "success": true,
  "payment": {
    "id": "pay_xyz123abc",
    "userId": "user_1234567890",
    "status": "completed",
    "amount": 499,
    "planDuration": 365,
    "premiumExpiryDate": "2026-11-16T10:55:00Z",
    "verifiedAt": "2025-11-16T10:55:00Z"
  }
}
```

**Response (Error 400):**
```json
{
  "success": false,
  "error": "Payment verification failed",
  "code": "INVALID_SIGNATURE"
}
```

---

## 7. Error Codes Reference

| Code | HTTP | Meaning | Action |
|------|------|---------|--------|
| `INVALID_PHONE` | 422 | Phone format invalid | Validate format before sending |
| `INVALID_OTP` | 401 | OTP expired or wrong | Ask user to request new OTP |
| `USER_NOT_FOUND` | 404 | Email/user doesn't exist | Show registration prompt |
| `UNAUTHORIZED` | 401 | Token missing/invalid | Refresh token or logout/login |
| `FORBIDDEN` | 403 | User not authorized | Check permissions |
| `CAR_NOT_FOUND` | 404 | Car info doesn't exist | Create car info first |
| `INVALID_PAYMENT` | 400 | Payment verification failed | Retry payment |
| `INVALID_SIGNATURE` | 400 | Razorpay signature mismatch | Security issue - contact support |
| `SERVER_ERROR` | 500 | Backend error | Retry or contact support |

---

## 8. Authentication Details

### JWT Token Structure
**Header:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Token Expiry:** 24 hours

**Refresh Token Endpoint:** `POST /auth/refresh`
```json
{
  "refreshToken": "refresh_token_xyz..."
}
```

**Response:**
```json
{
  "token": "new_jwt_token...",
  "refreshToken": "new_refresh_token..."
}
```

---

## 9. Implementation Priority

### Phase 1 (Core - Must Have)
1. ✅ `/auth/otp/request` - Request OTP
2. ✅ `/auth/otp/verify` - Verify & register
3. ✅ `/users/me` - Get profile
4. ✅ `/cars` - Save car info
5. ✅ `/cars/qr/{qrCode}` - Get car by QR
6. ✅ `/scans` - Log scan activity
7. ✅ `/users/me/upgrade-premium` - Premium upgrade

### Phase 2 (Features)
1. `/cars/me` - Get user's car
2. `/cars/{carId}` - Update car
3. `/cars/{carId}/scans` - Scan history
4. `/qr/generate` - Generate QR codes

### Phase 3 (Payment)
1. `/payments/razorpay/create` - Create payment
2. `/payments/razorpay/verify` - Verify payment

---

## 10. Sample Request/Response Examples

### Complete User Registration Flow

**Step 1: Request OTP**
```bash
curl -X POST https://api.carqr.app/v1/auth/otp/request \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543210"}'
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent to your phone",
  "expiresIn": 300,
  "sessionId": "session_abc123xyz"
}
```

---

**Step 2: Verify OTP & Create User**
```bash
curl -X POST https://api.carqr.app/v1/auth/otp/verify \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "9876543210",
    "otp": "123456",
    "email": "user@example.com",
    "sessionId": "session_abc123xyz"
  }'
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user_1234567890",
    "email": "user@example.com",
    "phone": "9876543210",
    "isPremium": false,
    "plan": "basic",
    "hasCarInfo": false,
    "selectedTemplate": "modern",
    "premiumExpiryDate": null,
    "createdAt": "2025-11-16T10:30:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

**Step 3: Save Car Information**
```bash
curl -X POST https://api.carqr.app/v1/cars \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "carNumber": "MH01AB1234",
    "carModel": "Honda City 2022",
    "customMessage": "Call me if blocking your way",
    "selectedTemplate": "modern",
    "customFields": {
      "color": "silver",
      "insurance": "2026-12-31"
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "car": {
    "id": "car_abc123xyz",
    "userId": "user_1234567890",
    "carNumber": "MH01AB1234",
    "carModel": "Honda City 2022",
    "customMessage": "Call me if blocking your way",
    "selectedTemplate": "modern",
    "customFields": {
      "color": "silver",
      "insurance": "2026-12-31"
    },
    "createdAt": "2025-11-16T10:40:00Z"
  }
}
```

---

## 11. Database Schema (Reference)

```sql
-- Users Table
CREATE TABLE users (
  id VARCHAR(50) PRIMARY KEY,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(10) UNIQUE NOT NULL,
  isPremium BOOLEAN DEFAULT FALSE,
  plan VARCHAR(20) DEFAULT 'basic',
  hasCarInfo BOOLEAN DEFAULT FALSE,
  selectedTemplate VARCHAR(50) DEFAULT 'modern',
  premiumExpiryDate TIMESTAMP NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Cars Table
CREATE TABLE cars (
  id VARCHAR(50) PRIMARY KEY,
  userId VARCHAR(50) NOT NULL,
  carNumber VARCHAR(50) NOT NULL,
  carModel VARCHAR(100) NOT NULL,
  customMessage TEXT,
  customFields JSON,
  selectedTemplate VARCHAR(50) DEFAULT 'modern',
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(id),
  UNIQUE (userId)
);

-- Scan Activities Table
CREATE TABLE scans (
  id VARCHAR(50) PRIMARY KEY,
  carId VARCHAR(50) NOT NULL,
  scannerPhone VARCHAR(10),
  scannerEmail VARCHAR(100),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes TEXT,
  FOREIGN KEY (carId) REFERENCES cars(id),
  INDEX (carId),
  INDEX (timestamp)
);

-- QR Codes Table
CREATE TABLE qr_codes (
  id VARCHAR(50) PRIMARY KEY,
  carId VARCHAR(50) NOT NULL,
  size VARCHAR(10),
  format VARCHAR(10),
  qrValue TEXT,
  downloadUrl TEXT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (carId) REFERENCES cars(id)
);

-- Payments Table
CREATE TABLE payments (
  id VARCHAR(50) PRIMARY KEY,
  userId VARCHAR(50) NOT NULL,
  paymentId VARCHAR(100),
  orderId VARCHAR(100),
  amount INT,
  currency VARCHAR(3),
  status VARCHAR(20),
  planDuration INT,
  verifiedAt TIMESTAMP NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(id)
);
```

---

## 12. Environment Variables (Backend Setup)

```bash
# Server
NODE_ENV=production
PORT=3000
BASE_URL=https://api.carqr.app

# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=carqr_user
DB_PASSWORD=strong_password
DB_NAME=carqr_db

# JWT
JWT_SECRET=your_secret_key_here
JWT_EXPIRY=24h

# Razorpay
RAZORPAY_KEY_ID=rzp_live_xxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxx

# S3/CDN (for QR file storage)
AWS_ACCESS_KEY_ID=xxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxx
AWS_BUCKET_NAME=carqr-qr-codes
AWS_REGION=ap-south-1
```

---

## 13. Testing Credentials (Demo)

```
Phone: 9876543210
OTP: 123456
Email: user@example.com (optional)
QR Code: QR001, QR002, QR003
```

**Premium Demo:**
```
Email: premium@carqr.app
→ Auto-sets isPremium=true
```

---

## Notes for Backend Developer

1. **Session IDs**: Use UUID for sessionIds, store in Redis for 5 minutes
2. **OTP Storage**: Store OTP in Redis/Cache with 5-minute expiry
3. **JWT Tokens**: Use HS256, include userId and email in payload
4. **Rate Limiting**: Limit OTP requests to 3 per phone/24 hours
5. **Email Validation**: Format check + optional email verification
6. **Phone Validation**: India format (10 digits), removable country code
7. **CORS**: Allow requests from `https://carqr.app`, `localhost:5000` (dev)
8. **Logging**: Log all auth attempts and payments for audit trail
9. **Security**: Hash passwords, validate all inputs, use HTTPS everywhere
10. **Car QR Value**: Generate deep link: `https://carqr.app/cars/{carId}`
