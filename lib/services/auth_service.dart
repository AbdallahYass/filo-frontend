import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // رابط السيرفر
  final String _baseUrl = 'https://filo-menu.onrender.com/api/auth';

  // 🔐 مفتاح الحماية (نفس اللي حطيته في Render)
  final String _apiKey = 'FiloSecretKey202512341234';

  // 1. تسجيل حساب جديد
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey, // 👈 أضفنا هذا السطر المهم
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        // طباعة سبب الخطأ في الترمينال لنعرفه
        print('Register Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Connection Error: $e');
      return false;
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
        return true;
      } else {
        print('Login Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Connection Error: $e');
      return false;
    }
  }
}
