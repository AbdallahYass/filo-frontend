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
  // 🔥🔥 تم إضافة معامل sortBy (إجباري لحل المشكلة) 🔥🔥
  Future<List<UserModel>> fetchVendorsByCategory(
    String categoryKey, {
    String sortBy = 'default',
  }) async {
    // 1. محاولة جلب البيانات من الخادم أولاً
    try {
      if (kDebugMode) {
        print(
          "Attempting to fetch vendors for category: $categoryKey, sorted by: $sortBy from API...",
        );
      }

      final token = await _getToken();
      // 🔥🔥 بناء الـ URI مع معامل sortBy 🔥🔥
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

        if (jsonList.isNotEmpty) {
          if (kDebugMode) {
            print("Successfully fetched ${jsonList.length} vendors from API.");
          }
          return jsonList.map((json) => UserModel.fromJson(json)).toList();
        } else {
          if (kDebugMode) {
            print(
              "API returned an empty list (200 OK). Falling back to mock data.",
            );
          }
        }
      } else {
        if (kDebugMode) {
          print(
            "API request failed with status code: ${response.statusCode}. Falling back to mock data.",
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("API connection error occurred: $e. Falling back to mock data.");
      }
    }

    // 3. تنفيذ الـ Fallback (الجلب الاحتياطي) في حال الفشل أو القائمة الفارغة
    // 🔥🔥 تمرير sortBy إلى دالة الـ Mock 🔥🔥
    return _fetchMockVendors(categoryKey, sortBy);
  }

  // ==================================================
  // 2. دالة جلب البيانات الوهمية (Mock Data)
  // ==================================================
  // 🔥🔥 تم إضافة معامل sortBy للدالة الوهمية 🔥🔥
  Future<List<UserModel>> _fetchMockVendors(
    String categoryKey,
    String sortBy,
  ) async {
    if (kDebugMode) {
      print(
        "-> Using Mock Vendor Data for category: $categoryKey, sorted by: $sortBy",
      );
    }

    await Future.delayed(const Duration(milliseconds: 700));

    // قائمة التجار الوهمية (مع حقول وهمية للتقييم والطلبات)
    final List<Map<String, dynamic>> mockVendorsData = [
      {
        '_id': 'v1',
        'email': 'vendor1@example.com',
        'name': 'مطعم الشيف الذهبي',
        'role': 'vendor',
        'isVerified': true,
        'phone': '0590000001',
        // 🔥 إضافة بيانات وهمية للفرز 🔥
        'averageRating': 4.7,
        'ordersCount': 120,
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
        // 🔥 إضافة بيانات وهمية للفرز 🔥
        'averageRating': 4.2,
        'ordersCount': 75,
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
        'name': 'سوبر ماركت فيلو',
        'role': 'vendor',
        'isVerified': true,
        'phone': '0590000003',
        // 🔥 إضافة بيانات وهمية للفرز 🔥
        'averageRating': 4.9,
        'ordersCount': 250,
        'storeInfo': {
          'storeName': 'سوبر ماركت فيلو',
          'description': 'كل ما تحتاجه من مواد تموينية وبقالة في مكان واحد.',
          'logoUrl': 'https://placehold.co/60x60/AAAAAA/FFFFFF?text=MKT',
          'isOpen': true,
        },
      },
    ];

    // 1. فلترة البيانات الوهمية بناءً على مفتاح الفئة
    List<Map<String, dynamic>> filteredList;

    if (categoryKey == 'restaurant') {
      filteredList = [mockVendorsData[0]];
    } else if (categoryKey == 'bakery' || categoryKey == 'cafe') {
      filteredList = [mockVendorsData[1]];
    } else if (categoryKey == 'market') {
      filteredList = [mockVendorsData[2]];
    } else {
      filteredList = [];
    }

    // 2. 🔥 تطبيق الفرز على القائمة المفلترة (Client-side Sorting) 🔥
    if (sortBy == 'rating') {
      filteredList.sort(
        (a, b) => b['averageRating']!.compareTo(a['averageRating']!),
      );
    } else if (sortBy == 'popular') {
      filteredList.sort(
        (a, b) => b['ordersCount']!.compareTo(a['ordersCount']!),
      );
    }
    // 'default' (الافتراضي) هو حسب ترتيب التعريف في القائمة

    return filteredList.map((json) => UserModel.fromJson(json)).toList();
  }
}
