// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart'; // 👈 استيراد اللغات
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
  // 🔥🔥🔥 حالة التنقل السفلية 🔥🔥🔥
  int _currentIndex = 0;

  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkColor = const Color(0xFF1A1A1A);

  // تحديث هذه القيمة بناءً على الـ localizations.all في كل build
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _menuService.fetchMenu();

    // كود خاص بالويب (Web initialization)
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
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _menuItemsFuture = _menuService.fetchMenu();
    });
  }

  // دالة إنشاء Placeholder - تستخدم الترجمة الموضعية
  Widget _buildPlaceholderScreen(String title) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _darkColor,
      appBar: AppBar(
        // بما أن title يأتي مترجماً من دالة build، نستخدمه مباشرة هنا
        title: Text(title, style: TextStyle(color: _goldColor)),
        backgroundColor: _darkColor,
      ),
      body: Center(
        child: Text(
          // 🔥🔥 التصحيح هنا: استدعاء الدالة المولّدة مباشرة 🔥🔥
          localizations.screenTitlePlaceholder(title),

          // ملاحظة: لكي يعمل هذا، يجب أن يكون المفتاح في ملف .arb معرفاً هكذا:
          // "screenTitlePlaceholder": "{title} Screen",
          // "@screenTitlePlaceholder": { "placeholders": { "title": {} } }
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // دالة محتوى الشاشة الرئيسية - تستخدم الترجمة الموضعية
  Widget _buildMenuContentWrapper() {
    final localizations = AppLocalizations.of(context)!;
    final String allKey = localizations.all;

    // تحديث الـ selectedCategory عند تغيير اللغة
    if (_selectedCategory == 'All') {
      _selectedCategory = allKey;
    }

    // ... (بقية المحتوى مع استدعاء الدوال المساعدة)
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: _darkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          localizations.home, // 🔥 ترجمة
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
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
                          localizations.getBetterAppExperience, // 🔥 ترجمة
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
                          localizations.downloadNow, // 🔥 ترجمة
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                child: _buildSearchBar(), // سيتم التعامل مع الترجمة داخله
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<MenuItem>>(
                future: _menuItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _goldColor),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final allItems = snapshot.data!;

                    // 1. ترجمة مفتاح 'All'
                    Set<String> categories = {allKey};
                    for (var item in allItems) {
                      categories.add(item.category);
                    }

                    // 2. فلترة العناصر بناءً على المفتاح المترجم
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
                        _buildCategoryList(
                          categories.toList(),
                        ), // سيتم التعامل مع الترجمة داخله
                        const SizedBox(height: 20),
                        if (filteredItems.isEmpty)
                          Center(
                            child: Text(localizations.noItemsFound),
                          ) // 🔥 ترجمة
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: _buildFeaturedCard(filteredItems.first),
                              ), // سيتم التعامل مع الترجمة داخله
                              const SizedBox(height: 25),
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
                                          ? localizations
                                                .popularNow // 🔥 ترجمة
                                          : _selectedCategory,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
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
                                        localizations.seeAll, // 🔥 ترجمة
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
                                    return _buildRestaurantCard(
                                      item,
                                    ); // سيتم التعامل مع الترجمة داخله
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
                          Text(localizations.connectionError), // 🔥 ترجمة
                          TextButton(
                            onPressed: _refreshData,
                            child: Text(localizations.retry), // 🔥 ترجمة
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Text(localizations.noMenuItems),
                  ); // 🔥 ترجمة
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- دوال بناء الواجهة المساعدة (تطبيق الترجمة الموضعية) ---
  Widget _buildSearchBar() {
    // 🔥 ترجمة موضعية 🔥
    final localizations = AppLocalizations.of(context)!;

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
                hintText: localizations.searchHint, // 🔥 ترجمة
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

  Widget _buildCategoryList(List<String> categories) {
    // 🔥 ترجمة موضعية 🔥

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

  Widget _buildFeaturedCard(MenuItem item) {
    // 🔥 ترجمة موضعية 🔥
    final localizations = AppLocalizations.of(context)!;

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
                  localizations.order, // 🔥 ترجمة
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

  Widget _buildRestaurantCard(MenuItem item) {
    // 🔥 ترجمة موضعية 🔥

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

  @override
  Widget build(BuildContext context) {
    // 🔥 الوصول لكائن الترجمة 🔥
    final localizations = AppLocalizations.of(context)!;

    // تهيئة الصفحات بالاعتماد على الـ build context
    final List<Widget> pages = [
      _buildMenuContentWrapper(),
      _buildPlaceholderScreen(localizations.searchHint),
      _buildPlaceholderScreen(localizations.myCart),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: _darkColor,

      // 🔥 الجسم الرئيسي يستخدم IndexedStack لعرض المحتوى بناءً على التبويب
      body: IndexedStack(index: _currentIndex, children: pages),

      // 🔥 شريط التنقل السفلي المعدل
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1A1A), // خلفية الشريط
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
          ), // Home/Menu
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ), // Search
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: '',
          ), // Cart
          // 🔥 استبدال أيقونة الشخص بالإعدادات 🔥
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ), // Settings
        ],
      ),
    );
  }
}
