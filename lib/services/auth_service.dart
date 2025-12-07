// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 🔗 رابط السيرفر
  final String _baseUrl = 'https://filo-menu.onrender.com/api/auth';

  // 🔐 مفتاح الحماية (اختياري حسب إعدادات السيرفر لديك)
  final String _apiKey = 'FiloSecretKey202512341234';

  // 📦 أدوات التخزين
  final _storage = const FlutterSecureStorage();

  // ==================================================
  // 1. تسجيل حساب جديد (مع الهاتف وتحديد الدور)
  // ==================================================
  Future<String?> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    print("🚀 بدء عملية التسجيل...");

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'phone': phone, // 📞 إضافة رقم الهاتف
              'role': 'customer', // 👤 تحديد أن هذا المستخدم "زبون"
            }),
          )
          .timeout(const Duration(seconds: 90));

      print("📡 كود الحالة: ${response.statusCode}");

      if (response.statusCode == 201) {
        print("✅ تم إنشاء الحساب بنجاح!");
        return null; // لا يوجد خطأ
      } else {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'فشل التسجيل';
      }
    } catch (e) {
      print("❌ خطأ في الاتصال: $e");
      return 'خطأ في الاتصال بالسيرفر';
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
        return body['error'] ?? 'رمز التفعيل غير صحيح';
      }
    } catch (e) {
      return 'خطأ في الاتصال';
    }
  }

  // ==================================================
  // 3. تسجيل الدخول (Login) - مع الحماية
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

        // 🛑 حماية: منع السائقين والمتاجر من الدخول لتطبيق الزبائن
        if (user['role'] != 'customer' && user['role'] != 'admin') {
          return 'هذا الحساب غير مخصص للزبائن (ربما حساب سائق أو متجر)';
        }

        // ✅ حفظ التوكن
        await _storage.write(key: 'auth_token', value: token);

        // ✅ حفظ بيانات المستخدم (للاستخدام في البروفايل)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user));

        return null; // نجاح
      } else {
        // التحقق من الحالات الخاصة
        if (body['error'] == 'NOT_VERIFIED') {
          return 'NOT_VERIFIED'; // الإيميل غير مفعل
        }
        return body['error'] ?? 'فشل تسجيل الدخول';
      }
    } catch (e) {
      print('Login Error: $e');
      return 'خطأ في الاتصال بالسيرفر';
    }
  }

  // ==================================================
  // 4. دوال التحقق من الهاتف (Phone Verification)
  // ==================================================

  // طلب إرسال رمز SMS
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

  // التحقق من رمز SMS المدخل
  Future<bool> verifyPhoneOtp(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/phone/verify'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({
          'email': email,
          'otp': code,
        }), // تأكدنا أن الاسم 'otp'
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================================================
  // 5. أدوات إدارة الجلسة (Logout & Token)
  // ==================================================

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}
