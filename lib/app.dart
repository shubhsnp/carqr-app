import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/scan_result_screen.dart';
import 'screens/owner_view_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_login_screen.dart';
import 'screens/add_car_info_screen.dart';
import 'screens/template_selection_screen.dart';
import 'screens/print_options_screen.dart';
import 'screens/qr_generation_screen.dart' as qr_screen;
import 'screens/scanner_flow_screen.dart' as scanner_flow;
import 'package:provider/provider.dart';
import 'services/mock_service.dart';
import 'providers/user_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => MockService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Car QR",
        theme: ThemeData(primarySwatch: Colors.indigo),
        initialRoute: "/",
        routes: {
          "/": (_) => const SplashScreen(),
          "/login": (_) => const LoginScreen(),
          "/otpLogin": (_) => const OTPLoginScreen(),
          "/register": (_) => const RegisterScreen(),
          "/home": (_) => const HomeScreen(),
          "/addCarInfo": (_) => const AddCarInfoScreen(),
          "/scanner": (_) => const ScannerScreen(),
          "/scanResult": (_) => const ScanResultScreen(),
          "/scannerFlow": (_) {
            final qrCode = ModalRoute.of(_)?.settings.arguments as String? ?? 'QR001';
            return scanner_flow.ScannerFlowScreen(qrCode: qrCode);
          },
          "/ownerView": (_) => const OwnerViewScreen(),
          "/templates": (_) => const TemplateSelectionScreen(),
          "/printOptions": (_) => const PrintOptionsScreen(),
          "/qrGeneration": (_) => const qr_screen.QRGenerationScreen(),
        },
      ),
    );
  }
}
