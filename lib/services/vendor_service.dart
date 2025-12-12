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

  // ==================================================
  // 1. جلب قائمة التجار
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

      final uri = Uri.parse(
        '$_apiBaseUrl/vendors',
      ).replace(queryParameters: {'category': categoryKey, 'sortBy': sortBy});

      final response = await http.get(
        uri,
        headers: {
          // 🛑🛑 تم إزالة رأس Authorization لحل مشكلة 401 في المسار العام 🛑🛑
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      // 🔥🔥 أدوات التشخيص (للتأكد من رمز الحالة النهائي) 🔥🔥
      if (kDebugMode) {
        print('Vendor API Status Code: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('Vendor API Error Body: ${response.body}');
        }
      }
      // 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        if (jsonList.isEmpty) return [];

        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      } else {
        final errorBody = jsonDecode(response.body);

        throw Exception(
          "Failed to load vendors: ${errorBody['error'] ?? response.statusCode}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("CRITICAL CONNECTION ERROR: $e");
      }
      throw Exception("Connection Error: Failed to reach the server.");
    }
  }

  // ==================================================
  // 2. 🔥 إدارة المفضلة (Favorites) 🔥
  // ==================================================

  Future<void> toggleFavorite(String vendorId, bool isAdding) async {
    final token = await _getToken();
    if (token == null) {
      if (kDebugMode) {
        print("ERROR: Cannot toggle favorite. User is not logged in.");
      }
      throw Exception("UNAUTHORIZED_ACCESS");
    }

    final String endpoint = '$_apiBaseUrl/user/favorites/$vendorId';

    http.Response response;

    // تحديد نوع الطلب: POST للإضافة، DELETE للحذف
    if (isAdding) {
      if (kDebugMode) print("Attempting to ADD favorite: $vendorId");
      response = await http.post(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $token', 'x-api-key': _apiKey},
      );
    } else {
      if (kDebugMode) print("Attempting to REMOVE favorite: $vendorId");
      response = await http.delete(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $token', 'x-api-key': _apiKey},
      );
    }

    // الخادم يرجع 200 OK للإضافة والحذف الناجحين
    if (response.statusCode == 200) {
      if (kDebugMode) print("Favorite status updated successfully.");
      return;
    } else if (response.statusCode == 409 || response.statusCode == 404) {
      // 409: موجود بالفعل (عند الإضافة)
      // 404: غير موجود (عند الحذف)
      if (kDebugMode) {
        print(
          "Favorite status already set or resource not found (Status ${response.statusCode})",
        );
      }
      return;
    }

    // رفع خطأ في أي حالة فشل أخرى
    final errorBody = jsonDecode(response.body);
    throw Exception(
      errorBody['message'] ??
          'Failed to update favorites: Status ${response.statusCode}',
    );
  }
}
