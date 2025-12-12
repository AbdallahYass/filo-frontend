// lib/models/store_info_model.dart

class StoreInfoModel {
  // يمكن أن يكون الـ ID اختياريًا هنا إذا كان يمرر من الـ UserModel
  final String? storeId;
  final String storeName;
  final String? logoUrl;
  final String? description;
  final bool? isOpen;

  // 🔥🔥 حقول التوقيت الجديدة 🔥🔥
  final String? openTime; // وقت الفتح (مثال: "09:00")
  final String? closeTime; // وقت الإغلاق (مثال: "22:00")

  StoreInfoModel({
    this.storeId,
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
      // يمكن استخدام حقل _id إذا كان موجودًا في الـ storeInfo نفسه
      storeId: json['_id'] as String?,
      storeName: json['storeName'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      isOpen: json['isOpen'] as bool?,

      // 🔥🔥 استخلاص حقول التوقيت من JSON 🔥🔥
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': storeId,
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
