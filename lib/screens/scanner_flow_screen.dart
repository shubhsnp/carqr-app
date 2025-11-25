import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scan_activity.dart';
import '../providers/user_provider.dart';
import '../services/mock_service.dart';

class ScannerFlowScreen extends StatefulWidget {
  final String qrCode;

  const ScannerFlowScreen({
    super.key,
    required this.qrCode,
  });

  @override
  State<ScannerFlowScreen> createState() => _ScannerFlowScreenState();
}

class _ScannerFlowScreenState extends State<ScannerFlowScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _showOwnerInfo = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitFormAndView() async {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (phone.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Mock: Record scan activity
    final activity = ScanActivity(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      carId: widget.qrCode,
      scannerPhone: phone,
      scannerEmail: email,
      timestamp: DateTime.now(),
      notes: 'Scanned via basic plan form',
    );

    // In a real app, you'd save this to backend
    print('Scan Activity: ${activity.toJson()}');

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _showOwnerInfo = true;
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted! Viewing owner info...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final isPremium = user?.isPremiumActive ?? false;

    // Get car data synchronously
    final mockService = context.read<MockService>();
    final carData = mockService.getCar(widget.qrCode) ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.qrCode,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Premium vs Non-Premium UI
            if (!isPremium && !_showOwnerInfo)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lock Icon + Title
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Owner Information Locked',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Basic plan requires verification',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Gate
                  const Text(
                    'Please verify your information to view owner details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitFormAndView,
                      icon: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.visibility),
                      label: const Text('Verify & View Owner Info'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Upgrade CTA
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '✨ Upgrade to Premium',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'See all owner info instantly, no form needed',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () async {
                              await userProvider.upgradeToPremium();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Upgraded! Refreshing view...'),
                                  ),
                                );
                                // Rebuild to show premium view
                                setState(() => _showOwnerInfo = true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('Upgrade Now'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              // Owner Info Display (Premium or after form submission)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPremium
                            ? Colors.amber
                            : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPremium
                            ? '⭐ Premium - No Gating'
                            : '✓ Verified',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Owner Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Owner Information',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Name',
                            carData['ownerName'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Phone',
                            carData['phone'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Email',
                            carData['email'] ?? 'N/A',
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'Vehicle Information',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Model',
                            carData['carModel'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Year',
                            (carData['year'] ?? 'N/A').toString(),
                          ),
                          _buildInfoRow(
                            'Car Number',
                            carData['carNumber'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/printOptions'),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Options'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Scan'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
