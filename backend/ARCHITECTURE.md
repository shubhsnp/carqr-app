# CarQR Backend Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────┐
│                   Flutter Mobile App                    │
│              (CarQR Clean - Dart/Flutter)               │
└──────────────────────┬──────────────────────────────────┘
                       │
                  HTTPS/JSON
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
┌──────────────────┐      ┌──────────────────┐
│   Web Browser    │      │   Mobile App     │
│  (Localhost/CDN) │      │  (Emulator/Real) │
└────────┬─────────┘      └────────┬─────────┘
         │                         │
         └──────────────┬──────────┘
                        │
                  ▼─────▼─────▼
         ┌────────────────────────────┐
         │   Express.js Backend API   │
         │      (Node.js Server)      │
         │  ┌──────────────────────┐  │
         │  │ Authentication       │  │
         │  │ - OTP verification   │  │
         │  │ - JWT tokens         │  │
         │  │ - Session mgmt       │  │
         │  ├──────────────────────┤  │
         │  │ User Management      │  │
         │  │ - Profile            │  │
         │  │ - Premium upgrade    │  │
         │  │ - Preferences        │  │
         │  ├──────────────────────┤  │
         │  │ Car Management       │  │
         │  │ - Car info CRUD      │  │
         │  │ - QR lookup          │  │
         │  │ - Custom fields      │  │
         │  ├──────────────────────┤  │
         │  │ Scanning             │  │
         │  │ - Activity logging   │  │
         │  │ - Lead generation    │  │
         │  ├──────────────────────┤  │
         │  │ QR Generation        │  │
         │  │ - Encode car data    │  │
         │  │ - Size/format opts   │  │
         │  ├──────────────────────┤  │
         │  │ Payments             │  │
         │  │ - Razorpay orders    │  │
         │  │ - Signature verify   │  │
         │  │ - Premium upgrades   │  │
         │  └──────────────────────┘  │
         └────────────────────────────┘
                 │        │        │
        ┌────────┴────┬───┴────┬──┴────────┐
        │             │        │           │
        ▼             ▼        ▼           ▼
   ┌─────────┐  ┌─────────┐ ┌────────┐ ┌──────┐
   │ MySQL   │  │ Redis   │ │AWS S3  │ │Mail  │
   │Database │  │Cache    │ │(QR CDN)│ │SMTP  │
   └─────────┘  └─────────┘ └────────┘ └──────┘
```

---

## Request Flow Examples

### 1. User Registration via OTP

```
Mobile App                          Backend API
    │                                    │
    ├──► POST /auth/otp/request ────────►│
    │    {phone: "9876543210"}            │ Generate OTP
    │                                    │ Store in Redis
    │    ◄────── 200 OK ─────────────────┤
    │    {sessionId: "..."}               │
    │                                    │
    │    [User enters OTP: 123456]        │
    │                                    │
    ├──► POST /auth/otp/verify ─────────►│
    │    {phone, otp, email, sessionId}   │ Verify OTP
    │                                    │ Create User in DB
    │    ◄────── 200 OK ─────────────────┤
    │    {user, token, refreshToken}     │
    │                                    │
    ├── Store token in Provider          │
    └── Navigate to Home                │
```

### 2. Owner Captures Car Info

```
Mobile App                          Backend API
    │                                    │
    ├── POST /cars ────────────────────► │
    │   Headers: {Authorization: token} │
    │   Body: {carNumber, carModel, ...} │ Save to DB
    │                                    │ Update user.hasCarInfo
    │   ◄────── 201 Created ────────────┤
    │   {car: {id, carNumber, ...}}     │
    │                                    │
    └── Update UserProvider             │
       with car info                    │
```

### 3. Scanner Form Gate Flow

```
Mobile App                          Backend API
    │                                    │
    ├──► GET /cars/qr/QR001 ───────────►│
    │                                    │ Lookup car
    │   ◄────── 200 OK ──────────────────┤
    │   {car: {owner, model, ...}}      │
    │                                    │
    │ [Check user.isPremium]             │
    │                                    │
    │ If Basic Plan:                     │
    │   [Show form: phone + email]       │
    │                                    │
    │   ├──► POST /scans ────────────────►│
    │   │    {carId, scannerPhone, ...}  │ Log activity
    │   │                                │
    │   │   ◄────── 201 Created ────────┤
    │   │   {activity: {id, ...}}        │
    │   │                                │
    │   └── Display owner info           │
    │                                    │
    │ If Premium:                        │
    │   └── Show owner info directly     │
```

### 4. Premium Upgrade Flow

```
Mobile App                          Backend API
    │                                    │
    ├──► POST /payments/razorpay/create ►│
    │    Headers: {Authorization: token} │ Create Razorpay
    │    Body: {amount, planDuration}    │ order
    │                                    │
    │   ◄────── 200 OK ──────────────────┤
    │   {orderId, key, ...}              │
    │                                    │
    │ [Open Razorpay SDK]                │
    │ [User enters payment details]      │
    │ [Razorpay returns signature]       │
    │                                    │
    │   ├──► POST /payments/razorpay     │
    │   │    /verify ───────────────────►│
    │   │    {paymentId, orderId, sig}   │ Verify signature
    │   │                                │ Upgrade user
    │   │   ◄────── 200 OK ─────────────┤
    │   │   {user: {isPremium: true}}    │
    │   │                                │
    │   └── Update UI with premium       │
