// lib/models/user_model.dart

import 'store_info_model.dart';
import 'address_model.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String role;
  final bool isVerified;

  // 🔥🔥 حقول التقييم الجديدة 🔥🔥
  final double averageRating;
  final int reviewsCount;

  // 🏠 قائمة عناوين المستخدم (قد تكون فارغة)
  final List<AddressModel>? savedAddresses;

  // 🏪 معلومات المتجر (فقط إذا كان role = 'vendor')
  final StoreInfoModel? storeInfo;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    required this.role,
    required this.isVerified,
    // 🔥🔥 إضافة التقييمات إلى الـ Constructor 🔥🔥
    required this.averageRating,
    required this.reviewsCount,
    this.savedAddresses,
    this.storeInfo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // معالجة قائمة العناوين
    List<AddressModel>? addresses;
    if (json['savedAddresses'] is List) {
      addresses = (json['savedAddresses'] as List)
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // معالجة بيانات المتجر
    StoreInfoModel? storeInfoData;
    if (json['storeInfo'] is Map<String, dynamic>) {
      storeInfoData = StoreInfoModel.fromJson(
        json['storeInfo'] as Map<String, dynamic>,
      );
    }

    // 🔥🔥 استخلاص التقييمات من الـ JSON 🔥🔥
    // نستخدم as num)?.toDouble() للتعامل مع الحالات التي يكون فيها التقييم int أو null
    final double rating = (json['averageRating'] as num?)?.toDouble() ?? 0.0;
    final int reviews = json['reviewsCount'] as int? ?? 0;

    return UserModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool,

      // 🔥🔥 تمرير التقييمات 🔥🔥
      averageRating: rating,
      reviewsCount: reviews,

      savedAddresses: addresses,
      storeInfo: storeInfoData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,

      // 🔥🔥 إضافة التقييمات إلى الـ JSON 🔥🔥
      'averageRating': averageRating,
      'reviewsCount': reviewsCount,

      'savedAddresses': savedAddresses?.map((e) => e.toJson()).toList(),
      'storeInfo': storeInfo?.toJson(),
    };
  }
}
