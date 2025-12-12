// lib/services/vendor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class VendorService {
  // 🔥🔥 تأكد من صحة هذا الرابط لجهازك 🔥🔥
  final String _apiBaseUrl = kDebugMode
      ? 'http://10.0.2.2:3000/api' // رابط محاكي الأندرويد
      : 'https://filo-menu.onrender.com/api';
  final String _apiKey = 'FiloSecretKey202512341234';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ----------------------------------------------------------------

  // ==================================================
  // 1. جلب قائمة التجار بناءً على مفتاح الفئة (بدون Mock)
  // ==================================================
  Future<List<UserModel>> fetchVendorsByCategory(
    String categoryKey, {
    String sortBy = 'default',
  }) async {
    try {
      if (kDebugMode) {
        print(
          "Attempting to fetch vendors for category: $categoryKey, sorted by: $sortBy from API...",
        );
      }

      final token = await _getToken();

      final uri = Uri.parse('$_apiBaseUrl/vendors').replace(
        queryParameters: {
          'category': categoryKey,
          'sortBy': sortBy, // تمرير خيار الفرز
        },
      );

      // 🔥🔥 طباعة الـ URI التي سيتم استخدامها للتشخيص 🔥🔥
      if (kDebugMode) {
        print('Vendor API URI: $uri');
        print('Vendor API Token is null? ${token == null}');
      }
      // 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      // 🔥🔥 طباعة حالة الـ API والـ Error Body للتشخيص 🔥🔥
      if (kDebugMode) {
        print('Vendor API Status Code: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('Vendor API Error Body: ${response.body}');
        }
      }
      // 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥

      // 2. التحقق من نجاح الاستجابة
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        // إذا كانت القائمة فارغة (200 OK)
        if (jsonList.isEmpty) return [];

        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      // 3. رفع خطأ في حالة فشل الاستجابة (غير 200)
      else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          "Failed to load vendors: ${errorBody['error'] ?? response.statusCode}",
        );
      }
    } catch (e) {
      // 4. رفع خطأ في حالة فشل الاتصال بالشبكة
      if (kDebugMode) {
        print("API connection error occurred: $e.");
      }
      throw Exception("Connection Error: Failed to reach the server.");
    }
  }

  // ----------------------------------------------------------------
  // تم إزالة دالة _fetchMockVendors والاعتماد على API بالكامل
  // ----------------------------------------------------------------
}
