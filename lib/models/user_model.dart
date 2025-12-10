// lib/models/user_model.dart

import 'store_info_model.dart';
import 'address_model.dart'; // نفترض أنك تستخدم موديل العناوين

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String role; // 'customer', 'vendor', 'driver'
  final bool isVerified;

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

    // معالجة بيانات المتجر (يجب أن يكون الكائن من نوع Map لتمريره إلى StoreInfoModel)
    StoreInfoModel? storeInfoData;
    if (json['storeInfo'] is Map<String, dynamic>) {
      storeInfoData = StoreInfoModel.fromJson(
        json['storeInfo'] as Map<String, dynamic>,
      );
    }

    return UserModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      // نستخدم operator ?? '' لضمان أن الحقول النصية التي قد تكون null في DB يتم التعامل معها بأمان
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool,
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
      'savedAddresses': savedAddresses?.map((e) => e.toJson()).toList(),
      // نستخدم storeInfo?.toJson() لتمرير البيانات فقط إذا كانت موجودة
      'storeInfo': storeInfo?.toJson(),
    };
  }
}
