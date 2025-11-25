# Car QR - Quick Start Testing Guide

## 🚀 How to Run

```bash
cd c:\src\car_QR
flutter pub get
flutter run -d chrome  # Web testing
# OR
flutter run -d android  # Android emulator (if available)
```

---

## 🧪 Test Account Quick Reference

### Demo Credentials
| Email | Password | Plan | Notes |
|-------|----------|------|-------|
| test@premium.com | - | Premium ✨ | Auto-premium (contains 'premium') |
| test@basic.com | - | Basic | Standard free plan |
| owner@example.com | - | Premium | For owner flow testing |

### OTP Testing
- **Demo OTP Code**: `123456` (hardcoded for testing)
- **Any 10-digit number** works as phone input

---

## 🎯 Quick Test Scripts

### Test 1: Full Owner Flow (5 mins)
```
1. App opens → SplashScreen → LoginScreen
2. Tap "Login with Phone (OTP)"
3. Phone: 9876543210 → Tap "Request OTP"
4. OTP: 123456 → Skip email → "Complete Login"
5. HomeScreen → "Add Car Info"
6. CarNumber: MH01AB1234
   CarModel: Honda City 2022
   Message: "Please don't block my garage"
7. Tap "Save"
8. HomeScreen shows car info
9. Tap "Generate QR"
10. Size: 4×4, Format: PDF
11. Tap "Generate QR Code" → Success dialog
12. Tap "Next: Print Options"
✅ Expected: Print options screen with design options
```

### Test 2: Scanner - Non-Premium Flow (5 mins)
```
1. Tap "Logout" from HomeScreen (if needed)
2. Login: test@basic.com (email login)
3. HomeScreen → "Scan QR Code"
4. Enter: QR001
5. Tap "View Owner Info"
6. 🔒 Lock icon appears with form
7. Phone: 9999999999
   Email: user@example.com
8. Tap "Verify & View Owner Info"
9. ✓ Verified badge + Owner card shown
10. See: "Rahul Patil, MH12AB1234, Honda City 2022"
✅ Expected: Form gate working correctly
```

### Test 3: Scanner - Premium Flow (3 mins)
```
1. Logout → Login: test@premium.com
2. HomeScreen → "Scan QR Code"
3. Sample button: "QR001" (tap directly)
4. ScannerFlowScreen loads
5. ⭐ Premium badge shown (NO FORM)
6. Owner info visible immediately
✅ Expected: No form gate for premium user
```

### Test 4: In-App Upgrade (2 mins)
```
1. Login: test@basic.com
2. HomeScreen → "Upgrade to Premium"
   OR ScannerFlowScreen → "Upgrade Now"
3. Tap button
4. SnackBar: "Upgraded to Premium!"
5. Re-scan same QR → No form gate
✅ Expected: Instant premium status, form bypass
```

### Test 5: Template Selection (2 mins)
```
1. HomeScreen → Car info shown
2. Tap "Choose Template"
3. Three templates shown: Modern, Classic, Minimal
4. Select each and preview
5. Tap "Select" on Modern
6. Return to HomeScreen
✅ Expected: Template selection persists
```

---

## 🎯 Sample QR Codes for Testing

### Pre-Loaded Owners
| QR Code | Owner | Phone | Car Model | Car Number |
|---------|-------|-------|-----------|------------|
| QR001 | Rahul Patil | 9876543210 | Honda City | MH12AB1234 |
| QR002 | Priya Sharma | 8765432109 | Maruti Swift | DL01CD5678 |
| QR003 | Vikram Singh | 7654321098 | Hyundai Creta | KA02EF9012 |

### Unknown QR (Fallback)
- Any other code → Generic owner "John Doe" displayed

---

## 🔍 UI Elements to Verify

### Login Screen
- [ ] Email input field
- [ ] "Login with Email" button
- [ ] "Login with Phone (OTP)" option
- [ ] "Register" link
- [ ] Navigation works

### OTP Screen
- [ ] Phone input field
- [ ] "Request OTP" button
- [ ] OTP input appears after request
- [ ] OTP verification with 123456
- [ ] Email field appears after OTP verified
- [ ] "Complete Login" button

### Home Screen
- [ ] User info card (email, phone, plan badge)
- [ ] "Add Car Info" card (if no car)
- [ ] "Your Car" card (if car exists)
- [ ] "Scan QR Code" button
- [ ] "Upgrade to Premium" card (if basic plan)
- [ ] Logout menu

### Add Car Info Screen
- [ ] CarNumber input (MH01AB1234 format)
- [ ] CarModel input (Honda City 2022)
- [ ] Custom message input (optional)
- [ ] "Add custom field" button works
- [ ] "Save" button creates car
- [ ] Navigation to TemplateSelectionScreen

### QR Generation Screen
- [ ] Size radio buttons (3×3, 4×4)
- [ ] Format radio buttons (PDF, SVG)
- [ ] Preview shows QR icon
- [ ] "Generate QR Code" button → Dialog
- [ ] Dialog shows generated QR with settings
- [ ] "Next: Print Options" button

