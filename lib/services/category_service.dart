// lib/services/category_service.dart (الكود المحدث)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class CategoryService {
  // 🔥🔥🔥 الإعدادات (تم تصحيح الرابط) 🔥🔥🔥
  final String _apiBaseUrl = kDebugMode
      ? 'http://10.0.2.2:3000/api'
      : 'https://filo-menu.onrender.com/api'; // تم حذف "/categories" من الرابط الأساسي
  final String _apiKey = 'FiloSecretKey202512341234';

  // ----------------------------------------------------------------

  // 🔥🔥 دالة جلب البيانات الافتراضية (تم تحديثها لدعم اللغتين) 🔥🔥
  List<CategoryModel> _getMockCategories() {
    // قائمة الفئات التي ستظهر عند فشل الاتصال أو عند التشغيل الأول
    final mockData = [
      {
        '_id': 'm1',
        'key': 'restaurant',
        'icon': 'restaurant',
        'name': {'en': 'Restaurants', 'ar': 'مطاعم'},
      },
      {
        '_id': 'm2',
        'key': 'bakery',
        'icon': 'bakery_dining',
        'name': {'en': 'Bakeries & Sweets', 'ar': 'مخابز وحلويات'},
      },
      {
        '_id': 'm3',
        'key': 'market',
        'icon': 'local_grocery_store',
        'name': {'en': 'Supermarkets', 'ar': 'سوبر ماركت'},
      },
      {
        '_id': 'm4',
        'key': 'cafe',
        'icon': 'coffee',
        'name': {'en': 'Cafes', 'ar': 'كافيهات'},
      },
    ];

    // تحويل القائمة الثابتة باستخدام الـ FromJson الجديد
    return mockData
        .map(
          (json) => CategoryModel.fromJson({
            '_id': json['_id'],
            'key': json['key'],
            'icon': json['icon'],
            'name': json['name'], // 🔥 تمرير الكائن المتعدد اللغات
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
        // 🔥 استخدام الرابط الصحيح (جذر API + المسار) 🔥
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
