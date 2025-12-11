// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart'; // 👈 استيراد اللغات
import '../../models/menu_item.dart';
import 'item_detail_screen.dart';

class AllItemsScreen extends StatefulWidget {
  final List<MenuItem> allItems;
  final String initialCategory;

  const AllItemsScreen({
    super.key,
    required this.allItems,
    required this.initialCategory,
  });

  @override
  State<AllItemsScreen> createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
  // الألوان
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);
  final Color _cardBackground = const Color(0xFF333333);

  // المتغير الذي يحمل التصنيف المختار حالياً
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // نبدأ بالتصنيف الذي اختاره المستخدم في الصفحة السابقة
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 الوصول لكائن الترجمة 🔥
    final localizations = AppLocalizations.of(context)!;
    final String allKey = localizations.all; // الحصول على الترجمة لكلمة "الكل"

    // 1. استخراج كل التصنيفات الموجودة من القائمة
    Set<String> categories = {allKey}; // 👈 استخدام المفتاح المترجم
    for (var item in widget.allItems) {
      categories.add(item.category);
    }
    List<String> categoryList = categories.toList();

    // 2. فلترة العناصر بناءً على التصنيف المختار حالياً
    final displayItems =
        _selectedCategory ==
            allKey // 👈 مقارنة بالمفتاح المترجم
        ? widget.allItems
        : widget.allItems
              .where((item) => item.category == _selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(
          localizations.menu, // 👈 نص مترجم
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: _goldColor),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),

          // 3. شريط التصنيفات (Categories Bar)
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 15),
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                final category = categoryList[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _goldColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? _goldColor : Colors.grey.shade700,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 15),

          // 4. شبكة المنتجات (GridView)
          Expanded(
            child: displayItems.isEmpty
                ? Center(
                    child: Text(
                      localizations.noItemsFound, // 👈 نص مترجم
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(15.0),
                    itemCount: displayItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      return _buildGridCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, MenuItem item) {
    // 🔥 هذا الـ Widget لا يحتاج إلى الترجمة الآن، لأنه يعرض بيانات (title, price) من الموديل
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  item.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // التفاصيل
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Price formatting
                        '${item.price.toStringAsFixed(2)} \$',
                        style: TextStyle(
                          color: _goldColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _goldColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
