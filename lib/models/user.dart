class User {
  final String id;
  final String? email;
  final String phone;
  final bool isPremium;
  final String? selectedTemplate; // Template ID preference
  final DateTime? premiumExpiryDate;
  final DateTime createdAt;
  final bool hasCarInfo; // Whether user has added car information
  final String plan; // 'basic' or 'premium'

  User({
    required this.id,
    this.email,
    required this.phone,
    required this.isPremium,
    this.selectedTemplate = "modern",
    this.premiumExpiryDate,
    required this.createdAt,
    this.hasCarInfo = false,
    this.plan = 'basic',
  });

  // Check if premium subscription is still active
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiryDate == null) return true; // Lifetime premium
    return DateTime.now().isBefore(premiumExpiryDate!);
  }

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? phone,
    bool? isPremium,
    String? selectedTemplate,
    DateTime? premiumExpiryDate,
    DateTime? createdAt,
    bool? hasCarInfo,
    String? plan,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isPremium: isPremium ?? this.isPremium,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      createdAt: createdAt ?? this.createdAt,
      hasCarInfo: hasCarInfo ?? this.hasCarInfo,
      plan: plan ?? this.plan,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'isPremium': isPremium,
      'selectedTemplate': selectedTemplate,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'hasCarInfo': hasCarInfo,
      'plan': plan,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      isPremium: json['isPremium'] as bool,
      selectedTemplate: json['selectedTemplate'] as String?,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.parse(json['premiumExpiryDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      hasCarInfo: json['hasCarInfo'] as bool? ?? false,
      plan: json['plan'] as String? ?? 'basic',
    );
  }
}
