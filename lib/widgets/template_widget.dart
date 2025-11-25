import 'package:flutter/material.dart';

class TemplateWidget extends StatelessWidget {
  final Map<String, dynamic> carData;
  final String templateId;

  const TemplateWidget({
    super.key,
    required this.carData,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    switch (templateId) {
      case 'modern':
        return _buildModernTemplate();
      case 'classic':
        return _buildClassicTemplate();
      case 'minimal':
        return _buildMinimalTemplate();
      default:
        return _buildModernTemplate();
    }
  }

  /// Modern style - Gradient background with rounded corners
  Widget _buildModernTemplate() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade400, Colors.indigo.shade800],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              carData["ownerName"] ?? "N/A",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow("🚗", "Car: ${carData["carNumber"] ?? "N/A"}", Colors.white),
            const SizedBox(height: 8),
            _buildInfoRow("📱", carData["phone"] ?? "N/A", Colors.white),
            const SizedBox(height: 8),
            _buildInfoRow("✉️", carData["email"] ?? "N/A", Colors.white),
          ],
        ),
      ),
    );
  }

  /// Classic style - Traditional design with bordered layout
  Widget _buildClassicTemplate() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.indigo, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.indigo, width: 2),
                ),
              ),
              child: Text(
                carData["ownerName"] ?? "N/A",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildClassicInfoRow("Car Number", carData["carNumber"] ?? "N/A"),
            const SizedBox(height: 8),
            _buildClassicInfoRow("Phone", carData["phone"] ?? "N/A"),
            const SizedBox(height: 8),
            _buildClassicInfoRow("Email", carData["email"] ?? "N/A"),
          ],
        ),
      ),
    );
  }

  /// Minimal style - Clean and simple
  Widget _buildMinimalTemplate() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              carData["ownerName"] ?? "N/A",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("${carData["carNumber"] ?? "N/A"}", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(carData["phone"] ?? "N/A", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(carData["email"] ?? "N/A", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Helper for modern template info rows
  Widget _buildInfoRow(String emoji, String text, Color textColor) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Helper for classic template info rows
  Widget _buildClassicInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
