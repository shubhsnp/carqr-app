import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/car_info.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  CarInfo? _currentCar;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  CarInfo? get currentCar => _currentCar;
  bool get isLoggedIn => _currentUser != null;
  bool get isPremium => _currentUser?.isPremiumActive ?? false;
  String? get errorMessage => _errorMessage;

  // Register user with real API
  Future<void> registerUser(String email, String phone) async {
    try {
      _errorMessage = null;
      final response = await ApiService.register(email, phone);
      
      _currentUser = User(
        id: response['user']['id'],
        email: response['user']['email'],
        phone: response['user']['phone'],
        isPremium: response['user']['isPremium'] ?? false,
        selectedTemplate: response['user']['selectedTemplate'] ?? 'modern',
        createdAt: DateTime.parse(response['user']['createdAt']),
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Login user with real API
  Future<void> loginUser(String phone, String otp, String sessionId) async {
    try {
      _errorMessage = null;
      final response = await ApiService.verifyOtp(phone, otp, sessionId);
      
      _currentUser = User(
        id: response['user']['id'],
        email: response['user']['email'],
        phone: response['user']['phone'],
        isPremium: response['user']['isPremium'] ?? false,
        selectedTemplate: response['user']['selectedTemplate'] ?? 'modern',
        createdAt: DateTime.parse(response['user']['createdAt']),
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOtp(String phone) async {
    try {
      _errorMessage = null;
      final response = await ApiService.requestOtp(phone);
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Verify OTP and login
  Future<void> verifyOtpAndLogin(String phone, String otp, String sessionId, [String? email]) async {
    try {
      _errorMessage = null;
      final response = await ApiService.verifyOtp(phone, otp, sessionId, email: email);

      final user = response['user'];
      _currentUser = User(
        id: user['id']?.toString() ?? '',
        email: user['email'],
        phone: user['phone']?.toString() ?? phone,
        isPremium: user['isPremium'] ?? false,
        selectedTemplate: user['selectedTemplate'] ?? 'modern',
        createdAt: user['createdAt'] != null ? DateTime.parse(user['createdAt']) : DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  Future<void> updateTemplate(String templateId) async {
    if (_currentUser != null) {
      try {
        await ApiService.updateTemplate(templateId);
        _currentUser = _currentUser!.copyWith(selectedTemplate: templateId);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  // Upgrade to premium
  Future<void> upgradeToPremium() async {
    if (_currentUser != null) {
      try {
        _errorMessage = null;
        await ApiService.initiatePremiumUpgrade(365);
        
        // After successful payment verification, update user
        _currentUser = _currentUser!.copyWith(
          isPremium: true,
          premiumExpiryDate: DateTime.now().add(const Duration(days: 365)),
        );
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await ApiService.logout();
      _currentUser = null;
      _currentCar = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Save car information
  Future<void> updateCarInfo(CarInfo carInfo) async {
    try {
      _errorMessage = null;
      await ApiService.addCarInfo(
        carInfo.carNumber,
        carInfo.carModel,
        carInfo.customMessage,
        carInfo.customFields,
      );
      
      _currentCar = carInfo;
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(hasCarInfo: true);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
