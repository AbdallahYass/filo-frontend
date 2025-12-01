import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // رابط السيرفر العالمي
  final String _baseUrl = 'https://filo-menu.onrender.com/api/auth';

  // 1. دالة إنشاء حساب جديد
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        return true; // تم الإنشاء بنجاح
      } else {
        print('Register Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // 2. دالة تسجيل الدخول
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // هنا المفروض نحفظ التوكن او بيانات المستخدم (لاحقاً)
        return true; // نجح الدخول
      } else {
        print('Login Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
