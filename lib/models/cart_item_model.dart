import 'package:sudafood/models/menu_item_model.dart';

class CartItem {
  final MenuItem product;
  int quantity;

  // ✅ 1. المتغير الجديد لتثبيت السعر (Price Snapshot)
  // هذا السعر لن يتغير حتى لو قام المطعم بتغيير سعر الوجبة لاحقاً
  final double price;

  CartItem({
    required this.product,
    this.quantity = 1,
    // خيار لتمرير سعر محفوظ مسبقاً (مثلاً عند استرجاع الطلب من التاريخ)
    double? savedPrice,
  }) :
        // ✅ إذا لم نمرر سعراً (حالة إضافة جديدة للسلة)، نأخذ السعر الحالي للوجبة
        // إذا مررنا سعراً (حالة استرجاع من التاريخ)، نستخدمه هو
        price = savedPrice ?? product.price;

  // ✅ 2. حساب الإجمالي يعتمد على السعر المثبت (this.price) وليس سعر المنتج الحالي
  double get totalPrice => price * quantity;

  // 3. تخزين البيانات بما فيها السعر المثبت
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.title,
      'price': price, // 👈 هنا يتم حفظ السعر التاريخي في قاعدة البيانات
      'quantity': quantity,
      'totalPrice': totalPrice,
      'imageUrl': product.imageUrl,
    };
  }

  // 4. استرجاع البيانات مع الحفاظ على السعر القديم
  factory CartItem.fromMap(Map<String, dynamic> map, MenuItem product) {
    return CartItem(
      product: product,
      quantity: map['quantity'] ?? 1,
      // 👈 استرجاع السعر القديم من الطلب، وليس من المنتج الحالي
      savedPrice: (map['price'] as num?)?.toDouble(),
    );
  }
}
