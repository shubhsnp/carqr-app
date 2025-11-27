# APK Build Status & Instructions

## 🔥 Latest Changes (Just Pushed)

**Commit**: Simplify build config - remove all ProGuard references
**Time**: Just now
**Status**: Building on GitHub Actions

### What Was Fixed:
1. ✅ Removed ProGuard file references (was causing R8 to run)
2. ✅ Kept minification completely disabled
3. ✅ Simplified workflow to use standard `flutter build apk --release`
4. ✅ Removed deprecated `android.enableR8` options

---

## 📦 Where to Get Your APK

### Step 1: Check Build Status
Go to: **https://github.com/shubhsnp/carqr-app/actions**

You should see a workflow run starting (triggered by the latest push).

### Step 2: Wait for Build (5-8 minutes)
The workflow will show:
- ✓ Checkout code
- ✓ Setup Java 17
- ✓ Setup Flutter 3.38.1
- ✓ Get dependencies
- ✓ Clean build cache
- ✓ Build APK (Release) ← **This is where it should succeed now**
- ✓ Upload Release APK

### Step 3: Download APK
Once the build completes successfully:
1. Click on the completed workflow run
2. Scroll down to **Artifacts** section
3. Click **CarQR-v1.0.0** to download
4. Extract the ZIP file
5. Inside you'll find `app-release.apk`

---

## 📱 Install on Android Phone

### Option A: USB Transfer
```bash
# Connect phone via USB
adb install app-release.apk
```

### Option B: Direct Download
1. Upload APK to Google Drive / Dropbox / WeTransfer
2. Download on your Android phone
3. Enable "Install from Unknown Sources" in Settings
4. Tap the APK file to install

### Option C: Cloud Storage
1. Share APK via WhatsApp / Telegram
2. Download on phone
3. Install

---

## 🔍 If Build Still Fails

If you see R8 errors again, we have one more nuclear option:

### Nuclear Option: Use Debug Build (No R8 at All)

Update `.github/workflows/build-apk.yml` line 37 to:
```yaml
- name: Build APK (Debug - No R8)
  run: flutter build apk --debug
```

Debug builds:
- ❌ Larger file size (~40MB vs ~20MB)
- ❌ Slower performance
- ✅ NO R8 at all
- ✅ Will definitely work
- ✅ Fine for testing purposes

---

## 🎯 Alternative: Build Locally with Docker

If GitHub Actions keeps failing, we can build locally using Docker (no Android Studio needed):

```bash
# Pull Flutter Docker image
docker pull cirrusci/flutter:stable

# Build APK in container
docker run --rm -v c:\src\car_QR:/project -w /project cirrusci/flutter:stable flutter build apk --release

# APK will be at: c:\src\car_QR\build\app\outputs\flutter-apk\app-release.apk
```

This requires Docker Desktop for Windows.

---

## 📊 Build Configuration Summary

```
App Name: Car QR
Package: com.carqr.parking
Version: 1.0.0 (Build 1)
Min Android: 5.0 (API 21)

Build Settings:
- Minification: DISABLED
- Shrink Resources: DISABLED
- R8: Should not run
- ProGuard: Removed
- Signing: Debug keystore

Dependencies:
- Flutter SDK: 3.38.1
- Dart SDK: 3.10.0
- provider: ^6.0.5
- http: ^1.1.0
- Play Core: 1.10.3 (dependency)
```

---

## ✅ Verification Steps

Once you get the APK:

### 1. Check File Size
```bash
ls -lh app-release.apk
# Expected: 15-30 MB
```

### 2. Verify APK Info
```bash
# If you have aapt installed
aapt dump badging app-release.apk | grep package
# Should show: package: name='com.carqr.parking' versionCode='1' versionName='1.0.0'
```

### 3. Test Install
```bash
# Connect Android device
adb install app-release.apk
# Should say: Success
```

---

## 🐛 Troubleshooting Build Errors

### Error: "R8 missing classes"
**Solution**: Already fixed by removing ProGuard references

### Error: "android.enableR8 is deprecated"
**Solution**: Already removed from gradle.properties

### Error: "assets/images/ not found"
**Solution**: Already commented out in pubspec.yaml

### Error: Build timeout
**Solution**: Increase timeout in workflow or use debug build

### Error: Out of memory
**Solution**: Already set to 8GB in gradle.properties

---

## 🚀 What Happens After You Get APK

1. **Install on phone**
2. **Grant permissions** (Camera, Storage, Internet)
3. **Test login** with phone number
4. **Check backend console** for OTP (or ask me!)
5. **Add car information**
6. **Test QR scanning** (when camera is implemented)

---

## 📞 Backend Connection

The APK will connect to:

**Development Mode** (default):
```
http://10.0.2.2:3000/api/v1
```
This works for Android Emulator pointing to localhost.

**For Real Phone**:
You need to either:
1. Deploy backend to cloud server
2. Use your computer's local IP (if on same WiFi)
3. Use ngrok to expose localhost

### Using ngrok (Quick Testing):
```bash
# In backend directory
ngrok http 3000

# Copy the https URL, update lib/services/api_service.dart line 17
# Rebuild APK
```

---

## 🎉 Success Indicators

You'll know everything worked when:
- ✅ GitHub Actions shows green checkmark
- ✅ Artifact download available
- ✅ APK file is 15-30 MB
- ✅ APK installs on Android phone
- ✅ App launches without crash
- ✅ Can enter phone number and request OTP

---

## 📝 Next Steps After Successful Install

1. **Test authentication flow**
2. **Add car information**
3. **Test all screens**
4. **Report any bugs**
5. **Plan production deployment**

---

**Current Status**: Building on GitHub Actions
**Check**: https://github.com/shubhsnp/carqr-app/actions

**Estimated completion**: 5-8 minutes from now

---

Generated by Claude Code
Last Updated: Just now
