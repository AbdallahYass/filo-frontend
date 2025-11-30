// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/cart_service.dart';

class ItemDetailScreen extends StatefulWidget {
  final MenuItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _quantity = 1;
  final CartService _cartService = CartService();
  bool _isEditing = false; // لمعرفة هل نحن نعدل طلب موجود أم نطلب جديد

  @override
  void initState() {
    super.initState();
    // 🔍 فحص السلة عند فتح الشاشة
    int currentQty = _cartService.getQuantity(widget.item.id);
    if (currentQty > 0) {
      _quantity = currentQty; // إذا موجود، ابدأ من العدد الحالي
      _isEditing = true; // نحن الآن في وضع التعديل
    } else {
      _quantity = 1; // إذا جديد، ابدأ من 1
      _isEditing = false;
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  double _calculateTotalPrice() {
    return widget.item.price * _quantity;
  }

  void _handleOrder() {
    // نستخدم updateQuantity بدلاً من add لضمان أن الرقم الذي اخترناه هو الذي سيُعتمد
    _cartService.updateQuantity(widget.item, _quantity);

    String message = _isEditing
        ? 'تم تحديث الكمية إلى $_quantity'
        : 'تم إضافة $_quantity من ${widget.item.title} للسلة';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 1),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // صورة الطبق
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.item.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            // تظليل خفيف للصورة لكي يظهر زر الرجوع
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  stops: const [0.0, 0.3],
                ),
              ),
            ),
          ),

          // التفاصيل
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A), // خلفية سوداء
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.item.price.toStringAsFixed(2)} \$',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFFC5A028),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(height: 30, color: Colors.grey),
                  const Text(
                    'الوصف:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),

          // شريط التحكم بالكمية والإضافة
          _buildBottomOrderBar(),
        ],
      ),
    );
  }

  Widget _buildBottomOrderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC5A028).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle,
                  color: Colors.redAccent,
                  size: 30,
                ),
                onPressed: _decrementQuantity,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  _quantity.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 30,
                ),
                onPressed: _incrementQuantity,
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5A028),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                // تغيير نص الزر حسب الحالة (إضافة أو تحديث)
                _isEditing
                    ? 'تحديث الطلب | ${_calculateTotalPrice().toStringAsFixed(2)} \$'
                    : 'أضف للسلة | ${_calculateTotalPrice().toStringAsFixed(2)} \$',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