### Scanner Screen
- [ ] QR input field
- [ ] "View Owner Info" button (enables only with input)
- [ ] Sample QR buttons (QR001, QR002, QR003)
- [ ] Clear button works
- [ ] Sample buttons navigate to ScannerFlowScreen

### Scanner Flow Screen
- [ ] QR code display at top
- [ ] BASIC PLAN: Lock icon + verification form
  - [ ] Phone input field
  - [ ] Email input field
  - [ ] "Verify & View Owner Info" button
  - [ ] Upgrade button + CTA
- [ ] PREMIUM PLAN: Amber premium badge + direct info
- [ ] Owner info card with details:
  - [ ] Name, Phone, Email
  - [ ] Model, Year, Car Number
- [ ] "Print Options" button
- [ ] "Back to Scan" button

---

## ⚙️ Feature Verification Checklist

### Authentication
- [ ] Email login works
- [ ] OTP login works (123456)
- [ ] Registration creates users
- [ ] User state persists after login
- [ ] Logout clears user state

### Owner Flow
- [ ] Can add car info with mandatory fields
- [ ] Custom fields can be added/removed
- [ ] Car info displays on HomeScreen
- [ ] Can edit car info
- [ ] Template selection works
- [ ] QR generation with size/format options

### Scanner Flow
- [ ] QR input with sample buttons
- [ ] Non-premium sees form gate
- [ ] Premium sees direct access
- [ ] Form submission records activity
- [ ] Upgrade from form gate works

### Premium Model
- [ ] Non-premium users default to "Basic" plan
- [ ] Premium badge shows correctly
- [ ] Premium users skip form gate
- [ ] Instant upgrade works
- [ ] Premium expiry set to 365 days
- [ ] Demo: emails with 'premium' auto-activate

### Navigation
- [ ] All 14 routes functional
- [ ] Back buttons work
- [ ] Arguments pass correctly between screens
- [ ] No blank screens or crashes

---

## 🐛 Common Issues & Solutions

### Issue: "OTP not working"
**Solution**: OTP demo code is hardcoded to `123456`. Any other code will fail.

### Issue: "Can't see owner info after scan"
**Solution**: Check if user is premium or basic:
- Basic: Must fill form first
- Premium: Direct access

### Issue: "Screen goes blank"
**Solution**: Check LogCat for errors. Likely navigation argument mismatch.

### Issue: "Car info not showing after save"
**Solution**: Navigate back to HomeScreen to see updated UI.

---

## 📊 Expected Behavior by User Type

### Non-Premium User Flow
```
LoginScreen → HomeScreen (Basic badge)
→ Add car info (optional)
→ Scan QR → Form gate → Fill phone+email → View info
→ Can upgrade anytime
```

### Premium User Flow
```
LoginScreen → HomeScreen (Premium badge)
→ Add car info (optional)
→ Scan QR → Direct info (no form)
→ No upgrade needed
```

---

## 🔒 Known Limitations (Demo Version)

- ❌ OTP actually sends SMS (hardcoded to 123456)
- ❌ No PDF generation (placeholder only)
- ❌ No QR generation (mock display)
- ❌ No payment processing (mock upgrade)
- ❌ No database persistence (session only)
- ❌ No email sending
- ❌ No camera scanning (manual input only on web)

✅ All above ready for integration in next phases

---

## 📱 Device Testing Notes

### Web (Chrome)
- ✅ Full functionality
- ✅ Use manual QR input (camera unavailable)
- ✅ Sample buttons for quick testing

### Android/iOS
- ✅ Mobile Scanner library ready for camera integration
- ✅ Manual input still works as fallback
- ✅ OTP input keyboard respects type

---

## 💾 Useful Flutter Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Run with debug logging
flutter run -v

# Format code
dart format lib/

# Analyze code
flutter analyze

# Generate build files
flutter pub run build_runner build

# Run tests
flutter test
```

---

## 📞 Debugging Tips

### Check State
- Open DevTools: `flutter run -d chrome --profile` then DevTools button
- Watch UserProvider changes via Provider DevTools extension

### Common Errors
- **"No user found"**: Login first or check currentUser in UserProvider
- **"Route not found"**: Verify route name in app.dart matches navigation call
- **"Widget build error"**: Check context.watch/read usage is correct

### Print Debugging
```dart
print("UserProvider: ${context.read<UserProvider>().currentUser}");
print("Car Info: ${context.read<UserProvider>().currentCar}");
```

---

## ✅ Sign-Off Criteria

**App is ready for launch when:**
1. ✅ All test scripts execute without errors
2. ✅ All UI elements render correctly
3. ✅ Navigation between all 14 screens works
4. ✅ Premium vs Basic flows differentiate correctly
5. ✅ Form gate appears for non-premium users
6. ✅ Instant upgrade functionality works
7. ✅ No console errors or warnings
8. ✅ Responsive design works on mobile

---

**Last Updated**: Session completion
**Status**: Ready for UAT (User Acceptance Testing)
