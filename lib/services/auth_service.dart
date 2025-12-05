// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
// 👇 1. إضافة مكتبة التخزين الآمن (تأكد أنك أضفتها في pubspec.yaml)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // رابط السيرفر العالمي
  final String _baseUrl = 'https://filo-menu.onrender.com/api/auth';

  // 🔐 مفتاح الحماية
  final String _apiKey = 'FiloSecretKey202512341234';

  // 👇 2. إنشاء كائن التخزين
  final _storage = const FlutterSecureStorage();
  //
  // 1. تسجيل حساب جديد
  // 1. تسجيل حساب جديد (نسخة التشخيص)
  Future<String?> register(String name, String email, String password) async {
    print("🚀 1. بدأت محاولة الاتصال بالسيرفر...");
    print("📍 الرابط المستخدم: $_baseUrl/register");

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20)); // ⏰ أضفنا مهلة 20 ثانية

      print("📡 2. وصل رد من السيرفر! كود الحالة: ${response.statusCode}");
      print("📄 محتوى الرد: ${response.body}");

      if (response.statusCode == 201) {
        print("✅ 3. تم التسجيل بنجاح!");
        return null; // نجاح
      } else {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'فشل التسجيل';
      }
    } catch (e) {
      // 🚨 هنا المشكلة كانت مخفية!
      print("☠️ 4. حدث خطأ أثناء الاتصال (CATCH): $e");
      return 'خطأ في الاتصال: $e';
    }
  }

  // 2. التحقق من رمز الإيميل (Verify Email OTP)
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
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // 👇 التعديل هنا: استخراج التوكن وحفظه
        final body = jsonDecode(response.body);
        String token = body['token'];

        // حفظ التوكن في الخزنة الآمنة
        await _storage.write(key: 'auth_token', value: token);

        // (اختياري) حفظ بيانات المستخدم إذا احتجتها
        // await _storage.write(key: 'user_data', value: jsonEncode(body['user']));

        return null; // نجاح
      } else {
        final body = jsonDecode(response.body);

        // 👇 معالجة الحالات الخاصة
        if (body['error'] == 'NOT_VERIFIED') {
          return 'NOT_VERIFIED';
        } else if (body['error'] == 'PHONE_NOT_VERIFIED') {
          return 'PHONE_NOT_VERIFIED';
        }

        return body['error'] ?? 'فشل تسجيل الدخول';
      }
    } catch (e) {
      return 'خطأ في الاتصال';
    }
  }

  // 4. طلب رمز الهاتف
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

  // 5. تفعيل الهاتف
  Future<bool> verifyPhoneOtp(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/phone/verify'),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        // 👇👇👇 التعديل هنا: غيرنا كلمة 'code' إلى 'otp' لتطابق السيرفر
        body: jsonEncode({'email': email, 'otp': code}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 👇 دوال إضافية مساعدة (مهمة جداً لإدارة الجلسة)
  // ==========================================

  // 6. تسجيل الخروج (حذف التوكن)
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    // await _storage.delete(key: 'user_data');
  }

  // 7. جلب التوكن الحالي (للاستخدام في الطلبات الأخرى)
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // 8. التأكد هل المستخدم مسجل دخول أم لا
  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}
