// lib/models/category_model.dart

class CategoryModel {
  final String id;
  // 🔥🔥🔥 الأسماء الآن تأتي من الـ DB 🔥🔥🔥
  final String nameEn;
  final String nameAr;
  final String key;
  final String icon;

  CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.key,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String,
      key: json['key'] as String,
      icon: json['icon'] as String,
      // 🔥 جلب الأسماء من الكائن الفرعي 'name' 🔥
      nameEn: json['name']['en'] as String,
      nameAr: json['name']['ar'] as String,
    );
  }
}
