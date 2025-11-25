# Frontend Testing Guide - Step by Step

## Prerequisites
✓ Backend running on `http://localhost:3000`
✓ PostgreSQL connected with `carqr_db` and tables created
✓ Flutter dependencies installed (`flutter pub get` completed)

## Quick Start - Run Frontend

### Terminal 1: Start Backend (if not already running)
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" server.js
```

You should see:
```
✓ Server running on http://localhost:3000
✓ Database pool initialized
✓ Routes registered
```

### Terminal 2: Start Flutter App
```powershell
cd C:\src\car_QR
flutter run -d chrome
```

App will launch on `http://localhost:<port>` in Chrome. Wait 30-60 seconds for compilation.

---

## Full Test Flow with Real Data

### Test 1: Registration Flow (OTP-based)

**Step 1: Start App**
- App opens → should redirect to `SplashScreen` → then `LoginScreen` (if not logged in)
- You should see login buttons for "Register" or "OTP Login"

**Step 2: Click "Register" or "Send OTP"**
- Navigate to registration screen
- Enter **Phone**: `9876543210` (must be 10 digits for Indian format)
- Click "Request OTP"

**Expected Backend Response:**
- Check Terminal 1 (backend logs) - you should see:
```
[DEV] OTP for 9876543210: <6-digit-code>
```
- Copy this OTP code

**Step 3: Enter OTP**
- Frontend shows "Enter OTP" field
- Paste the OTP from backend console (e.g., `123456`)
- Enter email (optional, but recommended): `user@example.com`
- Click "Verify"

**Expected Frontend Result:**
- ✓ User created in PostgreSQL `users` table
- ✓ JWT token received and stored
- ✓ App navigates to `HomeScreen`
- ✓ User sees their profile with phone number

**Step 4: Verify in Database**
Open another terminal and run:
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" -e "
const db = require('./config/database.js');
db.query('SELECT id, email, phone, isPremium FROM users ORDER BY createdAt DESC LIMIT 1')
  .then(res => { console.log('Latest user:', res.rows[0]); process.exit(0); })
  .catch(err => { console.error('Error:', err.message); process.exit(1); });
"
```

Expected output:
```
Latest user: {
  id: 'user_<timestamp>',
  email: 'user@example.com',
  phone: '9876543210',
  isPremium: false
}
```

---

### Test 2: Add Car Information

**Step 1: Navigate to Add Car Screen**
- From `HomeScreen`, click "Add Car Info" or similar button
- OR directly navigate: bottom nav or menu option for "My Car"

**Step 2: Fill Car Details**
```
Car Number:    DL01AB1234
Car Model:     Toyota Fortuner
Custom Message: Well maintained, great condition
Custom Fields: {
  year: 2022,
  color: silver,
  mileage: 45000
}
```

**Step 3: Submit**
- Click "Save Car Info"
- Frontend calls: `ApiService.addCarInfo(...)`
- API makes: `POST /api/v1/cars`

**Expected Frontend Result:**
- ✓ Loading indicator appears briefly
- ✓ Success message or auto-navigate to next screen
- ✓ Car info appears on home screen

**Step 4: Verify in Database**
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" -e "
const db = require('./config/database.js');
db.query('SELECT id, userId, carNumber, carModel, customMessage FROM cars ORDER BY createdAt DESC LIMIT 1')
  .then(res => { console.log('Latest car:', res.rows[0]); process.exit(0); })
  .catch(err => { console.error('Error:', err.message); process.exit(1); });
"
```

Expected output:
```
Latest car: {
  id: 'car_<timestamp>',
  userId: 'user_<timestamp>',
  carNumber: 'DL01AB1234',
  carModel: 'Toyota Fortuner',
  customMessage: 'Well maintained, great condition'
}
```

---

### Test 3: Generate QR Code

**Step 1: Navigate to QR Generation**
- From `HomeScreen`, click "Generate QR" or "Create QR Code"

**Step 2: Choose QR Size & Format**
```
Size:   medium (200x200)
Format: PNG
```

**Step 3: Click "Generate"**
- Frontend calls: `ApiService.generateQr(size: 'medium', format: 'PNG')`
- API makes: `POST /api/v1/qr/generate`

**Expected Frontend Result:**
- ✓ QR code image appears on screen
- ✓ Can see the QR code visually (should be a square barcode)
- ✓ Option to download/share appears

