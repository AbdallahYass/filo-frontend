// lib/models/user_model.dart

import 'store_info_model.dart';
import 'address_model.dart';
import 'package:flutter/foundation.dart'; // لإضافة kDebugMode

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String role;
  final bool isVerified;
  final List<String>? savedVendors;

  // 🔥🔥 حقول التقييم الجديدة 🔥🔥
  final double averageRating;
  final int reviewsCount;

  final List<AddressModel>? savedAddresses;
  final StoreInfoModel? storeInfo;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.averageRating,
    required this.reviewsCount,
    this.savedAddresses,
    this.storeInfo,
    this.savedVendors,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<AddressModel>? addresses;
    if (json['savedAddresses'] is List) {
      addresses = (json['savedAddresses'] as List)
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    List<String>? favorites;
    if (json['savedVendors'] is List) {
      favorites = (json['savedVendors'] as List)
          .map((item) => item.toString()) // الـ IDs هي String
          .toList();
    }
    StoreInfoModel? storeInfoData;
    // التأكد من أن 'storeInfo' هو كائن وليس null أو غير موجود
    if (json['storeInfo'] != null &&
        json['storeInfo'] is Map<String, dynamic>) {
      storeInfoData = StoreInfoModel.fromJson(
        // نمرر الـ User ID كـ storeId مؤقتاً للتوافق مع الموديل إذا لم يكن موجوداً
        {...json['storeInfo'] as Map<String, dynamic>, '_id': json['_id']},
      );
    }

    // 🔥🔥 استخلاص التقييمات من الـ JSON 🔥🔥
    final double rating = (json['averageRating'] as num?)?.toDouble() ?? 0.0;
    // يجب إضافة التحقق من reviewsCount في الـ Seeder
    final int reviews = json['reviewsCount'] as int? ?? 0;

    if (kDebugMode) {
      // طباعة للتحقق من وصول البيانات
      print(
        'UserModel Parsed: ${json['name']} | Rating: $rating | Store Open: ${storeInfoData?.isOpen}',
      );
    }

    return UserModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool,
      averageRating: rating,
      reviewsCount: reviews,
      savedAddresses: addresses,
      storeInfo: storeInfoData,
      savedVendors: favorites,
    );
  }

  Map<String, dynamic> toJson() {
    // ... (To Json code) ...
    return {
      '_id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'averageRating': averageRating,
      'reviewsCount': reviewsCount,
      'savedVendors': savedVendors,
      'savedAddresses': savedAddresses?.map((e) => e.toJson()).toList(),
      'storeInfo': storeInfo?.toJson(),
    };
  }
}
