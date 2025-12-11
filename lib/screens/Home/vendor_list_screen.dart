// lib/screens/vendor_list_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
// نستخدم مسار الحزمة الكامل لضمان عدم وجود مشاكل في Vercel/Cache
import '/l10n/app_localizations.dart';
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
  final VendorService _vendorService = VendorService();
  late Future<List<UserModel>> _vendorsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _selectedSortKey = 'default';
  // 🔥🔥 تم تعديل هذا من late final إلى late فقط 🔥🔥
  late List<Map<String, String>> _sortOptions;

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFFF9F9F9);
  final Color _darkColor = const Color(0xFF1A1A1A);
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
    // لا نحتاج لـ _refreshData() هنا، لأن الفلترة تتم على الواجهة (Client-side)
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // 🔥 هذا سيعيد جلب البيانات من الخادم مع تطبيق خيار الفرز
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

  Widget _buildSortDropdown(AppLocalizations localizations) {
    // 🔥 تهيئة _sortOptions هنا (آمن الآن لأنها ليست final)
    _sortOptions = [
      {'key': 'default', 'label': localizations.sortByDefault},
      {'key': 'popular', 'label': localizations.sortByPopular},
      {'key': 'rating', 'label': localizations.sortByRating},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSortKey,
          icon: Icon(Icons.sort, color: _goldColor),
          style: TextStyle(color: _darkColor, fontSize: 14),
          dropdownColor: _cardColor,
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
              _refreshData(); // 🔥 إعادة جلب البيانات بالفرز الجديد
            }
          },
        ),
      ),
    );
  }

  // بناء كارت التاجر/المتجر
  Widget _buildVendorCard(UserModel vendor, AppLocalizations localizations) {
    final String storeName =
        vendor.storeInfo?.storeName ??
        vendor.name ??
        localizations.vendorDefaultName;
    final String description =
        vendor.storeInfo?.description ?? localizations.vendorDefaultDescription;
    final bool isOpen = vendor.storeInfo?.isOpen == true;

    // 🔥🔥 استخراج بيانات التقييم 🔥🔥
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
                    // 1. اسم المتجر
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

                    // 🔥🔥 2. شريط التقييم والمراجعات 🔥🔥
                    Row(
                      children: [
                        Icon(Icons.star, color: _goldColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1), // عرض التقييم (4.7)
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // عدد المراجعات
                        Text(
                          '(${reviews} ${localizations.reviews})', // نص مترجم لـ "مراجعات"
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 3. وصف المتجر
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // 4. حالة المتجر (مفتوح/مغلق)
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. شريط البحث
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
              top: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildSearchBar(localizations),
          ),

          // 2. شريط الفرز (Sorting)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  localizations.sortBy,
                  style: TextStyle(color: _darkColor, fontSize: 14),
                ),
                const SizedBox(width: 10),
                _buildSortDropdown(localizations),
              ],
            ),
          ),

          // 3. قائمة التجار (Expanded)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: _goldColor,
              child: FutureBuilder<List<UserModel>>(
                future: _vendorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _goldColor),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
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

                  final allVendors = snapshot.data!;

                  // 🔥🔥 تطبيق فلترة البحث (Client-side) 🔥🔥
                  final filteredVendors = allVendors.where((vendor) {
                    final name =
                        (vendor.storeInfo?.storeName ?? vendor.name ?? '')
                            .toLowerCase();
                    final description = (vendor.storeInfo?.description ?? '')
                        .toLowerCase();

                    return name.contains(_searchQuery) ||
                        description.contains(_searchQuery);
                  }).toList();

                  // 💡 التعامل مع حالة عدم وجود نتائج بحث/تجار
                  if (filteredVendors.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        localizations.noResultsFound,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (filteredVendors.isEmpty) {
                    return Center(
                      child: Text(
                        localizations.noVendorsFound(widget.categoryName),
                        style: TextStyle(color: Colors.grey, fontSize: 16),
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