**Step 4: Verify in Database**
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" -e "
const db = require('./config/database.js');
db.query('SELECT id, carId, size, format, qrValue FROM qr_codes ORDER BY createdAt DESC LIMIT 1')
  .then(res => { console.log('Latest QR:', res.rows[0]); process.exit(0); })
  .catch(err => { console.error('Error:', err.message); process.exit(1); });
"
```

Expected output:
```
Latest QR: {
  id: 'qr_<timestamp>',
  carId: 'car_<timestamp>',
  size: 'medium',
  format: 'PNG',
  qrValue: '<encoded-data>'
}
```

---

### Test 4: Scan QR Code (View Owner Info)

**Step 1: Navigate to Scanner**
- Click "Scan QR Code" button on home screen

**Step 2: Enter QR Code**
- On **Web (Chrome)**: Manual text input field (camera not available on web)
- Enter the car ID or QR value: `car_<timestamp>` (from previous test)
- OR use a pre-existing test value: `QR001`

**Step 3: Submit Scan**
- Click "Scan" or "Submit"
- Frontend calls: `ApiService.getCarByQR(qrCode)`
- API makes: `GET /api/v1/cars/qr/{qrCode}`

**Expected Frontend Result:**
- ✓ If **Premium User**: Sees owner card with:
  - Car number, model
  - Custom message
  - Template styling (Modern/Classic/Minimal)
  - Print/Download options
  
- ✓ If **Non-Premium User**: Sees:
  - Lock icon / "Premium Feature" message
  - "Verify & View" button
  - Upgrade to Premium prompt

**Step 5: Verify in Database (Scan Log)**
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" -e "
const db = require('./config/database.js');
db.query('SELECT id, carId, scannerPhone, timestamp FROM scans ORDER BY timestamp DESC LIMIT 1')
  .then(res => { console.log('Latest scan:', res.rows[0]); process.exit(0); })
  .catch(err => { console.error('Error:', err.message); process.exit(1); });
"
```

Expected output:
```
Latest scan: {
  id: 'scan_<timestamp>',
  carId: 'car_<id>',
  scannerPhone: '9876543210',
  timestamp: 2025-11-19T10:30:00Z
}
```

---

### Test 5: Premium Upgrade

**Step 1: Attempt Premium Feature**
- As non-premium user, try to view owner info for a scanned QR
- Should see "Upgrade to Premium" dialog

**Step 2: Click "Upgrade to Premium"**
- Frontend calls: `ApiService.initiatePremiumUpgrade(365)`
- API makes: `POST /api/v1/payments/razorpay/create`

**Expected Response:**
- Razorpay order creation response (with orderId, amount, etc.)
- Frontend may show mock Razorpay modal

**Step 3: Simulate Payment**
- In mock mode: Click "Pay" or similar
- Frontend calls: `ApiService.verifyPayment(orderId, paymentId, signature)`
- API makes: `POST /api/v1/payments/razorpay/verify`

**Expected Frontend Result:**
- ✓ Payment verified
- ✓ User upgraded to premium
- ✓ Can now view all owner info without restrictions
- ✓ Success message displayed

**Step 4: Verify in Database**
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" -e "
const db = require('./config/database.js');
db.query('SELECT id, userId, amount, status, createdAt FROM payments ORDER BY createdAt DESC LIMIT 1')
  .then(res => { console.log('Latest payment:', res.rows[0]); process.exit(0); })
  .catch(err => { console.error('Error:', err.message); process.exit(1); });
"
```

Expected output:
```
Latest payment: {
  id: 'pay_<timestamp>',
  userId: 'user_<id>',
  amount: 299,
  status: 'verified',
  createdAt: 2025-11-19T10:35:00Z
}
```

---

### Test 6: Change Template

**Step 1: Navigate to Templates**
- From HomeScreen, click "Change Template" or "Templates"

**Step 2: Select Different Template**
- Available: Modern, Classic, Minimal
- Click one (e.g., "Classic")

**Step 3: Preview**
- Should show mock car data in selected template style
- Click "Apply" or "Save"

**Step 4: Verify**
- Frontend calls: `ApiService.updateTemplate('classic')`
- API makes: `PUT /api/v1/users/template`

**Expected Database Update:**
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" -e "
const db = require('./config/database.js');
db.query('SELECT id, email, selectedTemplate FROM users ORDER BY createdAt DESC LIMIT 1')
  .then(res => { console.log('User template:', res.rows[0].selectedTemplate); process.exit(0); })
  .catch(err => { console.error('Error:', err.message); process.exit(1); });
"
```

Expected output:
```
User template: classic
```

---

## Troubleshooting

### Issue: "Network error: Failed to connect to http://localhost:3000/api/v1"

