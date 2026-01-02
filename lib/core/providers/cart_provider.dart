import 'package:flutter/material.dart';
import 'package:sudafood/models/cart_item_model.dart';
import 'package:sudafood/models/menu_item_model.dart';

class CartProvider with ChangeNotifier {
  // استخدام Map لسهولة البحث والوصول للعناصر
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // بيانات المطعم الحالي (لمنع الطلب من مطعمين مختلفين)
  String? restaurantId;
  String? restaurantName;

  int get itemCount => _items.length;

  // ✅ التعديل 1: حساب الإجمالي يعتمد على السعر المثبت داخل CartItem
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      // نستخدم totalPrice الخاص بالعنصر لأنه محسوب بناءً على السعر المثبت
      total += cartItem.totalPrice;
    });
    return total;
  }

  // إضافة عنصر للسلة
  void addItem({
    required String restaurantId,
    required String restaurantName,
    required String itemId,
    required String name,
    required double price,
    required String image,
  }) {
    // 1. التحقق من أن الطلب من نفس المطعم، وإلا يتم تفريغ السلة
    if (this.restaurantId != null && this.restaurantId != restaurantId) {
      clearCart();
    }

    // تحديث بيانات المطعم الحالي
    this.restaurantId = restaurantId;
    this.restaurantName = restaurantName;

    if (_items.containsKey(itemId)) {
      // ✅ التعديل 2: عند زيادة الكمية، نحافظ على السعر القديم (savedPrice)
      _items.update(
        itemId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
          savedPrice: existingCartItem.price, // 👈 تمرير السعر المثبت سابقاً
        ),
      );
    } else {
      // ✅ التعديل 3: إضافة عنصر جديد (سيتم تثبيت السعر تلقائياً في CartItem)
      _items.putIfAbsent(
        itemId,
        () => CartItem(
          product: MenuItem(
            id: itemId,
            title: name,
            description: "",
            category: "",
            price: price, // هذا السعر سيتم تثبيته داخل CartItem
            imageUrl: image,
            isAvailable: true,
          ),
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // إنقاص الكمية
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      // ✅ التعديل 4: عند إنقاص الكمية، نحافظ أيضاً على السعر المثبت
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
          savedPrice: existingCartItem.price, // 👈 الحفاظ على السعر
        ),
      );
    } else {
      _items.remove(productId);
    }

    // إذا فرغت السلة، نلغي ارتباط المطعم
    if (_items.isEmpty) {
      restaurantId = null;
      restaurantName = null;
    }
    notifyListeners();
  }

  // حذف عنصر بالكامل من السلة
  void removeItem(String productId) {
    _items.remove(productId);
    if (_items.isEmpty) {
      restaurantId = null;
      restaurantName = null;
    }
    notifyListeners();
  }

  // تفريغ السلة بالكامل
  void clearCart() {
    _items = {};
    restaurantId = null;
    restaurantName = null;
    notifyListeners();
  }
}
