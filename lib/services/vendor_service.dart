// lib/services/vendor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
// 🔥 يجب التأكد من وجود هذه الموديلات في مجلد lib/models
//import '../models/store_info_model.dart';
//import '../models/address_model.dart';

class VendorService {
  // 🔥🔥🔥 الإعدادات محددة هنا (بدلاً من BaseService) 🔥🔥🔥
  final String _apiBaseUrl = kDebugMode
      ? 'http://10.0.2.2:3000/api' // عنوان محلي لمحاكيات الأندرويد
      : 'https://filo-menu.onrender.com/api'; // عنوان الإنتاج
  final String _apiKey = 'FiloSecretKey202512341234';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  // ----------------------------------------------------------------

  // ==================================================
  // 1. جلب قائمة التجار بناءً على مفتاح الفئة (مع منطق الـ Fallback)
  // ==================================================
  Future<List<UserModel>> fetchVendorsByCategory(String categoryKey) async {
    // 1. محاولة جلب البيانات من الخادم أولاً
    try {
      if (kDebugMode) {
        print(
          "Attempting to fetch vendors for category: $categoryKey from API...",
        );
      }

      final token =
          await _getToken(); // نحتاج التوكن إذا كانت نقطة النهاية محمية
      final uri = Uri.parse('$_apiBaseUrl/vendors?category=$categoryKey');

      // ⚠️ ملاحظة: يجب أن تقوم ببناء مسار '/vendors' في ملف server.js
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

        if (jsonList.isNotEmpty) {
          // ✅ نجح الجلب والبيانات موجودة
          if (kDebugMode) {
            print("Successfully fetched ${jsonList.length} vendors from API.");
          }
          return jsonList.map((json) => UserModel.fromJson(json)).toList();
        } else {
          // ⚠️ نجح الجلب لكن القائمة فارغة
          if (kDebugMode) {
            print(
              "API returned an empty list (200 OK). Falling back to mock data.",
            );
          }
        }
      } else {
        // ❌ فشل الاستجابة (مثل 404, 500)
        if (kDebugMode) {
          print(
            "API request failed with status code: ${response.statusCode}. Falling back to mock data.",
          );
        }
      }
    } catch (e) {
      // ❌ فشل الاتصال أو حدث خطأ برمجي
      if (kDebugMode) {
        print("API connection error occurred: $e. Falling back to mock data.");
      }
    }

    // 3. تنفيذ الـ Fallback (الجلب الاحتياطي) في حال الفشل أو القائمة الفارغة
    return _fetchMockVendors(categoryKey);
  }

  // ==================================================
  // 2. دالة جلب البيانات الوهمية (Mock Data)
  // ==================================================
  Future<List<UserModel>> _fetchMockVendors(String categoryKey) async {
    if (kDebugMode) {
      print("-> Using Mock Vendor Data for category: $categoryKey");
    }

    await Future.delayed(const Duration(milliseconds: 700)); // محاكاة التأخير

    // قائمة التجار الوهمية (تستخدم نفس الهيكل الذي يتوقعه UserModel)
    final mockVendors = [
      {
        '_id': 'v1',
        'email': 'vendor1@example.com',
        'name': 'الشيف الذهبي',
        'role': 'vendor',
        'isVerified': true,
        'phone': '0590000001',
        'storeInfo': {
          'storeName': 'مطعم الشيف الذهبي',
          'description':
              'أفضل المأكولات الشرقية والغربية لزبائن فيلو المميزين.',
          'logoUrl': 'https://placehold.co/60x60/C5A028/000000?text=R',
          'isOpen': true,
        },
      },
      {
        '_id': 'v2',
        'email': 'vendor2@example.com',
        'name': 'مخبز الكعك',
        'role': 'vendor',
        'isVerified': true,
        'phone': '0590000002',
        'storeInfo': {
          'storeName': 'مخبز الكعك الطازج',
          'description': 'مخبوزات طازجة يومياً وقهوة ممتازة.',
          'logoUrl': 'https://placehold.co/60x60/FFFFFF/000000?text=B',
          'isOpen': false,
        },
      },
      {
        '_id': 'v3',
        'email': 'vendor3@example.com',
        'name': 'سوبر ماركت',
        'role': 'vendor',
        'isVerified': true,
        'phone': '0590000003',
        'storeInfo': {
          'storeName': 'سوبر ماركت فيلو',
          'description': 'كل ما تحتاجه من مواد تموينية وبقالة في مكان واحد.',
          'logoUrl': 'https://placehold.co/60x60/AAAAAA/FFFFFF?text=MKT',
          'isOpen': true,
        },
      },
    ];

    // 🔥 فلترة البيانات الوهمية بناءً على مفتاح الفئة
    List<Map<String, dynamic>> filteredList = [];

    if (categoryKey == 'restaurant') {
      filteredList = [mockVendors[0]];
    } else if (categoryKey == 'bakery' || categoryKey == 'cafe') {
      filteredList = [mockVendors[1]];
    } else if (categoryKey == 'market') {
      filteredList = [mockVendors[2]];
    } else {
      // نرجع قائمة فارغة للفئات الأخرى
      filteredList = [];
    }

    return filteredList.map((json) => UserModel.fromJson(json)).toList();
  }
}
