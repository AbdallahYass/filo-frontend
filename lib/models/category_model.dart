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
    // التحقق من نوع حقل الاسم (قد يكون كائن أو نص قديم)
    final nameField = json['name'];
    String arName;
    String enName;

    if (nameField is Map<String, dynamic>) {
      // التعامل مع الهيكل الجديد { "ar": "...", "en": "..." }
      arName =
          nameField['ar'] ??
          nameField['en'] ??
          (json['key'] as String).toUpperCase();
      enName =
          nameField['en'] ??
          nameField['ar'] ??
          (json['key'] as String).toUpperCase();
    } else if (nameField is String) {
      // دعم للهيكل القديم إذا كان الاسم سلسلة نصية واحدة
      arName = nameField;
      enName = nameField;
    } else {
      // fallback
      arName = enName = (json['key'] as String).toUpperCase();
    }

    return CategoryModel(
      id: json['_id'] as String,
      key: json['key'] as String,
      icon: json['icon'] as String,
      nameEn: enName,
      nameAr: arName,
    );
  }
}
