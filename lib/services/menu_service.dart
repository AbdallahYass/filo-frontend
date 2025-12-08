// lib/services/menu_service.dart

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

class MenuService {
  String get baseUrl {
    // نستخدم الرابط العالمي دائماً الآن
    return 'https://filo-menu.onrender.com/api/menu';
  }

  Future<List<MenuItem>> fetchMenu() async {
    try {
      print("Connecting to: $baseUrl"); // ✅ تم التوحيد

      // 👇👇👇 التعديل الهام هنا: إضافة الـ Header
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'FiloSecretKey202512341234', // 🔑 المفتاح السري
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => MenuItem.fromJson(json)).toList();
      } else {
        // 🔥 توحيد رسالة الخطأ إلى كود ثابت/إنجليزي لـ UI layer
        throw Exception(
          'SERVER_ERROR: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("Connection Error: $e"); // ✅ تم التوحيد
      // 🔥 توحيد رسالة الخطأ
      throw Exception('CONNECTION_ERROR: $e');
    }
  }
}
