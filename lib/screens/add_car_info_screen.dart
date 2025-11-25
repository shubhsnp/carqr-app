import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/car_info.dart';

class AddCarInfoScreen extends StatefulWidget {
  const AddCarInfoScreen({super.key});

  @override
  State<AddCarInfoScreen> createState() => _AddCarInfoScreenState();
}

class _AddCarInfoScreenState extends State<AddCarInfoScreen> {
  final _carNumberController = TextEditingController();
  final _carModelController = TextEditingController();
  final _customMessageController = TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>> _customFields = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _carNumberController.dispose();
    _carModelController.dispose();
    _customMessageController.dispose();
    for (var entry in _customFields) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }

  void _addCustomField() {
    setState(() {
      _customFields.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeCustomField(int index) {
    _customFields[index].key.dispose();
    _customFields[index].value.dispose();
    setState(() {
      _customFields.removeAt(index);
    });
  }

  Future<void> _saveCar() async {
    final carNumber = _carNumberController.text.trim();
    final carModel = _carModelController.text.trim();
    final customMessage = _customMessageController.text.trim();

    if (carNumber.isEmpty || carModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car number and model are mandatory')),
      );
      return;
    }

    // Collect custom fields
    final customFields = <String, String>{};
    for (var entry in _customFields) {
      final key = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        customFields[key] = value;
      }
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.currentUser!;

      // Create CarInfo object
      final carInfo = CarInfo(
        id: 'car_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        carNumber: carNumber,
        carModel: carModel,
        customMessage: customMessage,
        customFields: customFields,
        selectedTemplate: user.selectedTemplate ?? 'modern',
        createdAt: DateTime.now(),
      );

      // Save car info (in real app, save to backend)
      await userProvider.updateCarInfo(carInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Car info saved!')),
        );
        Navigator.pushNamed(context, '/templates');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Car Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Car Details",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "These details will be shown when someone scans your QR code",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            // Car Number
            const Text("Car Number *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _carNumberController,
              decoration: InputDecoration(
                hintText: 'e.g., MH12AB1234',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.directions_car),
              ),
            ),
            const SizedBox(height: 20),
            // Car Model
            const Text("Car Model *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _carModelController,
              decoration: InputDecoration(
                hintText: 'e.g., Honda City 2022',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.car_rental),
              ),
            ),
            const SizedBox(height: 20),
            // Custom Message
            const Text("Custom Message", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _customMessageController,
              decoration: InputDecoration(
                hintText: 'e.g., Call me if car is blocking your way',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.message),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            // Custom Fields Section
            const Text(
              "Additional Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._customFields.asMap().entries.map((entry) {
              int index = entry.key;
              var field = entry.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: field.key,
                          decoration: InputDecoration(
                            hintText: 'Field name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: field.value,
                          decoration: InputDecoration(
                            hintText: 'Value',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeCustomField(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Field"),
                onPressed: _addCustomField,
              ),
            ),
            const SizedBox(height: 30),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCar,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save & Continue"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
