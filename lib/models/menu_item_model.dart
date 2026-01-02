class MenuItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
  });

  // تحويل البيانات القادمة من Firebase Firestore إلى كائن MenuItem
  factory MenuItem.fromMap(Map<String, dynamic> map, String docId) {
    return MenuItem(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      // التحويل لـ double بشكل آمن لتجنب أخطاء النوع في Firebase
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  // تحويل كائن MenuItem إلى Map لإرساله إلى Firestore يدوياً
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }

  // دالة مساعدة لتحديث حقل معين (مثل التوفر) مع الحفاظ على بقية البيانات
  MenuItem copyWith({
    bool? isAvailable,
  }) {
    return MenuItem(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
