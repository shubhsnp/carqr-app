class CarInfo {
  final String id;
  final String userId;
  final String carNumber;
  final String carModel;
  final String customMessage; // "Call me if car is blocking your way"
  final Map<String, String> customFields; // User-defined extra fields
  final String selectedTemplate; // Template ID
  final DateTime createdAt;

  CarInfo({
    required this.id,
    required this.userId,
    required this.carNumber,
    required this.carModel,
    required this.customMessage,
    this.customFields = const {},
    required this.selectedTemplate,
    required this.createdAt,
  });

  // Create a copy with updated fields
  CarInfo copyWith({
    String? id,
    String? userId,
    String? carNumber,
    String? carModel,
    String? customMessage,
    Map<String, String>? customFields,
    String? selectedTemplate,
    DateTime? createdAt,
  }) {
    return CarInfo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      carNumber: carNumber ?? this.carNumber,
      carModel: carModel ?? this.carModel,
      customMessage: customMessage ?? this.customMessage,
      customFields: customFields ?? this.customFields,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'carNumber': carNumber,
      'carModel': carModel,
      'customMessage': customMessage,
      'customFields': customFields,
      'selectedTemplate': selectedTemplate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      id: json['id'] as String,
      userId: json['userId'] as String,
      carNumber: json['carNumber'] as String,
      carModel: json['carModel'] as String,
      customMessage: json['customMessage'] as String,
      customFields: Map<String, String>.from(json['customFields'] ?? {}),
      selectedTemplate: json['selectedTemplate'] as String? ?? 'modern',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
