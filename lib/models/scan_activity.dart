class ScanActivity {
  final String id;
  final String carId;
  final String scannerPhone;
  final String scannerEmail;
  final DateTime timestamp;
  final String? notes;

  ScanActivity({
    required this.id,
    required this.carId,
    required this.scannerPhone,
    required this.scannerEmail,
    required this.timestamp,
    this.notes,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'scannerPhone': scannerPhone,
      'scannerEmail': scannerEmail,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from JSON
  factory ScanActivity.fromJson(Map<String, dynamic> json) {
    return ScanActivity(
      id: json['id'] as String,
      carId: json['carId'] as String,
      scannerPhone: json['scannerPhone'] as String,
      scannerEmail: json['scannerEmail'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }
}
