// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  // 👇👇👇 التعديل الحاسم: استخدام رابط السيرفر العالمي (Render)
  // الآن يعمل التطبيق على أي شبكة إنترنت!
  final String _baseUrl = 'https://filo-menu.onrender.com/api/orders';

  String? tableNumber;

  void setTableNumber(String number) {
    tableNumber = number;
    print("تم تعيين رقم الطاولة: $number");
  }

  int getQuantity(String itemId) {
    try {
      final existingItem = _items.firstWhere((i) => i.item.id == itemId);
      return existingItem.quantity;
    } catch (e) {
      return 0;
    }
  }

  void addItem(MenuItem item, int quantity) {
    int index = _items.indexWhere((i) => i.item.id == item.id);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(item: item, quantity: quantity));
    }
  }

  void updateQuantity(MenuItem item, int quantity) {
    int index = _items.indexWhere((i) => i.item.id == item.id);
    if (index != -1) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        removeItem(item.id);
      }
    } else {
      if (quantity > 0) {
        _items.add(CartItem(item: item, quantity: quantity));
      }
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.item.id == itemId);
  }

  void clearCart() {
    _items.clear();
  }

  double get totalPrice {
    double total = 0.0;
    for (var cartItem in _items) {
      total += cartItem.totalItemPrice;
    }
    return total;
  }

  Future<bool> placeOrder() async {
    if (_items.isEmpty) return false;

    final orderData = {
      'items': _items
          .map(
            (cartItem) => {
              'id': cartItem.item.id,
              'title': cartItem.item.title,
              'quantity': cartItem.quantity,
              'price': cartItem.item.price,
            },
          )
          .toList(),
      'totalPrice': totalPrice,
      'date': DateTime.now().toIso8601String(),
      'tableNumber': tableNumber ?? "Takeaway",
    };

    try {
      print('Sending order to: $_baseUrl');

      // داخل دالة placeOrder في http.post
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key':
              'FiloSecretKey202512341234', // 👈 أضف هذا السطر (نفس الكلمة اللي في السيرفر)
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        clearCart();
        return true;
      } else {
        print('Server Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Connection Error: $e');
      return false;
    }
  }
}
