# Quick Reference - Frontend Testing

## Start Everything

**Terminal 1:**
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" server.js
```

**Terminal 2:**
```powershell
cd C:\src\car_QR
flutter run -d chrome
```

## Test Data

| Field | Value | Notes |
|-------|-------|-------|
| Phone | `9876543210` | Must be 10 digits |
| Email | `user@example.com` | Optional, auto-generated if empty |
| Car Number | `DL01AB1234` | Any format |
| Car Model | `Toyota Fortuner` | Any format |
| QR Size | `medium` | small, medium, large |
| QR Format | `PNG` | PNG or other formats |

## Real Data Test Flow

### 1️⃣ Register (5 min)
```
App → Register → Enter Phone: 9876543210
↓
Backend Console: [DEV] OTP for 9876543210: <code>
↓
App → Enter OTP from console
↓
✓ User created in DB, JWT token received
```

### 2️⃣ Add Car (2 min)
```
Home → Add Car → Fill details → Save
↓
API: POST /api/v1/cars
↓
✓ Car saved to carqr_db.cars table
```

### 3️⃣ Generate QR (2 min)
```
Home → Generate QR → Choose size/format → Generate
↓
API: POST /api/v1/qr/generate
↓
✓ QR created in carqr_db.qr_codes table
```

### 4️⃣ Scan QR (2 min)
```
Home → Scan QR → Enter car ID or QR value
↓
API: GET /api/v1/cars/qr/{id}
↓
✓ Owner info displayed (if premium) or locked (if not)
```

### 5️⃣ Upgrade Premium (3 min)
```
Non-premium user → Tries to view owner info → Sees upgrade button
↓
Click "Upgrade" → Razorpay modal → Simulated payment
↓
API: POST /api/v1/payments/razorpay/create + verify
↓
✓ User upgraded, can now view all owner info
```

**Total Time: ~15 minutes for complete flow**

## Verify Data in DB

### After Registration
```powershell
cd C:\src\car_QR\backend
& "C:\Program Files\nodejs\node.exe" -e "const db = require('./config/database.js'); db.query('SELECT id, phone, isPremium FROM users ORDER BY createdAt DESC LIMIT 1').then(r => { console.log(r.rows[0]); process.exit(0); });"
```

### After Adding Car
```powershell
& "C:\Program Files\nodejs\node.exe" -e "const db = require('./config/database.js'); db.query('SELECT id, carNumber, carModel FROM cars ORDER BY createdAt DESC LIMIT 1').then(r => { console.log(r.rows[0]); process.exit(0); });"
```

### After Generating QR
```powershell
& "C:\Program Files\nodejs\node.exe" -e "const db = require('./config/database.js'); db.query('SELECT id, size, format FROM qr_codes ORDER BY createdAt DESC LIMIT 1').then(r => { console.log(r.rows[0]); process.exit(0); });"
```

### After Payment
```powershell
& "C:\Program Files\nodejs\node.exe" -e "const db = require('./config/database.js'); db.query('SELECT id, amount, status FROM payments ORDER BY createdAt DESC LIMIT 1').then(r => { console.log(r.rows[0]); process.exit(0); });"
```

## Troubleshoot

| Issue | Check |
|-------|-------|
| Network error | Backend running on port 3000 |
| Unauthorized | Clear cookies, re-login |
| DB error | PostgreSQL running, .env correct |
| OTP invalid | Copy exact code from backend console |
| Compilation error | `flutter clean` → `flutter pub get` |

## Chrome DevTools

1. Press `F12` in Chrome
2. Go to **Network** tab
3. Perform action (e.g., register)
4. See API calls:
   - `POST /api/v1/auth/otp/request` → Status 200 ✓
   - `POST /api/v1/auth/otp/verify` → Status 200 ✓
   - Response shows user data + JWT token

## Success Indicators

✅ Frontend
- No error messages
- Smooth navigation between screens
- Data persists after refresh

✅ Backend Console
- `[DEV] OTP for <phone>: <code>` logs
- `200 OK` status codes
- No red error messages

✅ Database
- `users` table grows with each registration
- `cars` table has entries after adding car
- `qr_codes` table has generated QRs
- `payments` table logs all transactions

---

**Everything integrated and ready to test!** 🚀
