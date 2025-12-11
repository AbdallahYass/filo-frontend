// lib/screens/vendor_categories_screen.dart

// 🚀 هذا الملف يمثل الشاشة الرئيسية للتطبيق، ويعرض فئات التجار ديناميكياً.

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
//import 'settings_screen.dart';
import 'vendor_list_screen.dart';

// 🔥🔥 تصحيح اسم الكلاس ليتوافق مع الملف 🔥🔥
class VendorCategoriesScreen extends StatefulWidget {
  const VendorCategoriesScreen({super.key});

  @override
  State<VendorCategoriesScreen> createState() => _VendorCategoriesScreenState();
}

class _VendorCategoriesScreenState extends State<VendorCategoriesScreen> {
  // ❌ حذف _currentIndex لأنه يتم إدارته في الـ Wrapper

  late Future<List<CategoryModel>> _categoriesFuture;
  final CategoryService _categoryService = CategoryService();

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkColor = const Color(0xFF1A1A1A);
  final Color _lightBackground = const Color(0xFFF9F9F9);

  // 🔥🔥🔥 مصفوفة الألوان (بيضاء) 🔥🔥🔥
  final List<Color> _categoryColors = const [
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.fetchCategories();

    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('table')) {
        final tableNum = uri.queryParameters['table'];
        if (tableNum != null) {
          CartService().setTableNumber(tableNum);
        }
      }
    }
  }

  // ❌ حذف _onItemTapped لأنه يتم إدارته في الـ Wrapper

  Future<void> _refreshData() async {
    setState(() {
      _categoriesFuture = _categoryService.fetchCategories();
    });
  }

  // 🔥🔥 الانتقال إلى شاشة قائمة التجار (تم تفعيل الدالة) 🔥🔥
  void _navigateToVendorList(CategoryModel category) {
    // نستخدم rootNavigator: false إذا كنا نريد إبقاء الشريط ثابتاً،
    // ولكن الطريقة الأكثر نظافة هي الاعتماد على Navigator العادي داخل Shell
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorListScreen(
          categoryKey: category.key,
          categoryName: _getCategoryDisplayName(category, context),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 🔥🔥 الدالة الجديدة: تحديد الاسم بناءً على اللغة 🔥🔥
  // ----------------------------------------------------
  String _getCategoryDisplayName(CategoryModel category, BuildContext context) {
    final currentLocale = AppLocalizations.of(context)!.localeName;

    if (currentLocale == 'ar') {
      return category.nameAr;
    }
    return category.nameEn;
  }

  // ----------------------------------------------------
  // 🎨 دوال بناء الواجهة المساعدة 🎨
  // ----------------------------------------------------

  // بناء شريط البحث العلوي
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

  // 🔥🔥 دالة بناء بطاقة الفئة 🔥🔥
  Widget _buildCategoryCard(
    CategoryModel category,
    int index,
    AppLocalizations localizations,
  ) {
    final String translatedName = _getCategoryDisplayName(category, context);
    final Color cardColor = _categoryColors[index % _categoryColors.length];
    final Color contentColor = Colors.black87;
    final Color iconColor = _goldColor;

    // 💡 دالة تحويل اسم الأيقونة النصي
    IconData getIconData(String key) {
      switch (key) {
        case 'restaurant':
          return Icons.restaurant;
        case 'bakery':
          return Icons.bakery_dining;
        case 'market':
          return Icons.local_grocery_store;
        case 'cafe':
          return Icons.coffee;
        case 'pharmacy':
          return Icons.local_hospital;
        default:
          return Icons.category;
      }
    }

    return GestureDetector(
      onTap: () => _navigateToVendorList(category),
      child: Card(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(getIconData(category.icon), color: iconColor, size: 40),
            const SizedBox(height: 10),
            Text(
              translatedName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 دالة مساعدة لعرض الـ GridView
  Widget _buildCategoryGridView(
    List<CategoryModel> categories,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            localizations.menu,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(categories[index], index, localizations);
          },
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // 🔨 دالة البناء الرئيسية (Build) 🔨
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // 🔥🔥 إعادة هيكلة: هذا الكلاس أصبح يمثل محتوى الشاشة (Content Widget) 🔥🔥
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: _darkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          localizations.menu,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // زر السلة
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _goldColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
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
              // بانر الويب وشريط البحث
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // كود بانر الويب
                    if (kIsWeb)
                      Container(
                        width: double.infinity,
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone_android,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                localizations.getBetterAppExperience,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _goldColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                minimumSize: const Size(0, 30),
                              ),
                              child: Text(
                                localizations.downloadNow,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    _buildSearchBar(localizations),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🔥🔥 عرض شبكة فئات التجار (FutureBuilder) 🔥🔥
              FutureBuilder<List<CategoryModel>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: _goldColor),
                      ),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    final categories = snapshot.data;

                    if (categories != null && categories.isNotEmpty) {
                      return _buildCategoryGridView(categories, localizations);
                    }

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.connectionError,
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

                  final categories = snapshot.data!;
                  return _buildCategoryGridView(categories, localizations);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
