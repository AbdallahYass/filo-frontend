// lib/services/category_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class CategoryService {
  // 🔥🔥🔥 الإعدادات (تم تصحيح الرابط) 🔥🔥🔥
  final String _apiBaseUrl = kDebugMode
      ? 'http://10.0.2.2:3000/api'
      : 'https://filo-menu.onrender.com/api';
  final String _apiKey = 'FiloSecretKey202512341234';

  // ----------------------------------------------------------------

  // ==================================================
  // 1. جلب جميع الفئات
  // ==================================================
  /// يجلب قائمة الفئات من الـ API الحقيقي.
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      if (kDebugMode) {
        print("Attempting to fetch categories from API...");
      }

      final response = await http.get(
        // 🔥 استخدام الرابط الصحيح (جذر API + المسار) 🔥
        Uri.parse('$_apiBaseUrl/categories'),
        headers: {'x-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        // 1. إذا كانت القائمة فارغة، نرجع قائمة فارغة (نجاح).
        if (jsonList.isEmpty) return [];

        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      }
      // 2. رفع خطأ في حالة فشل الاستجابة (غير 200)
      else {
        final errorBody = jsonDecode(response.body);
        if (kDebugMode) {
          print(
            "API request failed with status code: ${response.statusCode}. Error: ${errorBody['error'] ?? 'Unknown'}",
          );
        }
        throw Exception(
          "Failed to load categories: ${errorBody['error'] ?? response.statusCode}",
        );
      }
    } catch (e) {
      // 3. رفع خطأ في حالة فشل الاتصال بالشبكة
      if (kDebugMode) print("CategoryService Connection Error: $e");
      throw Exception("Connection Error: Failed to reach the server.");
    }
  }
}
