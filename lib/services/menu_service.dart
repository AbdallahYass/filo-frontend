// lib/services/menu_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item.dart';

class MenuService {
  final String _apiBaseUrl = kDebugMode
      ? 'http://10.0.2.2:3000/api'
      : 'https://filo-menu.onrender.com/api';
  final String _apiKey = 'FiloSecretKey202512341234';

  // ignore: unused_element
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ==================================================
  // 1. جلب قائمة الطعام (مع دعم لـ vendorId)
  // ==================================================
  /// يجلب قائمة الطعام من الـ API الحقيقي.
  Future<List<MenuItem>> fetchMenu({String? vendorId}) async {
    try {
      final String endpoint = vendorId != null
          ? '$_apiBaseUrl/menu?vendorId=$vendorId'
          : '$_apiBaseUrl/menu';

      if (kDebugMode && vendorId != null) {
        print("Attempting to fetch menu for vendor: $vendorId from API...");
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'x-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);

        if (kDebugMode && body.isNotEmpty) {
          print(
            "API MENU RESPONSE (First Item): ${body[0]['title']} (${body.length} items)",
          );
        }

        // 1. إذا كانت القائمة فارغة، نرجع قائمة فارغة (نجاح).
        if (body.isEmpty) return [];

        // 2. تحليل البيانات الحقيقية
        return body.map((json) => MenuItem.fromJson(json)).toList();
      }
      // 3. رفع خطأ في حالة فشل الاستجابة (غير 200)
      else {
        final errorBody = jsonDecode(response.body);
        if (kDebugMode) {
          print(
            "API request failed with status code: ${response.statusCode}. Error: ${errorBody['error'] ?? 'Unknown'}",
          );
        }
        throw Exception(
          "Failed to load menu: ${errorBody['error'] ?? response.statusCode}",
        );
      }
    } catch (e) {
      // 4. رفع خطأ في حالة فشل الاتصال بالشبكة
      if (kDebugMode) print("MenuService Network/Parsing Error: $e");
      throw Exception(
        "Connection Error: Failed to reach the server or parse data.",
      );
    }
  }

  // ==================================================
  // 2. دالة Mock Data (تم حذفها)
  // ==================================================
  // لم تعد هناك حاجة لدالة _getMockMenuItems
}
