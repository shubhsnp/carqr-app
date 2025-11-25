import 'package:flutter/material.dart';

class PrintOptionsScreen extends StatelessWidget {
  const PrintOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Print Options")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "How would you like to proceed?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Send to Print Option
            Card(
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: const Icon(Icons.local_shipping, size: 40, color: Colors.indigo),
                title: const Text(
                  "Send to Print",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "We'll print and deliver to you",
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  // For now, show a confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Print order feature coming soon")),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Print at Home Option
            Card(
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: const Icon(Icons.print, size: 40, color: Colors.green),
                title: const Text(
                  "Print at Home",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "Download as PDF and print yourself",
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PDF download feature coming soon")),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
