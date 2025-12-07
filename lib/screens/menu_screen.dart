// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart'; // للتحقق من المنصة (ويب/موبايل)
import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../services/cart_service.dart'; // لا تنس استيراد خدمة السلة
import 'item_detail_screen.dart';
import 'cart_screen.dart';
import 'all_items_screen.dart';
import 'qr_scanner_screen.dart'; // استيراد الماسح الضوئي
import 'qr_generator_screen.dart';
import 'settings_screen.dart'; // استيراد المولد

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkColor = const Color(0xFF1A1A1A);

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _menuService.fetchMenu();

    // 👇 كود خاص بالويب: قراءة رقم الطاولة من الرابط
    if (kIsWeb) {
      // نستخدم Uri.base لقراءة الرابط الحالي في المتصفح
      final uri = Uri.base;
      // هل الرابط يحتوي على '?table=5' مثلاً؟
      if (uri.queryParameters.containsKey('table')) {
        final tableNum = uri.queryParameters['table'];
        if (tableNum != null) {
          // نحفظ الرقم في خدمة السلة ليتم إرساله مع الطلب لاحقاً
          CartService().setTableNumber(tableNum);
          if (kDebugMode) {
            print("Web: Customer is on Table $tableNum");
          }
        }
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _menuItemsFuture = _menuService.fetchMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: _darkColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // زر الماسح الضوئي (يظهر فقط في الموبايل)
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

          // زر توليد الكود (مؤقت للتجربة)
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

          IconButton(
            icon: const Icon(Icons.settings),
            color: const Color(0xFFC5A028), // لون الذهب
            onPressed: () {
              // عند الضغط، انتقل إلى شاشة الإعدادات
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
              // 👇 بانر تحميل التطبيق (يظهر فقط في الويب)
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
                      const Expanded(
                        child: Text(
                          "احصل على تجربة أفضل مع التطبيق!",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // هنا تضع رابط المتجر
                          // html.window.open('LINK_TO_APP_STORE', '_blank');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _goldColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          minimumSize: const Size(0, 30), // زر صغير
                        ),
                        child: const Text(
                          "حمل الآن",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // 👆 نهاية البانر

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
                child: _buildSearchBar(),
              ),

              const SizedBox(height: 20),

              // المحتوى
              FutureBuilder<List<MenuItem>>(
                future: _menuItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _goldColor),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final allItems = snapshot.data!;

                    Set<String> categories = {'All'};
                    for (var item in allItems) {
                      categories.add(item.category);
                    }

                    final filteredItems = _selectedCategory == 'All'
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

                        if (filteredItems.isEmpty)
                          const Center(child: Text("No items found"))
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: _buildFeaturedCard(filteredItems.first),
                              ),

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
                                      _selectedCategory == 'All'
                                          ? "Popular Now"
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
                                        "See All",
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
                                    return _buildRestaurantCard(item);
                                  },
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          const Text("حدث خطأ في الاتصال"),
                          TextButton(
                            onPressed: _refreshData,
                            child: const Text("إعادة المحاولة"),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text("No menu items available"));
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: _goldColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

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

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey),
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

  Widget _buildFeaturedCard(MenuItem item) {
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
                child: const Text(
                  "Order",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                Text(
                  "5.0",
                  style: TextStyle(
                    color: _goldColor,
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
}
