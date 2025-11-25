import 'package:flutter/material.dart';
import '../widgets/template_widget.dart';

class OwnerViewScreen extends StatelessWidget {
  const OwnerViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = {
      "ownerName": "Rahul Patil",
      "carNumber": "MH12AB1234",
      "phone": "9876543210"
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Owner Card")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: TemplateWidget(
          carData: data,
          templateId: "template1",
        ),
      ),
    );
  }
}
