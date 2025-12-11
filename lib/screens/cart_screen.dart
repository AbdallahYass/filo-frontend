// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart'; // 👈 استيراد اللغات
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import 'Home/item_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  // الألوان الخاصة بالتصميم
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);
  final Color _cardBackground = const Color(0xFF333333);

  void _updateScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 الوصول لكائن الترجمة 🔥
    final localizations = AppLocalizations.of(context)!;

    final items = _cartService.items;
    final totalPrice = _cartService.totalPrice;

    return Scaffold(
      backgroundColor: _darkBackground, // خلفية سوداء
      appBar: AppBar(
        title: Text(
          localizations.myCart, // 👈 نص مترجم
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black, // شريط أسود
        centerTitle: true,
        iconTheme: IconThemeData(color: _goldColor), // زر الرجوع ذهبي
        elevation: 0,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.cartEmpty, // 👈 نص مترجم (السلة فارغة)
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItemCard(
                        item,
                        localizations,
                      ); // تمرير localizations
                    },
                  ),
                ),
                _buildCheckoutBar(
                  totalPrice,
                  localizations,
                ), // تمرير localizations
              ],
            ),
    );
  }

  Widget _buildCartItemCard(CartItem cartItem, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(item: cartItem.item),
          ),
        );
        _updateScreen();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                cartItem.item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[800],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${cartItem.totalItemPrice.toStringAsFixed(2)} \$',
                    style: TextStyle(
                      color: _goldColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _goldColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    'x${cartItem.quantity}',
                    style: TextStyle(
                      color: _goldColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    _cartService.removeItem(cartItem.item.id);
                    _updateScreen();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizations.itemRemoved, // 👈 نص مترجم
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(double total, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _goldColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.total, // 👈 نص مترجم
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} \$',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _goldColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: total > 0
                  ? () async {
                      // 1. إظهار مؤشر تحميل
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => Center(
                          child: CircularProgressIndicator(color: _goldColor),
                        ),
                      );

                      // 2. إرسال الطلب للسيرفر
                      bool success = await _cartService.placeOrder();

                      // 3. إغلاق مؤشر التحميل
                      Navigator.of(context).pop();

                      if (success) {
                        // 4. إذا نجح: تحديث الشاشة وإظهار رسالة
                        _updateScreen();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor:
                                Colors.grey[900], // خلفية غامقة للرسالة
                            title: Text(
                              localizations.orderPlacedTitle, // 👈 نص مترجم
                              style: const TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              localizations
                                  .orderPlacedSuccessMsg, // 👈 نص مترجم
                              style: const TextStyle(color: Colors.grey),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(
                                  localizations.ok, // 👈 نص مترجم
                                  style: TextStyle(color: _goldColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 5. إذا فشل: إظهار رسالة خطأ
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              localizations.orderFailed, // 👈 نص مترجم
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Text(
                localizations.checkout, // 👈 نص مترجم
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
