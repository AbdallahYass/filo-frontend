// lib/models/category_model.dart

class CategoryModel {
  final String id;
  final String name;
  final String key;
  final String icon; // اسم أيقونة (مثلاً 'restaurant')

  CategoryModel({
    required this.id,
    required this.name,
    required this.key,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      icon: json['icon'] as String,
    );
  }
}
