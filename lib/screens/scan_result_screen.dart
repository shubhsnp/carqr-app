import 'package:flutter/material.dart';
import '../services/mock_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/template_widget.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({super.key});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _showOwnerInfo = false;

  void _showPremiumGateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Premium Feature"),
        content: const Text(
          "Only premium members can view owner information. Upgrade now to unlock this feature!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _upgradeToPremium();
            },
            child: const Text("Upgrade to Premium"),
          ),
        ],
      ),
    );
  }

  Future<void> _upgradeToPremium() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await context.read<UserProvider>().upgradeToPremium();
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() => _showOwnerInfo = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✓ Upgraded to Premium!")),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upgrade failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final qr = ModalRoute.of(context)!.settings.arguments.toString();
    final mock = Provider.of<MockService>(context);
    final data = mock.getCar(qr);
    final userProvider = context.watch<UserProvider>();
    final isPremium = userProvider.isPremium;
    final selectedTemplate = userProvider.currentUser?.selectedTemplate ?? 'modern';

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Result")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "QR Code Scanned",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      qr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_showOwnerInfo || isPremium)
              Column(
                children: [
                  const Text(
                    "Owner Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TemplateWidget(
                    carData: data ?? {},
                    templateId: selectedTemplate,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text("Print"),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/printOptions', arguments: data),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.settings),
                          label: const Text("Template"),
                          onPressed: () => Navigator.pushNamed(context, '/templates'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  const Icon(Icons.lock, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Sign in Required",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your email and phone to verify and view owner information",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: userProvider.currentUser?.email ?? "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: userProvider.currentUser?.phone ?? "Phone",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showPremiumGateDialog,
                      child: const Text("Verify & View Owner Info"),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
