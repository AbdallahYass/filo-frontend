// lib/services/auth_service.dart

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 🔗 رابط السيرفر
  final String _baseUrl = 'https://filo-menu.onrender.com/api/auth';

  // 🔐 مفتاح الحماية
  final String _apiKey = 'FiloSecretKey202512341234';

  // 📦 أدوات التخزين
  final _storage = const FlutterSecureStorage();

  // ==================================================
  // 1. تسجيل حساب جديد
  // ==================================================
  Future<String?> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'phone': phone,
              'role': 'customer',
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 201) {
        return null; // نجاح
      } else {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'registrationFailed'; // ✅ تم التصحيح
      }
    } catch (e) {
      return 'connectionError'; // ✅ تم التصحيح
    }
  }

  // ==================================================
  // 2. التحقق من كود الإيميل (Email OTP)
  // ==================================================
  Future<String?> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return null; // نجاح
      } else {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'invalidOtp'; // ✅ تم التصحيح
      }
    } catch (e) {
      return 'connectionError'; // ✅ تم التصحيح
    }
  }

  // ==================================================
  // 3. تسجيل الدخول (Login)
  // ==================================================
  Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = body['token'];
        Map<String, dynamic> user = body['user'];

        // 🛑 حماية: منع الأدوار غير المسموح بها
        if (user['role'] != 'customer' && user['role'] != 'admin') {
          return 'roleNotAllowed'; // ✅ تم التصحيح
        }

        // ✅ حفظ التوكن وبيانات المستخدم
        await _storage.write(key: 'auth_token', value: token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user));

        return null; // نجاح
      } else {
        if (body['error'] == 'NOT_VERIFIED') {
          return 'NOT_VERIFIED';
        }
        return body['error'] ?? 'loginFailed'; // ✅ تم التصحيح
      }
    } catch (e) {
      print('Login Error: $e');
      return 'connectionError'; // ✅ تم التصحيح
    }
  }

  // ... (بقية دوال AuthService لا تحتاج تعديلاً في هذه المرحلة)
  Future<bool> sendPhoneOtp(String email, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/phone/send'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({'email': email, 'phone': phone}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPhoneOtp(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/phone/verify'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({'email': email, 'otp': code}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}
