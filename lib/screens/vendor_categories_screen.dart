// lib/screens/vendor_categories_screen.dart (اسم الملف الجديد)

// 🚀 هذا الملف يمثل الشاشة الرئيسية للتطبيق، ويعرض فئات التجار ديناميكياً.

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../models/category_model.dart'; // 🔥 استيراد الموديل الجديد
import '../services/category_service.dart'; // 🔥 استيراد الخدمة الجديدة
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'settings_screen.dart';
// يجب استيراد الشاشة التالية الآن
//import 'vendor_list_screen.dart';

// 🔥🔥 يجب أن يكون هذا الكلاس في ملف vendor_categories_screen.dart 🔥🔥
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // 🔥🔥🔥 حالة التنقل السفلية: 0 (Categories), 1 (Settings) 🔥🔥🔥
  int _currentIndex = 0;

  // 🔥🔥 جلب الفئات بدلاً من عناصر القائمة 🔥🔥
  late Future<List<CategoryModel>> _categoriesFuture;
  final CategoryService _categoryService = CategoryService();

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkColor = const Color(0xFF1A1A1A);
  final Color _lightBackground = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    // بدء جلب الفئات من الخادم
    _categoriesFuture = _categoryService.fetchCategories();

    // منطق خاص ببدء تشغيل الويب
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

  // دالة تغيير التبويب
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // دالة تحديث بيانات الفئات (تستخدم مع RefreshIndicator)
  Future<void> _refreshData() async {
    setState(() {
      _categoriesFuture = _categoryService.fetchCategories();
    });
  }
  /*
  // 🔥🔥 الانتقال إلى شاشة قائمة التجار عند اختيار فئة 🔥🔥
  void _navigateToVendorList(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorListScreen(
          categoryKey: category.key,
          categoryName: category.name,
        ),
      ),
    );
  }
*/
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

  // 🔥🔥 دالة بناء بطاقة الفئة (بدلاً من كروت الطعام القديمة) 🔥🔥
  Widget _buildCategoryCard(CategoryModel category) {
    // 💡 دالة بسيطة لتحويل اسم الأيقونة النصي (المحفوظ في DB) إلى IconData
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
      //  onTap: () => _navigateToVendorList(category),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(getIconData(category.icon), color: _goldColor, size: 40),
            const SizedBox(height: 10),
            Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥🔥 دالة محتوى الشاشة الرئيسية (الفئات) 🔥🔥
  Widget _buildCategoriesContentWrapper() {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: _darkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          localizations.menu, // "القائمة" كعنوان لاستكشاف الفئات
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // زر السلة (تم الإبقاء عليه في الأعلى)
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
                    // رسالة خطأ الاتصال أو حالة لا يوجد فئات
                    final categories = snapshot.data;

                    if (categories != null && categories.isNotEmpty) {
                      // في حال أرجع الـ Mock data
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
                            const SizedBox(height: 10),
                            /*    Text(
                              localizations.noVendorsFound(localizations.menu),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),*/
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

  // 🔥 دالة مساعدة لعرض الـ GridView (لتبسيط FutureBuilder)
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
            return _buildCategoryCard(categories[index]);
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
    // تهيئة الصفحات (0: Categories, 1: Settings)
    final List<Widget> pages = [
      _buildCategoriesContentWrapper(), // Index 0
      const SettingsScreen(), // Index 1
    ];

    return Scaffold(
      backgroundColor: _darkColor,
      body: IndexedStack(index: _currentIndex, children: pages),
      // شريط التنقل السفلي المعدل (تبويبين فقط)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: _goldColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
