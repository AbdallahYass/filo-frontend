// lib/services/vendor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class VendorService {
  final String _apiBaseUrl = kDebugMode
      ? 'http://10.0.2.2:3000/api'
      : 'https://filo-menu.onrender.com/api';
  final String _apiKey = 'FiloSecretKey202512341234';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  // ----------------------------------------------------------------

  // ==================================================
  // 1. جلب قائمة التجار بناءً على مفتاح الفئة (مع sortBy)
  // ==================================================
  /// يجلب قائمة التجار من الـ API الحقيقي بناءً على الفئة وخيار الفرز.
  Future<List<UserModel>> fetchVendorsByCategory(
    String categoryKey, {
    String sortBy = 'default',
  }) async {
    // 1. محاولة جلب البيانات من الخادم
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

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      // 2. التحقق من نجاح الاستجابة
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        if (kDebugMode) {
          print("Successfully fetched ${jsonList.length} vendors from API.");
        }

        // قد تكون القائمة فارغة، وهذا يعتبر نجاحاً
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      // 3. رفع خطأ في حالة فشل الاستجابة (غير 200)
      else {
        final errorBody = jsonDecode(response.body);
        if (kDebugMode) {
          print(
            "API request failed with status code: ${response.statusCode}. Error: ${errorBody['error']}",
          );
        }
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
}
