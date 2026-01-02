import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudafood/models/cart_item_model.dart';
import 'package:sudafood/models/menu_item_model.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String restaurantId;
  final String restaurantName;
  final double totalAmount; // 👈 هذا السعر هو السعر النهائي المثبت وقت الطلب
  final String status;
  final DateTime date;
  final String country;

  // ✅ القائمة التي ستحتفظ بتفاصيل الوجبات والأسعار المثبتة
  final List<CartItem> items;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.restaurantName,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.country,
    required this.items, // ✅ مطلوب الآن
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      customerId: map['customerId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      country: map['country'] ?? '',

      // ✅ استرجاع قائمة الوجبات من الخريطة (Array of Maps)
      items: (map['items'] as List<dynamic>? ?? []).map((itemMap) {
        // ننشئ منتجاً مؤقتاً لاستخدامه في CartItem بناءً على البيانات المحفوظة
        // هذا يضمن أننا نعرض الاسم والسعر والصورة كما كانت وقت الطلب
        final productSnapshot = MenuItem(
          id: itemMap['productId'] ?? '',
          title: itemMap['name'] ?? 'وجبة غير معروفة',
          description: '', // لا يهمنا الوصف في التاريخ
          price: (itemMap['price'] ?? 0.0).toDouble(), // 👈 السعر التاريخي
          imageUrl: itemMap['imageUrl'] ?? '',
          category: '',
        );

        return CartItem.fromMap(itemMap, productSnapshot);
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'totalAmount': totalAmount,
      'status': status,
      'date': date,
      'country': country,

      // ✅ حفظ قائمة الوجبات كاملة داخل الطلب (تثبيت البيانات)
      // هذا يحول كل CartItem إلى Map يحتوي على (الاسم، السعر المثبت، الكمية)
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
