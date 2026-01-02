class RestaurantModel {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String deliveryTime;
  final bool isFreeDelivery;
  // إضافات ضرورية للتوسع في السودان ورواندا
  final String country;
  final String city;
  final String category; // مثلاً: مشويات، بيتزا، إلخ
  final bool isOpen; // ✅ الحقل المضاف لحل مشكلة شاشة الإضافة

  RestaurantModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTime,
    this.isFreeDelivery = false,
    required this.country,
    required this.city,
    required this.category,
    this.isOpen = true, // ✅ قيمة افتراضية لتجنب الأخطاء عند إنشاء مطعم جديد
  });

  // تحويل البيانات القادمة من Firestore (Map) إلى كائن (Object)
  factory RestaurantModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RestaurantModel(
      id: documentId,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // معالجة الأرقام لضمان عدم حدوث خطأ في النوع (Casting)
      rating: (map['rating'] ?? 0.0).toDouble(),
      deliveryTime: map['deliveryTime'] ?? '',
      isFreeDelivery: map['isFreeDelivery'] ?? false,
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      category: map['category'] ?? '',
      isOpen: map['isOpen'] ?? true, // جلب الحالة من قاعدة البيانات
    );
  }

  // تحويل الكائن إلى Map لإرساله إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'isFreeDelivery': isFreeDelivery,
      'country': country,
      'city': city,
      'category': category,
      'isOpen': isOpen, // حفظ الحالة في قاعدة البيانات
    };
  }
}
