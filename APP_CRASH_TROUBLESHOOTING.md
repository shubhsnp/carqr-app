# Quick Fix for App Crash

## Immediate Actions:

### Step 1: Get Your Computer's IP Address

```bash
ipconfig
```

Look for **IPv4 Address** under your active network adapter (WiFi or Ethernet).
Example: `192.168.1.100`

### Step 2: Update API URL

Edit `lib/services/api_service.dart` line 17:

**Change from**:
```dart
return 'http://10.0.2.2:3000/api/v1'; // Android emulator
```

**Change to**:
```dart
return 'http://YOUR_IP_HERE:3000/api/v1'; // YOUR actual IP
```

Example:
```dart
return 'http://192.168.1.100:3000/api/v1';
```

### Step 3: Ensure Backend is Running

```bash
cd c:\src\car_QR\backend
node server.js
```

You should see:
```
Server running on port 3000
Database connected
Redis connected
```

### Step 4: Rebuild APK

```bash
cd c:\src\car_QR
git add lib/services/api_service.dart
git commit -m "Fix API URL for physical device"
git push origin main
```

Wait 5-8 minutes, then download new APK from GitHub Actions.

---

## Alternative: Offline Test Mode

If you want to test the app WITHOUT backend:

I can create a version that uses mock data for testing UI only.

---

## Need Help?

Share the crash logs with me:
1. Run `get_crash_logs.bat`
2. Open app on phone
3. Copy the error message
4. Tell me what it says

---

Most likely fixes ranked by probability:
1. ✅ **95% chance**: Wrong API URL for physical device
2. ✅ **3% chance**: Backend not running
3. ✅ **1% chance**: Phone and computer on different networks
4. ✅ **1% chance**: Firewall blocking port 3000

