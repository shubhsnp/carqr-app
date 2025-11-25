import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String _sessionId = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await context.read<UserProvider>().requestOtp(phone);
      setState(() {
        _otpSent = true;
        _sessionId = response['sessionId'];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent! Check backend console for OTP')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleVerifyOTP() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    final email = _emailController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<UserProvider>().verifyOtpAndLogin(phone, otp, _sessionId, email);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _otpSent = false;
      _phoneController.clear();
      _otpController.clear();
      _emailController.clear();
      _sessionId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with OTP")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Car QR",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const Text(
              "QR Scanner for Car Owners",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 60),
            // Phone input
            TextField(
              controller: _phoneController,
              enabled: !_otpSent,
              decoration: InputDecoration(
                hintText: 'Enter your 10-digit phone',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            // OTP input (visible only after OTP is sent)
            if (_otpSent) ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit OTP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.security),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Action button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_otpSent ? _handleVerifyOTP : _handleRequestOTP),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_otpSent ? "Verify OTP & Login" : "Send OTP"),
              ),
            ),
            // Reset button
            if (_otpSent) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(onPressed: _isLoading ? null : _resetForm, child: const Text("Start Over")),
              ),
            ],
            const SizedBox(height: 24),
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Test Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('1. Enter any 10-digit phone'),
                  Text('2. Click "Send OTP"'),
                  Text('3. Check backend console for OTP'),
                  Text('4. Enter OTP & click "Verify"'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
