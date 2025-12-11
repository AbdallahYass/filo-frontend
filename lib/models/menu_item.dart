class MenuItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  // 🔥 إضافة الحقول التي يرسلها الخادم 🔥
  final String vendorId;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.vendorId, // إضافة للـ constructor
    required this.isAvailable, // إضافة للـ constructor
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // 🔥🔥 قراءة _id بدلاً من id 🔥🔥
    final String itemId = json['_id'] as String;

    // 💡 التحقق من أن حقل السعر يمكن أن يكون int أو double
    final double itemPrice = (json['price'] as num).toDouble();

    return MenuItem(
      id: itemId, // استخدام القيمة المصححة
      title: json['title'] as String,
      description: json['description'] as String,
      price: itemPrice,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      // 🔥 قراءة الحقول الإضافية 🔥
      vendorId: json['vendorId'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
