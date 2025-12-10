// lib/services/category_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
// ⚠️ ملاحظة: يجب التأكد من وجود موديل CategoryModel.dart

class CategoryService {
  // 🔥🔥🔥 الإعدادات (نفس ما اتفقنا عليه) 🔥🔥🔥
  final String _apiBaseUrl = kDebugMode
      ? 'http://10.0.2.2:3000/api'
      : 'https://filo-menu.onrender.com/api/categories';
  final String _apiKey = 'FiloSecretKey202512341234';

  // ----------------------------------------------------------------

  // 🔥🔥 دالة جلب البيانات الافتراضية (Default/Fallback Categories) 🔥🔥
  List<CategoryModel> _getMockCategories() {
    // قائمة الفئات التي ستظهر عند فشل الاتصال أو عند التشغيل الأول
    final mockData = [
      {'id': 'm1', 'name': 'مطاعم', 'key': 'restaurant', 'icon': 'restaurant'},
      {
        'id': 'm2',
        'name': 'مخابز وحلويات',
        'key': 'bakery',
        'icon': 'bakery_dining',
      },
      {
        'id': 'm3',
        'name': 'سوبر ماركت',
        'key': 'market',
        'icon': 'local_grocery_store',
      },
      {'id': 'm4', 'name': 'كافيهات', 'key': 'cafe', 'icon': 'coffee'},
    ];

    // تحويل القائمة الثابتة إلى موديل CategoryModel
    return mockData
        .map(
          (json) => CategoryModel.fromJson({
            '_id': json['id'], // MongoDB uses _id
            'name': json['name'],
            'key': json['key'],
            'icon': json['icon'],
          }),
        )
        .toList();
  }

  // ==================================================
  // 1. جلب جميع الفئات (مع خيار العودة للافتراضي)
  // ==================================================
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/categories'),
        headers: {'x-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        if (jsonList.isNotEmpty) {
          return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
        }
      }

      // إذا فشل الاتصال أو كانت القائمة فارغة من الخادم
      if (kDebugMode) {
        print(
          "CategoryService: Using mock data as API failed or returned empty.",
        );
      }
      return _getMockCategories(); // 🔥 العودة إلى البيانات الافتراضية 🔥
    } catch (e) {
      if (kDebugMode) print("CategoryService Connection Error: $e");
      // العودة إلى البيانات الافتراضية في حال فشل الاتصال
      return _getMockCategories();
    }
  }
}
