// lib/screens/vendor_list_screen.dart

// 🚀 هذا الملف يعرض قائمة التجار (Vendors) التابعين لفئة معينة، مع دعم البحث والفرز.

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart'; // مسار الترجمة الصحيح
import '../../models/user_model.dart';
import '../../services/vendor_service.dart';
import 'vendor_menu_screen.dart';

class VendorListScreen extends StatefulWidget {
  final String categoryKey;
  final String categoryName;

  const VendorListScreen({
    super.key,
    required this.categoryKey,
    required this.categoryName,
  });

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  // 🔥🔥 1. إدارة الحالة والمتحكمات 🔥🔥
  final VendorService _vendorService = VendorService();
  late Future<List<UserModel>> _vendorsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _selectedSortKey = 'default';
  late List<Map<String, String>> _sortOptions; // خيارات الفرز

  // 🎨 تعريف الألوان والثوابت 🎨
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(
    0xFFF9F9F9,
  ); // الخلفية الفاتحة (Body)
  final Color _darkColor = const Color(0xFF1A1A1A); // اللون الداكن (AppBar)
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _vendorsFuture = _vendorService.fetchVendorsByCategory(widget.categoryKey);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _vendorsFuture = _vendorService.fetchVendorsByCategory(
        widget.categoryKey,
        sortBy: _selectedSortKey,
      );
    });
  }

  // ----------------------------------------------------
  // 🎨 دوال بناء الواجهة المساعدة 🎨
  // ----------------------------------------------------

  // 🔥 بناء شريط البحث (مدمج في البانر الداكن)
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.searchVendorHint,
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

  // بناء القائمة المنسدلة للفرز
  Widget _buildSortDropdown(AppLocalizations localizations) {
    _sortOptions = [
      {'key': 'default', 'label': localizations.sortByDefault},
      {'key': 'popular', 'label': localizations.sortByPopular},
      {'key': 'rating', 'label': localizations.sortByRating},
    ];

    // 🔥 تعديل تصميم الـ Dropdown ليكون أبيض بخلفية داكنة (كما في شاشة الفئات)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, // لون خلفية الـ Dropdown أبيض
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSortKey,
          icon: Icon(Icons.sort, color: _goldColor),
          // نصوص القائمة ستكون باللون الداكن ليظهر فوق الخلفية البيضاء
          style: TextStyle(color: _darkColor, fontSize: 14),
          dropdownColor: Colors.white,
          items: _sortOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['key'],
              child: Text(
                option['label']!,
                style: TextStyle(color: _darkColor),
              ),
            );
          }).toList(),
          onChanged: (newKey) {
            if (newKey != null) {
              setState(() {
                _selectedSortKey = newKey;
              });
              _refreshData();
            }
          },
        ),
      ),
    );
  }

  // 🔥 بناء بطاقة التاجر/المتجر (يبقى التصميم الداخلي كما هو)
  Widget _buildVendorCard(UserModel vendor, AppLocalizations localizations) {
    final String storeName =
        vendor.storeInfo?.storeName ??
        vendor.name ??
        localizations.vendorDefaultName;
    final String description =
        vendor.storeInfo?.description ?? localizations.vendorDefaultDescription;
    final bool isOpen = vendor.storeInfo?.isOpen == true;

    final double rating = vendor.averageRating;
    final int reviews = vendor.reviewsCount;

    final Color statusColor = isOpen ? Colors.green : Colors.red;
    final String statusText = isOpen
        ? (localizations.storeOpen)
        : (localizations.storeClosed);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorMenuScreen(vendor: vendor),
          ),
        );
      },
      child: Card(
        color: _cardColor,
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (صورة/لوجو التاجر) ...
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  vendor.storeInfo?.logoUrl ??
                      'https://placehold.co/60x60/888888/FFFFFF?text=Logo',
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 60,
                    width: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.store, color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // شريط التقييم والمراجعات
                    Row(
                      children: [
                        Icon(Icons.star, color: _goldColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${reviews} ${localizations.reviews})',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // حالة المتجر
                    Row(
                      children: [
                        Icon(
                          isOpen ? Icons.check_circle : Icons.access_time,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(widget.categoryName),
        // 🔥 توحيد التصميم: جعل الـ AppBar داكناً ليتوافق مع النمط الرئيسي
        backgroundColor: _darkColor,
        foregroundColor: Colors.white, // جعل النص أبيض
        elevation: 0,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥🔥 1. دمج شريط البحث وشريط الفرز في بانر واحد (مثل شاشة الفئات) 🔥🔥
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
              top: 10,
            ),
            decoration: BoxDecoration(
              color: _darkColor, // خلفية داكنة للبانر
              borderRadius: const BorderRadius.only(
                // زوايا سفلية مستديرة (مثل شاشة الفئات)
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // شريط البحث
                _buildSearchBar(localizations),
                const SizedBox(height: 15),

                // شريط الفرز داخل البانر الداكن
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      localizations.sortBy,
                      // النص أصبح أبيض (أو رمادي فاتح) ليظهر على الخلفية الداكنة
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSortDropdown(
                      localizations,
                    ), // الـ Dropdown سيظل أبيض (عناصر الـ Dark Mode)
                  ],
                ),
              ],
            ),
          ),

          // 2. قائمة التجار (Expanded)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: _goldColor,
              child: FutureBuilder<List<UserModel>>(
                future: _vendorsFuture,
                builder: (context, snapshot) {
                  // ... (معالجة حالات التحميل، الخطأ، والقائمة الفارغة) ...

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _goldColor),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
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
                    );
                  }

                  final allVendors = snapshot.data!;
                  final filteredVendors = allVendors.where((vendor) {
                    final name =
                        (vendor.storeInfo?.storeName ?? vendor.name ?? '')
                            .toLowerCase();
                    final description = (vendor.storeInfo?.description ?? '')
                        .toLowerCase();
                    return name.contains(_searchQuery) ||
                        description.contains(_searchQuery);
                  }).toList();

                  if (filteredVendors.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        localizations.noResultsFound,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (filteredVendors.isEmpty) {
                    return Center(
                      child: Text(
                        localizations.noVendorsFound(widget.categoryName),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // ✅ عرض قائمة التجار المفلترة
                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: filteredVendors.length,
                    itemBuilder: (context, index) {
                      return _buildVendorCard(
                        filteredVendors[index],
                        localizations,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
