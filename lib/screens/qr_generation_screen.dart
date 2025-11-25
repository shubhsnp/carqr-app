import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class QRGenerationScreen extends StatefulWidget {
  const QRGenerationScreen({super.key});

  @override
  State<QRGenerationScreen> createState() => _QRGenerationScreenState();
}

class _QRGenerationScreenState extends State<QRGenerationScreen> {
  String _selectedSize = '3x3'; // 3x3 inch or 4x4 inch
  String _selectedFormat = 'pdf'; // pdf or svg

  void _generateQR() {
    final userProvider = context.read<UserProvider>();
    final car = userProvider.currentCar;

    if (car == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No car info found. Please add car info first.')),
      );
      return;
    }

    // Mock QR generation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Generated!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Size: $_selectedSize inches',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Format: ${_selectedFormat.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Vehicle: ${car.carModel} (${car.carNumber})'),
            const SizedBox(height: 8),
            Text('Template: ${car.selectedTemplate}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 100, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready to print! You can:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Send to print service'),
            const Text('• Download and print at home'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/printOptions', arguments: {
                'size': _selectedSize,
                'format': _selectedFormat,
              });
            },
            child: const Text('Next: Print Options'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final car = userProvider.currentCar;

    if (car == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Generate QR')),
        body: const Center(
          child: Text('No car info found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Info Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Car',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${car.carModel} • ${car.carNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (car.customMessage.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(car.customMessage),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Size Selection
            const Text(
              'Sticker Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('3×3 inches (Compact)'),
                  subtitle: const Text('Good for small surfaces'),
                  value: '3x3',
                  groupValue: _selectedSize,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSize = value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('4×4 inches (Standard)'),
                  subtitle: const Text('Most popular size'),
                  value: '4x4',
                  groupValue: _selectedSize,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSize = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Format Selection
            const Text(
              'Export Format',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('PDF (Recommended)'),
                  subtitle: const Text('High-quality, print-ready format'),
                  value: 'pdf',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFormat = value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('SVG (Vector)'),
                  subtitle: const Text('Scalable vector graphics'),
                  value: 'svg',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFormat = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Template Preview
            const Text(
              'Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_2,
                    size: 120,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    car.carNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    car.carModel,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _generateQR,
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate QR Code'),
              ),
            ),
            const SizedBox(height: 12),

            // Back Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
