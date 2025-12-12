// lib/models/store_info_model.dart

class StoreInfoModel {
  final String storeId;
  final String storeName;
  final String? logoUrl;
  final String? description;
  final bool? isOpen;

  // 🔥🔥 الحقول الجديدة التي سببت الخطأ 🔥🔥
  final String? openTime; // يجب تعريفها هنا
  final String? closeTime; // يجب تعريفها هنا

  StoreInfoModel({
    required this.storeId,
    required this.storeName,
    this.logoUrl,
    this.description,
    this.isOpen,
    // 🔥🔥 إضافة الحقول للـ Constructor 🔥🔥
    this.openTime,
    this.closeTime,
  });

  factory StoreInfoModel.fromJson(Map<String, dynamic> json) {
    return StoreInfoModel(
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      isOpen: json['isOpen'] as bool?,

      // 🔥🔥 استخلاص الحقول من JSON 🔥🔥
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'logoUrl': logoUrl,
      'description': description,
      'isOpen': isOpen,

      // 🔥🔥 إضافة الحقول للـ JSON (للتطبيق) 🔥🔥
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }
}