**Solution:**
1. Check backend is running:
   ```powershell
   netstat -ano | findstr :3000
   ```
   Should show Node.js process listening on port 3000

2. Restart backend:
   ```powershell
   cd C:\src\car_QR\backend
   & "C:\Program Files\nodejs\node.exe" server.js
   ```

3. Check CORS in `.env`:
   ```
   CORS_ORIGIN=http://localhost:5000,http://localhost
   ```

### Issue: "Unauthorized - Please login again"

**Solution:**
1. Logout and re-login
2. Check JWT_SECRET in `.env` hasn't changed
3. Clear browser cookies: DevTools → Application → Cookies → Delete all

### Issue: "Database error: connection refused"

**Solution:**
1. Check PostgreSQL running:
   ```powershell
   Get-Process postgres -ErrorAction SilentlyContinue
   ```

2. Verify credentials in `backend/.env`:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=Trushal@1234
   DB_NAME=carqr_db
   ```

3. Test connection:
   ```powershell
   cd C:\src\car_QR\backend
   & "C:\Program Files\nodejs\node.exe" test-db.js
   ```

### Issue: "OTP not received" or "OTP showing as invalid"

**Solution:**
1. Backend console should show: `[DEV] OTP for 9876543210: <code>`
2. Use exact code from console (Redis caches it)
3. OTP expires in 5 minutes
4. Make sure `sessionId` matches between request and verify

### Issue: "Flutter compilation errors"

**Solution:**
```powershell
cd C:\src\car_QR
flutter clean
flutter pub get
flutter run -d chrome
```

---

## Real Data Test Scenarios

### Scenario 1: Complete User Journey
```
1. Register with phone: 9876543210
2. Add car: DL01AB1234, Toyota Fortuner
3. Generate QR code
4. Scan own QR (see car info, but locked if not premium)
5. Upgrade to premium
6. Rescan QR (now view all info)
7. Change template to Classic
8. See updated card in new template
```

### Scenario 2: Premium User Features
```
1. Register as premium: email contains "premium"
2. Add car info
3. Generate QR
4. Scan QR → Immediately see full owner info (no lock)
5. Download/print option available
```

### Scenario 3: Multiple Scans
```
1. User A creates car DL01AB1234
2. User B scans DL01AB1234
3. Database logs scan from User B
4. Scan history grows with each scan
```

---

## Console Debugging

### Check Network Requests (Chrome DevTools)
1. Open app in Chrome
2. Press `F12` → Network tab
3. Perform action (e.g., register)
4. See API call:
   - **URL:** `http://localhost:3000/api/v1/auth/otp/request`
   - **Status:** `200` (success) or `400/500` (error)
   - **Response:** JSON with `sessionId`, `expiresIn`, etc.

### Check Backend Logs (Terminal 1)
```
Example successful registration:
POST /api/v1/auth/otp/request 200 - 2.5ms
[DEV] OTP for 9876543210: 287465
POST /api/v1/auth/otp/verify 200 - 8.3ms
User created successfully: user_1234567890
```

### Check Database Changes (Live Query)
```powershell
# Run live query after each action
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" -e "
setInterval(async () => {
  const db = require('./config/database.js');
  const res = await db.query('SELECT COUNT(*) as count FROM users');
  console.log('Total users:', res.rows[0].count);
}, 2000);
" # Updates every 2 seconds
```

---

## Expected Data Flow Summary

```
Flutter UI
    ↓
[User enters: Phone 9876543210]
    ↓
ApiService.requestOtp(phone)
    ↓
Backend: POST /api/v1/auth/otp/request
    ↓
Controller: Generates OTP, stores in Redis, returns sessionId
    ↓
[Backend Console: [DEV] OTP: 287465]
    ↓
[User enters: OTP 287465]
    ↓
ApiService.verifyOtp(phone, otp, sessionId)
    ↓
Backend: POST /api/v1/auth/otp/verify
    ↓
Controller: Validates OTP, creates user in DB, returns JWT
    ↓
[Frontend: User logged in, JWT stored]
    ↓
PostgreSQL: users table has new row
    ↓
HomeScreen displays user profile
```

---

## Summary
- **Total Test Time:** ~5-10 minutes for full flow
- **Test Data:** Phone (any 10 digits), Email (any valid), Car (any model)
- **Success Indicator:** Data appears in PostgreSQL immediately after action
- **Network Monitor:** Chrome DevTools shows all API calls with status codes

**Ready to test!** Start backend, run flutter app, and follow any test scenario above.
