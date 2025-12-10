// lib/models/store_info_model.dart

class StoreInfoModel {
  final String storeName;
  final String? description;
  final String? logoUrl;
  final bool? isOpen;

  StoreInfoModel({
    required this.storeName,
    this.description,
    this.logoUrl,
    this.isOpen,
  });

  factory StoreInfoModel.fromJson(Map<String, dynamic> json) {
    return StoreInfoModel(
      storeName: json['storeName'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      isOpen: json['isOpen'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'description': description,
      'logoUrl': logoUrl,
      'isOpen': isOpen,
    };
  }
}
