// lib/screens/menu_screen.dart

// 🚀 هذا الملف يمثل الشاشة الرئيسية للتطبيق (القائمة)
// ويحتوي على منطق التنقل الرئيسي بين الشاشات.

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../services/cart_service.dart';
import 'item_detail_screen.dart';
import 'cart_screen.dart';
import 'all_items_screen.dart';
import 'qr_scanner_screen.dart';
import 'qr_generator_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // 🔥🔥🔥 حالة التنقل السفلية: 0 (Menu), 1 (Settings) 🔥🔥🔥
  int _currentIndex = 0;

  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkColor = const Color(0xFF1A1A1A);

  // المتغير الذي يحمل الفئة المختارة للتصفية
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // بدء جلب قائمة الطعام من الخادم
    _menuItemsFuture = _menuService.fetchMenu();

    // منطق خاص ببدء تشغيل الويب: قراءة رقم الطاولة من الـ URL
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

  // دالة تغيير التبويب (للتبويبات المتبقية: 0 و 1)
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // دالة تحديث بيانات القائمة (تستخدم مع RefreshIndicator)
  Future<void> _refreshData() async {
    setState(() {
      _menuItemsFuture = _menuService.fetchMenu();
    });
  }

  // ----------------------------------------------------
  // 🎨 دوال بناء الواجهة المساعدة 🎨
  // ----------------------------------------------------

  // دالة بناء شاشة Placeholder (تستخدم لصفحات غير مكتملة)

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

  // بناء قائمة فئات الطعام الأفقية
  Widget _buildCategoryList(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _goldColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _goldColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                category,
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

  // كارت العنصر البارز/المميز (Featured Card)
  Widget _buildFeaturedCard(MenuItem item, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
      ),
      child: Container(
        height: 220,
        width: double.infinity,
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
            // زر الطلب/Order في الأسفل اليمين
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
            // العنوان والسعر في الأسفل اليسار
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

  // كارت المطعم/العنصر القصير (Restaurant Card)
  Widget _buildRestaurantCard(MenuItem item) {
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    item.imageUrl,
                    height: 140,
                    width: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      height: 140,
                      width: 160,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _goldColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flash_on,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: _goldColor, size: 14),
                const SizedBox(width: 4),
                const Text(
                  "5.0",
                  style: TextStyle(
                    color: Color(0xFFC5A028),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // دالة محتوى الشاشة الرئيسية (القائمة)
  Widget _buildMenuContentWrapper() {
    final localizations = AppLocalizations.of(context)!;
    final String allKey = localizations.all;

    if (_selectedCategory == 'All') {
      _selectedCategory = allKey;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: _darkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          localizations.home,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // أيقونة الماسح الضوئي (فقط على الموبايل)
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              },
            ),
          // أيقونة توليد الـ QR
          IconButton(
            icon: Icon(Icons.qr_code_2, color: _goldColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRGeneratorScreen(),
                ),
              );
            },
          ),
          // زر السلة (تم نقله إلى الـ AppBar)
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
              // بانر التطبيق على الويب
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
              // شريط البحث
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

              // محتوى القائمة الفعلية (FutureBuilder)
              FutureBuilder<List<MenuItem>>(
                future: _menuItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _goldColor),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final allItems = snapshot.data!;

                    // تهيئة الفئات
                    Set<String> categories = {allKey};
                    for (var item in allItems) {
                      categories.add(item.category);
                    }

                    // فلترة العناصر
                    final filteredItems = _selectedCategory == allKey
                        ? allItems
                        : allItems
                              .where(
                                (item) => item.category == _selectedCategory,
                              )
                              .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryList(categories.toList()),
                        const SizedBox(height: 20),

                        // حالة عدم وجود عناصر بعد الفلترة
                        if (filteredItems.isEmpty)
                          Center(child: Text(localizations.noItemsFound))
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // العنصر المميز الأول
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: _buildFeaturedCard(
                                  filteredItems.first,
                                  localizations,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // عنوان (Popular Now / Category Name)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedCategory == allKey
                                          ? localizations.popularNow
                                          : _selectedCategory,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    // زر (See All)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AllItemsScreen(
                                                  allItems: allItems,
                                                  initialCategory:
                                                      _selectedCategory,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        localizations.seeAll,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),

                              // قائمة العناصر الأفقية (Restaurant Cards)
                              SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(left: 20),
                                  itemCount: filteredItems.length > 1
                                      ? filteredItems.length - 1
                                      : 0,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index + 1];
                                    return _buildRestaurantCard(item);
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          Text(localizations.connectionError),
                          TextButton(
                            onPressed: _refreshData,
                            child: Text(localizations.retry),
                          ),
                        ],
                      ),
                    );
                  }
                  // حالة لا توجد عناصر menu (بعد التحميل)
                  return Center(child: Text(localizations.noMenuItems));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 🔨 دالة البناء الرئيسية (Build) 🔨
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // تهيئة الصفحات (تم حذف البحث والسلة)
    final List<Widget> pages = [
      _buildMenuContentWrapper(), // Index 0: Menu
      const SettingsScreen(), // Index 1: Settings
    ];

    return Scaffold(
      backgroundColor: _darkColor,

      // الجسم الرئيسي يستخدم IndexedStack لعرض المحتوى بناءً على التبويب
      body: IndexedStack(index: _currentIndex, children: pages),

      // 🔥 شريط التنقل السفلي المعدل (تبويبين فقط) 🔥
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '',
          ), // Home/Menu (Index 0)

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ), // Settings (Index 1)
        ],
      ),
    );
  }
}
