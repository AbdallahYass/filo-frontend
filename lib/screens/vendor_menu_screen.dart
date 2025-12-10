// lib/screens/vendor_menu_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import 'item_detail_screen.dart';
import 'cart_screen.dart';

class VendorMenuScreen extends StatefulWidget {
  final UserModel vendor; // 🔥 التاجر الذي تم اختياره

  const VendorMenuScreen({super.key, required this.vendor});

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkColor = const Color(0xFF1A1A1A);
  final Color _lightBackground = const Color(0xFFF9F9F9);

  // لفلترة العناصر ضمن قائمة التاجر
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // 🚀 جلب قائمة الطعام الخاصة بالتاجر باستخدام ID التاجر
    _menuItemsFuture = _menuService.fetchMenu(vendorId: widget.vendor.id);
  }

  Future<void> _refreshData() async {
    setState(() {
      _menuItemsFuture = _menuService.fetchMenu(vendorId: widget.vendor.id);
    });
  }

  // ----------------------------------------------------
  // 🎨 دوال بناء الواجهة المساعدة 🎨
  // ----------------------------------------------------

  // بناء شريط البحث
  Widget _buildSearchBar(AppLocalizations localizations) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: localizations.searchHint,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _goldColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // بناء قائمة الفئات الأفقية للتصفية
  Widget _buildCategoryList(List<String> categories, String allKey) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          // 🔥 تصحيح: يجب استخدام مفتاح 'All' للمقارنة إذا كنا نعتمد على الترجمة
          final isSelected = category == 'All'
              ? _selectedCategory == allKey
              : _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                // حفظ القيمة الأصلية أو المترجمة
                _selectedCategory = category == 'All' ? allKey : category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _goldColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                category == 'All' ? allKey : category, // 🔥 ترجمة "الكل" فقط
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // كارت العنصر البارز
  Widget _buildFeaturedCard(MenuItem item, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
      ),
      child: Container(
        height: 220,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: _darkColor,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(item.imageUrl),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  localizations.order,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 15,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "\$${item.price.toStringAsFixed(2)}",
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // كارت العنصر العادي
  Widget _buildMenuItemCard(MenuItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                item.imageUrl,
                height: 140,
                width: 160,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.description,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "\$${item.price.toStringAsFixed(2)}",
              style: TextStyle(
                color: _goldColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 🔨 دالة البناء الرئيسية (Build) 🔨
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final String allKey = localizations.all;

    // 🔥 تصحيح: إذا كان 'All' هو الفئة المحددة، استخدم القيمة المترجمة
    if (_selectedCategory == 'All') {
      _selectedCategory = allKey;
    }

    final String displayStoreName =
        widget.vendor.storeInfo?.storeName ??
        widget.vendor.name ??
        localizations.vendorDefaultName;

    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: _darkColor,
        elevation: 0,
        centerTitle: true,
        // 🔥 اسم المتجر في العنوان
        title: Text(
          displayStoreName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        foregroundColor: _goldColor,
        actions: [
          // زر السلة
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: _goldColor,
        backgroundColor: _darkColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 شريط البحث في الأعلى 🔥
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  top: 10,
                ),
                decoration: BoxDecoration(
                  color: _darkColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: _buildSearchBar(localizations),
              ),
              const SizedBox(height: 20),

              // 🔥🔥🔥 FutureBuilder لعرض القائمة 🔥🔥🔥
              FutureBuilder<List<MenuItem>>(
                future: _menuItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _goldColor),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty) {
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          localizations.noMenuItems,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localizations.connectionError,
                            style: TextStyle(color: Colors.red),
                          ),
                          TextButton(
                            onPressed: _refreshData,
                            child: Text(localizations.retry),
                          ),
                        ],
                      ),
                    );
                  }

                  final allItems = snapshot.data!;

                  // 1. استخراج الفئات المتاحة من عناصر التاجر
                  Set<String> categoryKeys = {'All'};
                  for (var item in allItems) {
                    categoryKeys.add(item.category);
                  }

                  // 2. فلترة العناصر بناءً على الفئة المختارة
                  final filteredItems = _selectedCategory == allKey
                      ? allItems
                      : allItems
                            .where((item) => item.category == _selectedCategory)
                            .toList();

                  // 3. التحقق من وجود عناصر بعد الفلترة
                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Text(
                        localizations.noItemsFound,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // قائمة الفئات الأفقية للتصفية
                      _buildCategoryList(categoryKeys.toList(), allKey),
                      const SizedBox(height: 20),

                      // العنصر المميز (Featured)
                      _buildFeaturedCard(filteredItems.first, localizations),
                      const SizedBox(height: 25),

                      // عنوان "الأكثر شيوعاً" أو الفئة
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          _selectedCategory == allKey
                              ? localizations.popularNow
                              : _selectedCategory,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 🔥🔥 قائمة العناصر الأفقية المتبقية (تجاهل العنصر الأول المميز) 🔥🔥
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          // itemCount: إجمالي العناصر ما عدا العنصر الأول
                          itemCount: filteredItems.length > 1
                              ? filteredItems.length - 1
                              : 0,
                          itemBuilder: (context, index) {
                            // نبدأ من العنصر الثاني في القائمة (index + 1)
                            final item = filteredItems[index + 1];
                            return _buildMenuItemCard(item);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ), // نهاية FutureBuilder
            ],
          ),
        ),
      ),
    );
  }
}
