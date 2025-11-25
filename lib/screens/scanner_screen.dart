import 'package:flutter/material.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _qrController = TextEditingController();
  final List<String> _sampleCodes = [
    "QR001",
    "QR002",
    "QR003",
  ];

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.qr_code_scanner,
              size: 64,
              color: Colors.indigo,
            ),
            const SizedBox(height: 24),
            const Text(
              "Scan a Car QR Code",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter the QR code or scan using your camera",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _qrController,
              decoration: InputDecoration(
                hintText: "Enter QR code (e.g., QR001)",
                prefixIcon: const Icon(Icons.qr_code),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _qrController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _qrController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text("View Owner Info"),
                onPressed: _qrController.text.isEmpty
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          "/scannerFlow",
                          arguments: _qrController.text,
                        );
                      },
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              "Try a Sample QR Code",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _sampleCodes
                  .map((code) => ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/scannerFlow",
                            arguments: code,
                          );
                        },
                        icon: const Icon(Icons.qr_code_2, size: 18),
                        label: Text(code),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

