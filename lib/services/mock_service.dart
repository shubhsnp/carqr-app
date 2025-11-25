class MockService {
  // Mock database of car owners
  static final Map<String, Map<String, dynamic>> _carDatabase = {
    'QR001': {
      'ownerName': 'Rahul Patil',
      'carNumber': 'MH12AB1234',
      'phone': '9876543210',
      'email': 'rahul@example.com',
      'carModel': 'Honda City',
      'year': 2022,
    },
    'QR002': {
      'ownerName': 'Priya Sharma',
      'carNumber': 'DL01CD5678',
      'phone': '8765432109',
      'email': 'priya@example.com',
      'carModel': 'Maruti Swift',
      'year': 2023,
    },
    'QR003': {
      'ownerName': 'Vikram Singh',
      'carNumber': 'KA02EF9012',
      'phone': '7654321098',
      'email': 'vikram@example.com',
      'carModel': 'Hyundai Creta',
      'year': 2021,
    },
  };

  /// Get car owner info by QR code
  /// Returns null if QR not found
  Map<String, dynamic>? getCar(String qr) {
    // Default mock data if QR not in database
    return _carDatabase[qr] ?? {
      'ownerName': 'John Doe',
      'carNumber': 'XX00AA0000',
      'phone': '9999999999',
      'email': 'john@example.com',
      'carModel': 'Generic Car',
      'year': 2020,
    };
  }

  /// Check if a user has access to owner info (premium check)
  bool canViewOwnerInfo(bool isPremium) {
    return isPremium;
  }
}
