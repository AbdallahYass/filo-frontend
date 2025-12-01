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
      print("جاري الاتصال بـ: $baseUrl");

      // 👇👇👇 التعديل الهام هنا: إضافة الـ Header
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'FiloSecretKey2025', // 🔑 المفتاح السري
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => MenuItem.fromJson(json)).toList();
      } else {
        throw Exception(
          'خطأ في السيرفر: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("خطأ في الاتصال: $e");
      throw Exception('فشل الاتصال: $e');
    }
  }
}
