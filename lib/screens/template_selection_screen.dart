import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/template_widget.dart';

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  static const List<String> templates = ['modern', 'classic', 'minimal'];
  static const Map<String, String> templateNames = {
    'modern': 'Modern Style',
    'classic': 'Classic Style',
    'minimal': 'Minimal Style',
  };

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final selectedTemplate = userProvider.currentUser?.selectedTemplate ?? 'modern';

    const mockCarData = {
      'ownerName': 'Rahul Patil',
      'carNumber': 'MH12AB1234',
      'phone': '9876543210',
      'email': 'rahul@example.com',
      'carModel': 'Honda City',
      'year': 2022,
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Select Card Template")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose a template for your owner info card",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...templates.map((template) {
              final isSelected = template == selectedTemplate;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      userProvider.updateTemplate(template);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.indigo : Colors.grey,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TemplateWidget(
                              carData: mockCarData,
                              templateId: template,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                              ),
                              child: const Text(
                                "Selected",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text("Confirm Selection"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
