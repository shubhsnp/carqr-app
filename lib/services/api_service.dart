import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Environment-based API URL configuration
  // Use --dart-define=API_ENV=production when building for production
  static const String _apiEnv = String.fromEnvironment('API_ENV', defaultValue: 'development');

  static String get baseUrl {
    switch (_apiEnv) {
      case 'production':
        return 'https://api.carqr.app/api/v1'; // Replace with your production URL
      case 'staging':
        return 'https://staging-api.carqr.app/api/v1'; // Replace with staging URL
      default:
        // Development - using local network IP for physical device
        return 'http://192.168.1.2:3000/api/v1'; // Your computer's IP
    }
  }

  static String? authToken;

  // Helper method for API requests
  static Future<dynamic> _request(
    String endpoint, {
    required String method,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        if (requiresAuth && authToken != null) 'Authorization': 'Bearer $authToken',
      };

      http.Response response;
      final methodUpper = method.toUpperCase();
      final encodedBody = body != null ? jsonEncode(body) : null;

      if (methodUpper == 'GET') {
        response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      } else if (methodUpper == 'POST') {
        response = await http.post(url, headers: headers, body: encodedBody).timeout(const Duration(seconds: 10));
      } else if (methodUpper == 'PUT') {
        response = await http.put(url, headers: headers, body: encodedBody).timeout(const Duration(seconds: 10));
      } else if (methodUpper == 'DELETE') {
        response = await http.delete(url, headers: headers).timeout(const Duration(seconds: 10));
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Bad request');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // AUTH ENDPOINTS
  static Future<Map<String, dynamic>> register(String email, String phone) async {
    // Step 1: Request OTP - returns sessionId for verification
    final otpResponse = await _request(
      '/auth/otp/request',
      method: 'POST',
      body: {'phone': phone, 'email': email},
    );
    return otpResponse; // Return sessionId, user will enter OTP manually
  }

  // Complete registration after OTP verification
  static Future<Map<String, dynamic>> completeRegistration(
    String phone,
    String email,
    String otp,
    String sessionId,
  ) async {
    final response = await _request(
      '/auth/otp/verify',
      method: 'POST',
      body: {
        'phone': phone,
        'email': email,
        'otp': otp,
        'sessionId': sessionId,
      },
    );
    authToken = response['token'];
    return response;
  }

  static Future<Map<String, dynamic>> login(String phone, String otp, String sessionId) async {
    final response = await _request(
      '/auth/otp/verify',
      method: 'POST',
      body: {
        'phone': phone,
        'otp': otp,
        'sessionId': sessionId,
      },
    );
    authToken = response['token'];
    return response;
  }

  static Future<Map<String, dynamic>> requestOtp(String phone) async {
    final response = await _request(
      '/auth/otp/request',
      method: 'POST',
      body: {'phone': phone},
    );
    return response;
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp,
    String sessionId, {
    String? email,
  }) async {
    final response = await _request(
      '/auth/otp/verify',
      method: 'POST',
      body: {
        'phone': phone,
        'otp': otp,
        'sessionId': sessionId,
        if (email != null) 'email': email,
      },
    );
    authToken = response['token'];
    return response;
  }

  static Future<Map<String, dynamic>> emailLogin(String email) async {
    final response = await _request(
      '/auth/email/login',
      method: 'POST',
      body: {'email': email},
    );
    authToken = response['token'];
    return response;
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await _request('/users/me', method: 'GET', requiresAuth: true);
  }

  // CAR ENDPOINTS
  static Future<Map<String, dynamic>> addCarInfo(
    String carNumber,
    String carModel,
    String? customMessage,
    Map<String, dynamic>? customFields,
  ) async {
    return await _request(
      '/cars',
      method: 'POST',
      body: {
        'carNumber': carNumber,
        'carModel': carModel,
        'customMessage': customMessage,
        'customFields': customFields,
      },
      requiresAuth: true,
    );
  }

  static Future<Map<String, dynamic>> getCarInfo() async {
    return await _request('/cars/me', method: 'GET', requiresAuth: true);
  }

  static Future<Map<String, dynamic>> updateCarInfo(
    String carId,
    String carNumber,
    String carModel,
    String? customMessage,
    Map<String, dynamic>? customFields,
  ) async {
    return await _request(
      '/cars/$carId',
      method: 'PUT',
      body: {
        'carNumber': carNumber,
        'carModel': carModel,
        'customMessage': customMessage,
        'customFields': customFields,
      },
      requiresAuth: true,
    );
  }

  static Future<Map<String, dynamic>> getCarByQR(String qrCode) async {
    return await _request('/cars/qr/$qrCode', method: 'GET');
  }

  // QR ENDPOINTS
  static Future<Map<String, dynamic>> generateQr({
    required String size,
    required String format,
  }) async {
    return await _request(
      '/qr/generate',
      method: 'POST',
      body: {'size': size, 'format': format},
      requiresAuth: true,
    );
  }

  static Future<Map<String, dynamic>> getQRCode(String qrId) async {
    return await _request('/qr/$qrId', method: 'GET');
  }

  // PAYMENT ENDPOINTS
  static Future<Map<String, dynamic>> initiatePremiumUpgrade(int planDuration) async {
    return await _request(
      '/payments/razorpay/create',
      method: 'POST',
      body: {'planDuration': planDuration},
      requiresAuth: true,
    );
  }

  static Future<Map<String, dynamic>> verifyPayment(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    return await _request(
      '/payments/razorpay/verify',
      method: 'POST',
      body: {
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
      },
      requiresAuth: true,
    );
  }

  // USER ENDPOINTS
  static Future<Map<String, dynamic>> updateTemplate(String templateId) async {
    return await _request(
      '/users/template',
      method: 'PUT',
      body: {'selectedTemplate': templateId},
      requiresAuth: true,
    );
  }

  static Future<void> logout() async {
    authToken = null;
  }
}
