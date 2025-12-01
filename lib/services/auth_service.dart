// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // رابط السيرفر العالمي
  final String _baseUrl = 'https://filo-menu.onrender.com/api/auth';

  // 🔐 مفتاح الحماية (نفس الموجود في إعدادات Render)
  final String _apiKey = 'FiloSecretKey202512341234';

  // 1. تسجيل حساب جديد
  // 1. تسجيل حساب جديد (معدلة لترجع رسالة الخطأ)
  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        return null; // null يعني العملية نجحت بدون أخطاء
      } else {
        // فك تشفير رسالة الخطأ القادمة من السيرفر
        final body = jsonDecode(response.body);
        return body['error'] ?? 'فشل التسجيل لسبب غير معروف';
      }
    } catch (e) {
      return 'خطأ في الاتصال بالإنترنت';
    }
  }

  // 2. تسجيل الدخول
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey, // 👈 وأضفناه هنا أيضاً
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        print("تم الدخول بنجاح!");
        return true;
      } else {
        print('خطأ في الدخول: ${response.body}');
        return false;
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
      return false;
    }
  }
}
