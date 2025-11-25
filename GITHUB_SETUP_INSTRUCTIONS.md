# GitHub Setup Instructions for APK Build

Your Car QR Parking System is now ready to build APK using GitHub Actions!

## What's Been Configured

✅ Environment-based API URLs
✅ Android permissions (camera, storage, internet)
✅ Production build configuration
✅ ProGuard rules for code shrinking
✅ GitHub Actions workflow for APK building
✅ Git repository initialized with all code

## Steps to Get Your APK

### 1. Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository (e.g., `car-qr-parking`)
3. **DO NOT** initialize with README, .gitignore, or license (we already have them)

### 2. Push Code to GitHub

Run these commands in your terminal:

```bash
cd c:\src\car_QR

# Add your GitHub repository as remote (replace YOUR_USERNAME and YOUR_REPO)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push code to GitHub
git push -u origin master
```

### 3. Trigger APK Build

Once pushed, GitHub Actions will automatically build your APK. You can:

- **Automatic**: Just push the code and wait 5-10 minutes
- **Manual**: Go to your repo → Actions tab → "Build Android APK" → Click "Run workflow"

### 4. Download Your APK

1. Go to your GitHub repository
2. Click on **Actions** tab
3. Click on the latest workflow run
4. Scroll down to **Artifacts**
5. Download:
   - `app-release.apk` - Production APK (recommended)
   - `app-debug.apk` - Testing APK

### 5. Install on Android Phone

1. Download the APK to your Android phone
2. Enable "Install from Unknown Sources" in Settings
3. Tap the APK to install
4. Grant camera and storage permissions when prompted

---

## Production Deployment Checklist

Before deploying to production:

### Backend Setup Required

1. **Deploy Backend Server**
   - Deploy `backend/` folder to a cloud server (AWS, DigitalOcean, Heroku)
   - Install Node.js, PostgreSQL, and Redis
   - Set up environment variables (see `backend/.env.example`)
   - Get SSL certificate for HTTPS

2. **Update API URL**
   - Open `lib/services/api_service.dart`
   - Line 12: Replace `https://api.carqr.app/api/v1` with your actual backend URL
   - Example: `https://your-server.com/api/v1`

3. **Rebuild APK**
   ```bash
   # After updating API URL, commit and push
   git add .
   git commit -m "Update production API URL"
   git push
   ```

### Security Requirements

1. **Generate Release Keystore** (for Play Store)
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create key.properties** (DO NOT commit this file)
   ```
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=upload
   storeFile=C:/path/to/upload-keystore.jks
   ```

3. **Update build.gradle.kts** to use the keystore (currently using debug keys)

### Environment Variables

For production build with custom API:

```bash
flutter build apk --release --dart-define=API_ENV=production
```

For staging:
```bash
flutter build apk --release --dart-define=API_ENV=staging
```

---

## Current Configuration

**Package ID**: `com.carqr.parking`
**App Name**: Car QR
**Version**: 1.0.0 (Build 1)
**Min Android**: 5.0 (API 21)
**API URLs**:
- Production: `https://api.carqr.app/api/v1` (UPDATE THIS!)
- Staging: `https://staging-api.carqr.app/api/v1`
- Development: `http://10.0.2.2:3000/api/v1` (Android Emulator)

---

## Important Notes

⚠️ **The current APK will use debug signing** - suitable for testing only
⚠️ **You MUST update the production API URL** before building production APK
⚠️ **Backend must be deployed and running** for the app to work
⚠️ **Never commit .env files or keystores** to GitHub

---

## Troubleshooting

### Build Fails on GitHub
- Check Actions tab for error details
- Most common: dependency version conflicts
- Solution: Update `pubspec.yaml` dependencies

### APK Won't Install
- Enable "Install from Unknown Sources"
- Check if you have enough storage
- Try uninstalling previous version

### App Crashes on Launch
- Check if backend is running and accessible
- Verify API URL in code
- Check Android logs: `adb logcat`

### Network Error in App
- Ensure backend server is running
- Check firewall allows connections
- Verify API URL is HTTPS with valid SSL

---

## Next Steps After APK Build

1. **Test the APK** on physical Android devices
2. **Deploy backend** to production server
3. **Update API URL** to production backend
4. **Generate release keystore** for Play Store
5. **Submit to Google Play Store** for public release

---

## Support

For issues:
- Check GitHub Actions logs for build errors
- Review backend logs for API errors
- Consult Flutter documentation: https://flutter.dev/docs

---

**Generated with Claude Code**
Car QR Parking System v1.0.0
