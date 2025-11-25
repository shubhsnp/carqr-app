# Frontend-Backend Integration Guide

## Overview
The Flutter frontend has been integrated with the Node.js/PostgreSQL backend API. All user authentication, car data, QR operations, and payments now connect to real backend endpoints.

## Setup Steps

### 1. Install Dependencies
Update `pubspec.yaml` dependencies have been added:
- `http: ^1.1.0` — for API calls
- `mobile_scanner: ^2.1.0` — for QR scanning
- `provider: ^6.0.5` — state management (already had)

Run:
```bash
flutter pub get
```

### 2. API Service Layer
**New file:** `lib/services/api_service.dart`
- Central API service with all backend endpoints
- Handles authentication tokens (Bearer tokens)
- Error handling and network timeouts
- Base URL: `http://localhost:3000/api`

### 3. Updated User Provider
**Updated file:** `lib/providers/user_provider.dart`
- `registerUser()` — calls `/auth/register` endpoint
- `loginUser()` — calls `/auth/login` endpoint
- `upgradeToPremium()` — calls `/payments/create-order` endpoint
- `updateCarInfo()` — calls `/cars` POST/PUT endpoints
- `updateTemplate()` — calls `/users/template` endpoint
- All methods now call real APIs with error handling

### 4. API Endpoints Available

#### Auth
- `POST /api/auth/register` — Register new user
- `POST /api/auth/login` — Login user
- `POST /api/auth/send-otp` — Send OTP to phone
- `POST /api/auth/verify-otp` — Verify OTP and login

#### Cars
- `POST /api/cars` — Add car info
- `GET /api/cars/me` — Get user's car info
- `PUT /api/cars` — Update car info

#### QR
- `POST /api/qr/scan` — Scan QR code
- `POST /api/qr/generate` — Generate QR code

#### Payments
- `POST /api/payments/create-order` — Create premium upgrade order
- `POST /api/payments/verify` — Verify payment after Razorpay callback

#### Users
- `GET /api/users/me` — Get current user profile
- `PUT /api/users/template` — Update selected template

## Running the App

### 1. Start Backend API
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" server.js
# OR (if node is on PATH)
node server.js
```
API runs on `http://localhost:3000`

### 2. Start Flutter App
```bash
cd C:\src\car_QR
flutter pub get
flutter run -d chrome  # Web (fastest for testing)
# OR
flutter run -d android  # Android emulator
```

## Authentication Flow

1. **Register/Login**
   - User enters email/phone
   - Frontend calls `ApiService.register()` or `ApiService.login()`
   - Backend verifies and returns JWT token
   - `ApiService.authToken` stored in memory
   - All subsequent requests include `Authorization: Bearer <token>` header

2. **Token Persistence** (Optional - for production)
   - Consider adding `flutter_secure_storage` or `shared_preferences`
   - Store token in device storage for session persistence
   - Restore token on app startup

## Key Changes from Mock to Real API

| Feature | Before (Mock) | After (Real) |
|---------|---------------|------------|
| User Registration | Local in-memory | `POST /api/auth/register` |
| Login | Mock with 'premium' in email | Real email validation, JWT token |
| Premium Upgrade | Instant mock | Razorpay payment integration |
| Car Info | Local state | PostgreSQL `cars` table |
| QR Scanning | Mock data for QR001-003 | Real database lookup |
| Templates | Local only | Synced via `/api/users/template` |

## Error Handling

All API calls wrap responses in try-catch. Error messages are stored in `UserProvider._errorMessage` and can be displayed:

```dart
// In widgets
final userProvider = context.watch<UserProvider>();
if (userProvider.errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(userProvider.errorMessage!))
  );
}
```

## Testing Workflow

### 1. Test Registration
```
1. Open app → navigate to RegisterScreen
2. Enter: email = "test@example.com", phone = "9876543210"
3. Backend validates, creates user in DB, returns JWT
4. App navigates to HomeScreen (logged in)
```

### 2. Test Login
```
1. Logout → navigate to LoginScreen
2. Enter email from previous registration
3. Backend validates, returns JWT
4. App shows user dashboard
```

### 3. Test QR Scanning
```
1. Logged in → Click "Scan QR Code"
2. Enter any car ID or QR value
3. Backend queries `cars` table
4. If non-premium → show upgrade dialog
5. If premium → show car info card
```

### 4. Test Premium Upgrade
```
1. Non-premium user → Tries to view owner info
2. Click "Upgrade to Premium" → calls /api/payments/create-order
3. Mock Razorpay response → calls /api/payments/verify
4. Backend updates user.isPremium = true
5. User can now view owner info
```

## Common Issues & Solutions

### Issue: "Network error: Failed to connect to http://localhost:3000"
**Solution:** 
- Ensure backend server is running on port 3000
- Run: `node server.js` in backend directory
- Check firewall isn't blocking localhost:3000

### Issue: "Unauthorized - Please login again"
**Solution:**
- Token might have expired or is invalid
- Re-login to get a fresh token
- Check JWT_SECRET in `.env` matches across requests

### Issue: "Database connection error"
**Solution:**
- Verify PostgreSQL is running
- Verify `.env` DB credentials are correct
- Run: `node test-db.js` to confirm connection

### Issue: "CORS error"
**Solution:**
- Backend CORS_ORIGIN in `.env` should include app URL
- For development: `http://localhost:5000,http://localhost` etc.
- Update `.env` and restart backend

## Next Steps

1. **Add Session Persistence** — Store JWT in secure storage across app restarts
2. **Implement Redis** — For OTP caching (optional, but recommended)
3. **Add Real Razorpay Integration** — Connect payment verification flow
4. **AWS S3 for QR Images** — Store generated QRs in cloud
5. **Email/SMS Notifications** — Send confirmation emails and SMS alerts

## File Locations

- API Service: `lib/services/api_service.dart`
- User Provider: `lib/providers/user_provider.dart`
- Backend API: `backend/server.js`
- Routes: `backend/routes/` (auth, cars, qr, payments, users)
- Database Config: `backend/config/database.js`
- Environment: `backend/.env`

## Support
If you hit issues:
1. Check backend logs: `node server.js` output
2. Check frontend console: `flutter run` output
3. Test API directly: `curl http://localhost:3000/api/users/me` (with Authorization header)
4. Verify database: `node test-db.js` in backend
