# Car QR - AI Coding Agent Instructions

## Project Overview
**Car QR** is a Flutter mobile application for QR code scanning with a premium subscription model. Users scan car QR codes to access owner information, with different access levels based on premium status.

### Core Feature Flow
1. **User Registration/Login** → Email + Phone validation
2. **QR Scanning** → Manual input or camera scan
3. **Premium Gate** → Non-premium users must upgrade to view owner info
4. **Template Selection** → Choose from Modern/Classic/Minimal card designs
5. **Print Options** → Send to Print or Download as PDF

### Tech Stack
- **Framework**: Flutter 3.x+
- **Language**: Dart 2.17+
- **State Management**: Provider 6.0.5+ (ChangeNotifier for UserProvider)
- **Key Dependencies**: 
  - `provider: ^6.0.5` - State management and service locator
  - `mobile_scanner: ^2.1.0` - QR code scanning (mobile only)

## Architecture & Data Flow

### 1. Authentication & User Management
- **UserProvider** (`lib/providers/user_provider.dart`): Centralized user state
  - Manages login, registration, premium upgrades
  - Tracks premium status with optional expiry date
  - Template selection persistence
- **User Model** (`lib/models/user.dart`): Data structure with copyWith() and JSON serialization
- **Flow**: SplashScreen → LoginScreen/RegisterScreen → HomeScreen

### 2. Navigation Structure (Named Routes in `app.dart`)
```
/ → SplashScreen (checks auth, redirects to login or home)
/login → LoginScreen
/register → RegisterScreen
/home → HomeScreen (main hub)
/scanner → ScannerScreen (manual QR input on web, camera on mobile)
/scanResult → ScanResultScreen (premium gate)
/ownerView → OwnerViewScreen (legacy preview)
/templates → TemplateSelectionScreen
/printOptions → PrintOptionsScreen
```

### 3. Premium Access Model
**Non-Premium User Flow:**
```
Scans QR → ScanResultScreen shows lock icon → 
Must tap "Verify & View Owner Info" → Shows "Premium Feature" dialog → 
Can upgrade or cancel
```

**Premium User Flow:**
```
Scans QR → ScanResultScreen displays owner card directly → 
Can access Print/Template options
```

**Key Code Pattern** (ScanResultScreen):
```dart
// Check premium status and conditionally render UI
if (_showOwnerInfo || isPremium) {
  // Show owner info + print/template options
} else {
  // Show verification form + upgrade button
}
```

### 4. Template System
Three different CardTemplate layouts:
- **Modern**: Gradient background (indigo), emojis, rounded corners
- **Classic**: Bordered layout, label-value pairs
- **Minimal**: Clean, compact design

**Selection Flow**: HomeScreen → TemplateSelectionScreen → Preview with mock data → UserProvider.updateTemplate()

**Usage**: `TemplateWidget(carData: data, templateId: userProvider.currentUser?.selectedTemplate)`

### 5. Service Layer
- **MockService** (`lib/services/mock_service.dart`):
  - Returns mock car data for QR codes
  - Static database of hardcoded car owners (QR001-QR003)
  - **Ready for API integration**: Replace `_carDatabase` with HTTP calls

### 6. State Management Pattern
**Provider Setup** (app.dart):
```dart
MultiProvider(
  providers: [
    Provider(create: (_) => MockService()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
  ],
  child: MaterialApp(...)
)
```

**Accessing State in Widgets:**
```dart
// Read-only (build context)
final userProvider = context.watch<UserProvider>();

// Write (perform action)
await context.read<UserProvider>().upgradeToPremium();
```

## Critical Workflows & Commands

### Development Setup
```bash
flutter pub get
flutter run -d chrome  # Web testing
flutter run -d android # Mobile emulator (if available)
```

### Testing the Premium Flow
1. Start app → Redirects to LoginScreen (no user logged in)
2. Register with any email/phone → Creates free user
3. Click "Scan QR Code" → Enter "QR001" or "QR002"
4. See lock icon → Can't view owner info
5. Click "Verify & View Owner Info" → Upgrade dialog
6. Click "Upgrade to Premium" → User upgraded, shows owner card

### QR Scanner Implementation
- **Web**: Manual text input field (mobile_scanner not supported on web)
- **Mobile**: Camera-based scanning with MobileScanner
- Sample QR values: "QR001", "QR002", "QR003" (mock data available)
- Fallback: Any unknown QR code returns generic mock data

