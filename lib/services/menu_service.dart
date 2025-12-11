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
  Future<List<MenuItem>> fetchMenu({String? vendorId}) async {
    try {
      final String endpoint = vendorId != null
          ? '$_apiBaseUrl/menu?vendorId=$vendorId'
          : '$_apiBaseUrl/menu';

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'x-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);

        // 🔥🔥 إضافة طباعة للمراجعة (Debugging) 🔥🔥
        if (kDebugMode && body.isNotEmpty) {
          print(
            "API MENU RESPONSE (First Item): ${body[0]['title']} (${body.length} items)",
          );
        }
        // 🔥🔥

        if (body.isEmpty) return _getMockMenuItems(vendorId);
        return body.map((json) => MenuItem.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("MenuService Network/Parsing Error: $e");
    }
    return _getMockMenuItems(vendorId);
  }

  // ==================================================
  // 2. دالة Mock Data (المعدلة)
  // ==================================================
  List<MenuItem> _getMockMenuItems(String? vendorId) {
    if (kDebugMode) {
      print("-> Using Mock Menu Data for vendor: $vendorId");
    }

    if (vendorId == 'v1' || vendorId == 'v2') {
      // بيانات مخصصة للتاجر الأول (مطعم)
      final mockData = [
        {
          "_id": "i101",
          "title": "طبق الشيف المميز",
          "description": "وجبة لحم فاخرة مع الخضروات الموسمية.",
          "price": 18.50,
          "category": "Main Dishes",
          "imageUrl":
              "https://placehold.co/400x300/C5A028/FFFFFF?text=Featured%20Dish",
          "isAvailable": true,
          "vendorId": "v1", // 🔥🔥 تمت الإضافة 🔥🔥
        },
        {
          "_id": "i102",
          "title": "سلطة السيزر",
          "description": "سلطة خفيفة مع دجاج مشوي.",
          "price": 7.00,
          "category": "Salads",
          "imageUrl": "https://placehold.co/400x300/C5A028/FFFFFF?text=Salad",
          "isAvailable": true,
          "vendorId": "v1", // 🔥🔥 تمت الإضافة 🔥🔥
        },
        {
          "_id": "i103",
          "title": "عصير ليمون بالنعناع",
          "description": "منعش ومثالي للصيف.",
          "price": 3.50,
          "category": "Drinks",
          "imageUrl": "https://placehold.co/400x300/C5A028/FFFFFF?text=Drink",
          "isAvailable": true,
          "vendorId": "v2", // 🔥🔥 تمت الإضافة 🔥🔥
        },
      ];
      return mockData
          .map(
            (json) => MenuItem.fromJson({
              'id': json['_id'],
              'title': json['title'],
              'description': json['description'],
              'price': json['price'],
              'category': json['category'],
              'imageUrl': json['imageUrl'],
              'isAvailable': json['isAvailable'],
              'vendorId': json['vendorId'], // 🔥🔥 تمت الإضافة 🔥🔥
            }),
          )
          .toList();
    }
    return [];
  }
}
