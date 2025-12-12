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
}
