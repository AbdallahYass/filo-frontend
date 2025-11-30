// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

class MenuService {
  // 👇👇👇 الرابط العالمي الجديد (يعمل على الويب والموبايل)
  final String baseUrl = 'https://filo-menu.onrender.com/api/menu';

  Future<List<MenuItem>> fetchMenu() async {
    try {
      print("جاري الاتصال بـ: $baseUrl");
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => MenuItem.fromJson(json)).toList();
      } else {
        throw Exception('خطأ في السيرفر: ${response.statusCode}');
      }
    } catch (e) {
      print("خطأ في الاتصال: $e");
      throw Exception('فشل الاتصال: $e');
    }
  }
}
