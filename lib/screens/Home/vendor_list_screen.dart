// lib/screens/vendor_list_screen.dart

// 🚀 هذا الملف يعرض قائمة التجار (Vendors) التابعين لفئة معينة، مع دعم البحث والفرز والحالة الذكية، ونمط العرض المتعدد.

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  // 🔥🔥 1. إدارة الحالة والمتحكمات 🔥🔥
  final VendorService _vendorService = VendorService();
  late Future<List<UserModel>> _vendorsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _selectedSortKey = 'default';
  late List<Map<String, String>> _sortOptions;

  // 🔥🔥 متغير الحالة لتبديل طريقة العرض 🔥🔥
  bool _isGridView = false; // False = List view (افتراضي), True = Grid view

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
    debugPrint(
      'VENDOR LIST SCREEN: Starting data fetch for category: ${widget.categoryKey}',
    );

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

  // 🔥🔥 دالة لتحديث البيانات من الخادم (يجب استخدامها بعد تفضيل متجر) 🔥🔥
  Future<void> _refreshData() async {
    // يجب أن تتضمن هذه الدالة تحديثاً لحالة المستخدم (خاصة قائمة المفضلة)
    // لكن بما أننا لا نملك خدمة `fetchCurrentUser`, سنكتفي بتحديث قائمة التجار بالكامل
    // (لنفترض أن الخادم يرجع حالة المستخدم ضمن الاستجابة العامة إذا كان مسجل دخول).
    setState(() {
      _vendorsFuture = _vendorService.fetchVendorsByCategory(
        widget.categoryKey,
        sortBy: _selectedSortKey,
      );
    });
  }

  // ----------------------------------------------------
  // 🎨 منطق حالة المتجر الذكي (للاستخدام في كلا نمطي العرض) 🎨
  // ----------------------------------------------------

  Map<String, dynamic> _getSmartStatus(
    UserModel vendor,
    AppLocalizations localizations,
  ) {
    final bool isOpen = vendor.storeInfo?.isOpen == true;

    final String? openTimeStr = vendor.storeInfo?.openTime;
    final String? closeTimeStr = vendor.storeInfo?.closeTime;

    if (openTimeStr != null && closeTimeStr != null) {
      try {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final openParts = openTimeStr.split(':');
        final openHour = int.parse(openParts[0]);
        final openMinute = int.parse(openParts[1]);
        final openTime = today.add(
          Duration(hours: openHour, minutes: openMinute),
        );

        final closeParts = closeTimeStr.split(':');
        final closeHour = int.parse(closeParts[0]);
        final closeMinute = int.parse(closeParts[1]);
        DateTime closeTime = today.add(
          Duration(hours: closeHour, minutes: closeMinute),
        );

        if (closeTime.isBefore(openTime)) {
          closeTime = closeTime.add(const Duration(days: 1));
        }

        const openSoonThreshold = Duration(minutes: 30);
        const closeSoonThreshold = Duration(minutes: 60);

        if (!isOpen) {
          final timeUntilOpen = openTime.difference(now);
          if (!timeUntilOpen.isNegative && timeUntilOpen < openSoonThreshold) {
            return {
              'text': localizations.storeOpeningSoon,
              'color': _goldColor,
              'icon': Icons.schedule,
            };
          }
        }

        if (isOpen) {
          if (now.isAfter(openTime) && now.isBefore(closeTime)) {
            final timeUntilClose = closeTime.difference(now);
            if (timeUntilClose < closeSoonThreshold) {
              return {
                'text': localizations.storeClosingSoon,
                'color': Colors.orange.shade700,
                'icon': Icons.timer_outlined,
              };
            }
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error parsing store time: $e');
      }
    }

    final Color statusColor = isOpen ? Colors.green : Colors.red;
    final String statusText = isOpen
        ? localizations.storeOpen
        : localizations.storeClosed;

    return {
      'text': statusText,
      'color': statusColor,
      'icon': isOpen ? Icons.check_circle : Icons.access_time,
    };
  }

  // ----------------------------------------------------
  // 🔥🔥 دالة تطبيق الحركة (Animation) 🔥🔥
  // ----------------------------------------------------

  Widget _buildAnimatedCard(int index, Widget child) {
    const duration = Duration(milliseconds: 400);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, childWidget) {
        final offset = Offset(0.0, (1 - value) * 0.2);

        return Opacity(
          opacity: value,
          child: Transform.translate(offset: offset, child: childWidget),
        );
      },
      child: child,
    );
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

  Widget _buildViewToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isGridView = !_isGridView;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _isGridView ? Icons.view_list : Icons.grid_view,
          color: _goldColor,
        ),
      ),
    );
  }

  Widget _buildSortDropdown(AppLocalizations localizations) {
    _sortOptions = [
      {'key': 'default', 'label': localizations.sortByDefault},
      {'key': 'popular', 'label': localizations.sortByPopular},
      {'key': 'rating', 'label': localizations.sortByRating},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSortKey,
          icon: Icon(Icons.sort, color: _goldColor),
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

  // ----------------------------------------------------
  // 🔥 بناء بطاقة التاجر/المتجر لنمط القائمة (List Card)
  // ----------------------------------------------------
  Widget _buildVendorCard(UserModel vendor, AppLocalizations localizations) {
    final String storeName =
        vendor.storeInfo?.storeName ??
        vendor.name ??
        localizations.vendorDefaultName;
    final String description =
        vendor.storeInfo?.description ?? localizations.vendorDefaultDescription;

    final double rating = vendor.averageRating;
    final int reviews = vendor.reviewsCount;

    // 🔥🔥 التحقق من حالة المفضلة: يعتمد على أن قائمة savedVendors موجودة في UserModel
    final bool isFavorite = vendor.savedVendors?.contains(vendor.id) ?? false;

    final smartStatus = _getSmartStatus(vendor, localizations);
    final Color statusColor = smartStatus['color'];
    final String statusText = smartStatus['text'];
    final IconData statusIcon = smartStatus['icon'];

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
              // صورة/لوجو التاجر
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
                    // حالة المتجر (يستخدم الحالة الذكية)
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
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

              // 🔥🔥 أيقونة المفضلة (القلب) وزر التفاعل 🔥🔥
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: () async {
                      try {
                        await _vendorService.toggleFavorite(
                          vendor.id,
                          !isFavorite,
                        );

                        // يتم تحديث القائمة بالكامل لإظهار حالة القلب الجديدة
                        await _refreshData();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              // 🔥🔥 نهاية أيقونة المفضلة 🔥🔥
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 🔥 بناء بطاقة التاجر/المتجر لنمط الشبكة (Grid Card)
  // ----------------------------------------------------
  Widget _buildGridVendorCard(
    UserModel vendor,
    AppLocalizations localizations,
  ) {
    final String storeName =
        vendor.storeInfo?.storeName ??
        vendor.name ??
        localizations.vendorDefaultName;

    final double rating = vendor.averageRating;
    final int reviews = vendor.reviewsCount;

    // 🔥🔥 التحقق من حالة المفضلة 🔥🔥
    final bool isFavorite = vendor.savedVendors?.contains(vendor.id) ?? false;

    final smartStatus = _getSmartStatus(vendor, localizations);
    final Color statusColor = smartStatus['color'];
    final String statusText = smartStatus['text'];
    final IconData statusIcon = smartStatus['icon'];

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
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔥🔥 تغليف الصورة بـ Stack لإضافة زر المفضلة 🔥🔥
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.5, // 3:2 Aspect Ratio for the image
                    child: Image.network(
                      vendor.storeInfo?.logoUrl ??
                          'https://placehold.co/300x200/888888/FFFFFF?text=Logo',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.store,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                // 🔥🔥 زر المفضلة في أعلى اليمين 🔥🔥
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Colors.white70, // خلفية بيضاء شفافة لتحسين الرؤية
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(35, 35),
                    ),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () async {
                      try {
                        await _vendorService.toggleFavorite(
                          vendor.id,
                          !isFavorite,
                        );
                        await _refreshData();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المتجر
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // شريط التقييم وحالة المتجر
                  Row(
                    children: [
                      Icon(Icons.star, color: _goldColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      // حالة المتجر (الحالة الذكية)
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // عدد المراجعات
                  Text(
                    '(${reviews} ${localizations.reviews})',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
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

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: _darkColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥🔥 1. دمج شريط البحث وشريط الفرز في بانر واحد 🔥🔥
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
                // شريط البحث
                _buildSearchBar(localizations),
                const SizedBox(height: 15),

                // 🔥🔥 شريط الفرز وزر التبديل 🔥🔥
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر تبديل العرض (Grid / List)
                    _buildViewToggleButton(),

                    // شريط الفرز
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          localizations.sortBy,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildSortDropdown(localizations),
                      ],
                    ),
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
                  // ... (معالجة حالات التحميل والخطأ) ...

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _goldColor),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    final errorMessage = snapshot.error.toString().replaceFirst(
                      'Exception: ',
                      '',
                    );
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localizations.connectionError,
                            style: const TextStyle(color: Colors.red),
                          ),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
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

                  // معالجة حالات القائمة الفارغة/البحث
                  if (filteredVendors.isEmpty) {
                    final text = _searchQuery.isNotEmpty
                        ? localizations.noResultsFound
                        : localizations.noVendorsFound(widget.categoryName);
                    return Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // ✅ عرض قائمة التجار المفلترة (منطق التبديل هنا)
                  if (_isGridView) {
                    // --- GRID VIEW ---
                    return GridView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: filteredVendors.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                0.75, // نسبة العرض إلى الارتفاع للبطاقة
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      itemBuilder: (context, index) {
                        return _buildAnimatedCard(
                          index,
                          _buildGridVendorCard(
                            filteredVendors[index],
                            localizations,
                          ),
                        );
                      },
                    );
                  } else {
                    // --- LIST VIEW ---
                    return ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: filteredVendors.length,
                      itemBuilder: (context, index) {
                        return _buildAnimatedCard(
                          index,
                          _buildVendorCard(
                            filteredVendors[index],
                            localizations,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
