// lib/models/address_model.dart

class AddressModel {
  final String id;
  final String title; // مثال: "المنزل" أو "العمل"
  final String details; // تفاصيل العنوان (مثال: "شارع الجامعة - مبنى 5")
  final double latitude; // دائرة العرض
  final double longitude; // خط الطول

  AddressModel({
    required this.id,
    required this.title,
    required this.details,
    required this.latitude,
    required this.longitude,
  });

  // دالة تحويل من JSON إلى موديل
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      details: json['details'] ?? '',
      // التأكد من أن القيم هي Double
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // دالة تحويل من موديل إلى JSON (لإرسالها إلى السيرفر)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'details': details,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
