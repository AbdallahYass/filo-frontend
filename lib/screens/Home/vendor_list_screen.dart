// lib/screens/vendor_list_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/vendor_service.dart';
import 'vendor_menu_screen.dart';

class VendorListScreen extends StatefulWidget {
  // 🔥🔥🔥 المعاملات المستقبلة من شاشة الفئات 🔥🔥🔥
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
  // 🔥🔥🔥 حالة البحث والبيانات 🔥🔥🔥
  final VendorService _vendorService = VendorService();
  late Future<List<UserModel>> _vendorsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFFF9F9F9);
  final Color _darkColor = const Color(
    0xFF1A1A1A,
  ); // لون موحد للخلفية الداكنة في شريط البحث
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _vendorsFuture = _vendorService.fetchVendorsByCategory(widget.categoryKey);
    // 🚀 ربط المستمع لتفعيل الفلترة عند الكتابة
    _searchController.addListener(_onSearchChanged);
  }

  // 🔥🔥 دالة تحدث حالة البحث 🔥🔥
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
      );
    });
  }

  // ----------------------------------------------------
  // 🎨 دوال بناء الواجهة المساعدة 🎨
  // ----------------------------------------------------

  // 🔥 بناء شريط البحث العلوي
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
              controller: _searchController, // 🔥 ربط المتحكم
              decoration: InputDecoration(
                hintText: localizations
                    .searchVendorHint, // 💡 افترضنا وجود مفتاح ترجمة جديد
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

  // بناء كارت التاجر/المتجر
  Widget _buildVendorCard(UserModel vendor, AppLocalizations localizations) {
    // 🔥 استخراج البيانات من UserModel 🔥
    final String storeName =
        vendor.storeInfo?.storeName ??
        vendor.name ??
        localizations.vendorDefaultName;
    final String description =
        vendor.storeInfo?.description ?? localizations.vendorDefaultDescription;
    final bool isOpen = vendor.storeInfo?.isOpen == true;

    final Color statusColor = isOpen ? Colors.green : Colors.red;
    final String statusText = isOpen
        ? (localizations.storeOpen)
        : (localizations.storeClosed);

    return GestureDetector(
      onTap: () {
        // ✅ تفعيل التوجيه إلى VendorMenuScreen
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
              // ... (كود اللوجو والصورة) ...
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
                    // ... (اسم المتجر ووصفه وحالته) ...
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
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
        // عنوان الشاشة هو اسم الفئة المختار
        title: Text(widget.categoryName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // 🔥 الآن يحتوي الـ Body على شريط البحث في الأعلى 🔥
      body: Column(
        children: [
          // شريط البحث المدمج في الجزء العلوي من الـ Body
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
              top: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white, // خلفية بيضاء لتفريقها عن الـ darkBackground
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

          // 🔥 الجزء المتبقي (FutureBuilder & RefreshIndicator) 🔥
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
                    // رسالة خطأ الاتصال
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

                  // 🔥🔥 تطبيق فلترة البحث 🔥🔥
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
                    // لا يوجد نتائج للبحث الحالي
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          localizations
                              .noResultsFound, // 💡 يجب إضافة هذا المفتاح لملفات arb
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (filteredVendors.isEmpty) {
                    // لا يوجد تجار متاحون في هذه الفئة
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          localizations.noVendorsFound(widget.categoryName),
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
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