```

---

## Database Schema

```sql
users
├── id (PK)
├── email (UNIQUE)
├── phone (UNIQUE)
├── isPremium
├── plan ('basic' | 'premium')
├── hasCarInfo
├── selectedTemplate
├── premiumExpiryDate
├── createdAt
└── updatedAt

cars (1:1 with users)
├── id (PK)
├── userId (FK) UNIQUE
├── carNumber
├── carModel
├── customMessage
├── customFields (JSON)
├── selectedTemplate
├── createdAt
└── updatedAt

scans (N:1 with cars)
├── id (PK)
├── carId (FK)
├── scannerPhone
├── scannerEmail
├── notes
└── timestamp

qr_codes (N:1 with cars)
├── id (PK)
├── carId (FK)
├── size ('3x3' | '4x4')
├── format ('pdf' | 'svg' | 'png')
├── qrValue
└── createdAt

payments (N:1 with users)
├── id (PK)
├── userId (FK)
├── orderId
├── paymentId
├── amount
├── currency
├── status ('pending' | 'completed' | 'failed')
├── planDuration
├── verifiedAt
└── createdAt
```

---

## Security Implementation

### Authentication
- JWT tokens with 24-hour expiry
- Refresh tokens with 7-day expiry
- OTP stored in Redis (5-minute expiry)
- Session IDs for OTP verification

### API Protection
- `verifyToken` middleware on protected routes
- Role-based access control (future)
- Rate limiting on auth endpoints

### Data Protection
- Passwords hashed with bcryptjs
- Input validation on all endpoints
- SQL injection prevention (parameterized queries)
- CORS enabled for trusted origins

### Payment Security
- Razorpay signature verification
- Secure order creation
- Payment status tracking

---

## Error Handling Strategy

### Standard Error Response
```json
{
  "success": false,
  "error": "User-friendly error message",
  "code": "ERROR_CODE"
}
```

### Error Codes
| Code | HTTP | Meaning |
|------|------|---------|
| INVALID_PHONE | 422 | Invalid phone format |
| INVALID_OTP | 401 | Wrong/expired OTP |
| UNAUTHORIZED | 401 | Missing/invalid token |
| USER_NOT_FOUND | 404 | User doesn't exist |
| CAR_NOT_FOUND | 404 | Car info missing |
| INVALID_SIGNATURE | 400 | Payment verification failed |
| SERVER_ERROR | 500 | Backend error |

---

## Middleware Stack

```
Express App
    │
    ├─► CORS middleware (allow cross-origin)
    │
    ├─► Body parser (JSON)
    │
    ├─► URL encoded parser
    │
    ├─► verifyToken (on protected routes)
    │
    ├─► Controller logic
    │
    └─► Error handler
```

---

## Performance Considerations

1. **Database Indexes**
   - email, phone on users table
   - carId on scans table
   - createdAt for sorting

2. **Connection Pooling**
   - MySQL pool size: 10
   - Max queue: unlimited
   - Prevents connection exhaustion

3. **Redis Caching**
   - OTP storage (5 minutes)
   - Session validation
   - Future: User state cache

4. **Async Operations**
   - Database queries are async/await
   - No blocking operations
   - Proper error handling

---

## Scalability Notes

### Horizontal Scaling
- Stateless design (tokens, not sessions)
- Shared Redis for OTP cache
- Shared MySQL database
- Load balancer friendly

### Future Optimizations
- Database query caching
- CDN for QR code images
- Message queue for email/SMS
- Microservices separation
- API rate limiting

---

## Monitoring & Logging

### Current Implementation
- Console logging for development
- Error logging for debugging
- Request logging available

### Future Enhancement
- Winston/Bunyan for structured logging
- DataDog/New Relic monitoring
- Error tracking (Sentry)
- Performance metrics

---

## Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Runtime | Node.js | 18.x+ |
| Framework | Express.js | 4.18+ |
| Database | MySQL | 8.0+ |
| Cache | Redis | 6.0+ |
| Auth | JWT | jsonwebtoken 9.1+ |
| Payments | Razorpay | 2.9+ |
| QR Codes | qrcode | 1.5+ |
| CORS | cors | 2.8+ |
| Env | dotenv | 16.3+ |

---

## Deployment Architecture

```
┌─────────────────────────────────┐
│     Production Environment      │
├─────────────────────────────────┤
│ Load Balancer / Reverse Proxy   │
│       (Nginx / HAProxy)         │
└────────┬──────────┬─────────────┘
         │          │
    ┌────▼──┐  ┌────▼──┐
    │ Node  │  │ Node   │  Node Servers
    │ App 1 │  │ App 2  │  (Scalable)
    └────┬──┘  └────┬──┘
         │          │
    ┌────▼──────────▼─────┐
    │   MySQL Database    │  Managed DB
    │   (Primary/Replica) │  (AWS RDS)
    └─────────────────────┘
         │
    ┌────▼──────────────────┐
    │  Redis Cache Cluster  │  In-memory Cache
    │  (Master/Sentinel)    │
    └───────────────────────┘
         │
    ┌────▼──────────────────┐
    │  AWS S3 (QR Storage)  │  CDN + Storage
    └───────────────────────┘
```