### Template Selection
- User can switch templates anytime from HomeScreen
- Selection is stored in `User.selectedTemplate`
- Mock preview uses hardcoded car data
- In ScanResultScreen, selected template applies to fetched car data

### Analysis & Linting
```bash
flutter analyze
dart fix --apply
```

## Key Files & Data Flows

### File Structure
```
lib/
├── main.dart                  # Entry point
├── app.dart                   # Routes, MultiProvider setup
├── models/
│   └── user.dart             # User data model
├── providers/
│   └── user_provider.dart    # User state management
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── scanner_screen.dart
│   ├── scan_result_screen.dart
│   ├── owner_view_screen.dart (legacy)
│   ├── template_selection_screen.dart
│   └── print_options_screen.dart
├── services/
│   └── mock_service.dart     # Car data (ready for API)
└── widgets/
    └── template_widget.dart  # Multi-template card component
```

### Important Logic Flows

**Login/Registration:**
- EmailValidator in LoginScreen/RegisterScreen
- UserProvider.registerUser/loginUser create User with ID, email, phone
- Non-premium users start with false isPremium flag
- Demo: emails with 'premium' in them auto-activate premium

**Accessing Owner Info:**
1. User scans QR → ScanResultScreen receives QR code as argument
2. MockService.getCar(qr) returns owner data
3. Check userProvider.isPremium:
   - True → Display TemplateWidget with owner data
   - False → Show upgrade dialog, lock UI

**Premium Upgrade:**
- In ScanResultScreen: `_upgradeToPremium()` calls `userProvider.upgradeToPremium()`
- Sets isPremium=true, premiumExpiryDate=now+365 days
- Triggers setState() to rerender with owner info visible

## Project-Specific Patterns

### Const Constructors & Best Practices
- All widgets use `const` constructors where possible
- StatelessWidget for most screens (no local state needed)
- StatefulWidget for ScanResultScreen (manages _showOwnerInfo flag)

### Hardcoded Data Strategy
- **MockService**: Central repository for mock car data
- **TemplateSelectionScreen**: Uses mock data for preview
- **ScanResultScreen**: Displays actual scanned data (if premium)
- **When integrating backend**: Replace MockService.getCar() with API call

### Premium Check Pattern
```dart
bool get isPremium => _currentUser?.isPremiumActive ?? false;
bool get isPremiumActive {
  if (!isPremium) return false;
  if (premiumExpiryDate == null) return true; // Lifetime
  return DateTime.now().isBefore(premiumExpiryDate!);
}
```

### Error Handling
- TRY/CATCH in login/register/upgrade flows
- ShowSnackBar for user feedback
- LoadingDialog during async operations
- Mounted check before setState in async callbacks

## Future Extensions (Design Ready)

### Ready to Implement
1. **PDF Generation** (lib/screens/print_options_screen.dart)
   - Add `pdf: ^3.0.0` dependency
   - Create `lib/services/pdf_service.dart`
   - Generate TemplateWidget as PDF, download on web/save on mobile

2. **Payment Integration** (New: lib/screens/payment_screen.dart)
   - Implement premium upgrade payment flow
   - Mock payment gateway or integrate Stripe/PayPal
   - Create `lib/services/payment_service.dart`

3. **Print Orders** (New: lib/screens/orders_screen.dart)
   - Store order history in MockService or database
   - Track order status (pending, shipped, delivered)

4. **Real Backend** (Update lib/services/mock_service.dart)
   - Replace mock data with HTTP API calls
   - Integrate authentication (JWT tokens)
   - Sync user preferences to server

## Common Development Tasks

### Adding New Screen
1. Create in `lib/screens/new_screen.dart` as StatelessWidget
2. Add route in `app.dart` routes map
3. Navigate: `Navigator.pushNamed(context, "/newRoute", arguments: data)`
4. Receive args: `ModalRoute.of(context)!.settings.arguments as Type`

### Modifying Car Data Structure
1. Update `MockService._carDatabase` with new fields
2. Update `TemplateWidget` to display new fields
3. Update TemplateSelectionScreen mock data

### Updating Premium Logic
1. Edit `UserProvider.isPremiumActive` logic (expiry dates, etc.)
2. Update premium checks in ScanResultScreen
3. Update HomeScreen premium badge

## Conventions & Testing Notes
- **No logging framework**: Errors use debug console + SnackBar
- **State persists during session**: No local storage yet (ready for SharedPreferences integration)
- **Test suite**: Placeholder in test/widget_test.dart (update with actual screen navigation tests)
- **Web Testing**: Use Chrome with sample QR codes (QR001, QR002, QR003)
