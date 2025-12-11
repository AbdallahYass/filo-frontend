// lib/screens/vendor_menu_screen.dart

// 🚀 هذا الملف يعرض قائمة طعام متجر معين، مع دعم الفلترة حسب الفئة والعرض المميز.

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart'; // مسار الترجمة الصحيح
import '../../models/user_model.dart';
import '../../models/menu_item.dart';
import '../../services/menu_service.dart';
import 'item_detail_screen.dart';
import '../cart_screen.dart';

class VendorMenuScreen extends StatefulWidget {
  final UserModel vendor; // 🔥 التاجر الذي تم اختياره

  const VendorMenuScreen({super.key, required this.vendor});

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  // 🔥🔥 1. إدارة الحالة والمتحكمات 🔥🔥
  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();

  // لفلترة العناصر ضمن قائمة التاجر
  String _selectedCategory = 'All'; // القيمة الافتراضية قبل الترجمة

  // 🎨 تعريف الألوان والثوابت 🎨
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkColor = const Color(0xFF1A1A1A);
  final Color _lightBackground = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    // 🚀 جلب قائمة الطعام الخاصة بالتاجر باستخدام ID التاجر
    _menuItemsFuture = _menuService.fetchMenu(vendorId: widget.vendor.id);
  }

  // 🔄 دالة تحديث البيانات
  Future<void> _refreshData() async {
    setState(() {
      _menuItemsFuture = _menuService.fetchMenu(vendorId: widget.vendor.id);
    });
  }

  // ----------------------------------------------------
  // 🎨 دوال بناء الواجهة المساعدة 🎨
  // ----------------------------------------------------

  // بناء شريط البحث العلوي (نفس تصميم الشاشات السابقة)
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
              // 💡 يمكن إضافة متحكم بحث هنا إذا لزم الأمر، حاليًا هو placeholder
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
          // 💡 يتم تمرير مفاتيح الفئات (الاسم الإنجليزي أو المفتاح)
          final categoryKey = categories[index];
          // إذا كان المفتاح هو 'All'، نستخدم القيمة المترجمة للمقارنة والعرض
          final isAll = categoryKey == 'All';

          final isSelected = isAll
              ? _selectedCategory == allKey
              : _selectedCategory == categoryKey;

          return GestureDetector(
            onTap: () {
              setState(() {
                // نحفظ المفتاح الأصلي ('All') أو مفتاح الفئة
                _selectedCategory = isAll ? allKey : categoryKey;
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
                isAll ? allKey : categoryKey, // عرض الترجمة للـ "الكل"
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔥 بناء كارت العنصر البارز (Featured Item Card)
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

  // 🔥 بناء كارت العنصر العادي (Grid/Horizontal List Item)
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
                // 💡 إضافة placeholder عند الخطأ لضمان استمرارية التصميم
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.fastfood, color: Colors.grey[600]),
                ),
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
    final String allKey = localizations.all; // القيمة المترجمة لـ "الكل"

    // 💡 تحديث الفئة المختارة إلى القيمة المترجمة (للاستخدام في الفلترة)
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
        // 🔥 تصميم الـ AppBar باللون الغامق
        backgroundColor: _darkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          displayStoreName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        foregroundColor: _goldColor, // لون زر الرجوع
        actions: [
          // زر السلة
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
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
              // 🔥 البانر العلوي الذي يحتوي على شريط البحث
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
                    // ❌ معالجة حالة الخطأ
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.hasError
                                  ? localizations.connectionError
                                  : localizations.noMenuItems,
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: _refreshData,
                              child: Text(localizations.retry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final allItems = snapshot.data!;

                  // 1. استخراج الفئات المتاحة
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
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // قائمة الفئات الأفقية للتصفية
                      _buildCategoryList(categoryKeys.toList(), allKey),
                      const SizedBox(height: 20),

                      // العنصر المميز (Featured) - هو أول عنصر في القائمة
                      _buildFeaturedCard(filteredItems.first, localizations),
                      const SizedBox(height: 25),

                      // عنوان "الأكثر شيوعاً" أو الفئة المختارة
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

                      // 🔥🔥 قائمة العناصر الأفقية المتبقية 🔥🔥
                      SizedBox(
                        height: 220, // ارتفاع ثابت للقائمة الأفقية
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          // إجمالي العناصر ما عدا العنصر الأول
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
