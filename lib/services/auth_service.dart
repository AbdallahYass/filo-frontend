// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // رابط السيرفر العالمي
  final String _baseUrl = 'https://filo-menu.onrender.com/api/auth';

  // 🔐 مفتاح الحماية (نفس الموجود في إعدادات Render)
  final String _apiKey = 'FiloSecretKey202512341234';

  // 1. تسجيل حساب جديد
  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        return null; // null تعني نجاح (لا يوجد خطأ)
      } else {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'فشل التسجيل';
      }
    } catch (e) {
      return 'خطأ في الاتصال بالإنترنت';
    }
  }

  // 2. التحقق من الرمز (Verify OTP)
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
        return body['error'] ?? 'رمز التفعيل غير صحيح';
      }
    } catch (e) {
      return 'خطأ في الاتصال';
    }
  }

  // 3. تسجيل الدخول
  // 3. تسجيل الدخول (المعدلة)
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return null; // نجاح
      } else {
        final body = jsonDecode(response.body);

        // 👇👇👇 التقاط حالة عدم التفعيل
        if (body['error'] == 'NOT_VERIFIED') {
          return 'NOT_VERIFIED'; // نرجع هذه الكلمة للشاشة لتتصرف
        }

        return body['error'] ?? 'فشل تسجيل الدخول';
      }
    } catch (e) {
      return 'خطأ في الاتصال';
    }
  }
}
