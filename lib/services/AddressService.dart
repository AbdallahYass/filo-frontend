// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';

class AddressService {
  final String _baseUrl = 'https://filo-menu.onrender.com/api/user/addresses';
  final String _apiKey = 'FiloSecretKey202512341234';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // ⚠️ نفترض أن التوكن محفوظ تحت المفتاح 'token' أو 'auth_token'.
    // يجب توحيد مكان حفظ التوكن. سنعتمد حالياً على المفتاح 'token' في SharedPreferences مؤقتاً للتوافق السريع.
    return prefs.getString('token');
  }

  // ==================================================
  // 2. جلب جميع العناوين
  // ==================================================
  Future<List<AddressModel>> fetchAddresses() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-api-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => AddressModel.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print("Address Fetch Error: ${response.statusCode}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Connection Error during address fetch: $e");
      }
      return [];
    }
  }

  // ==================================================
  // 3. إضافة عنوان جديد
  // ==================================================
  Future<String?> addAddress(AddressModel address) async {
    final token = await _getToken();
    if (token == null) return "loginRequired"; // ✅ تم التصحيح إلى camelCase

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-api-key': _apiKey,
        },
        body: jsonEncode(address.toJson()),
      );

      if (response.statusCode == 201) {
        return null; // نجاح
      } else {
        final body = jsonDecode(response.body);
        return body['error'] ??
            'addressAddFailed'; // ✅ تم التصحيح إلى camelCase
      }
    } catch (e) {
      return 'connectionError'; // ✅ تم التصحيح
    }
  }

  // ==================================================
  // 4. حذف عنوان
  // ==================================================
  Future<bool> deleteAddress(String addressId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$addressId'), // endpoint/addressId
        headers: {'Authorization': 'Bearer $token', 'x-api-key': _apiKey},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
