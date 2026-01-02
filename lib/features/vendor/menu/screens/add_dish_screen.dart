import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sudafood/models/menu_item_model.dart';

class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. جلب قائمة الطعام للمطعم لحظياً (Stream)
  // يستخدم هذا التابع لتحديث شاشة الإدارة وشاشة العميل فورياً
  Stream<List<MenuItem>> getRestaurantMenu(String restaurantId) {
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menu')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 2. إضافة وجبة جديدة مع رفع الصورة
  // تتم العملية على مرحلتين: رفع الملف أولاً ثم حفظ البيانات بالرابط الجديد
  Future<void> addDish(
      String restaurantId, MenuItem item, File imageFile) async {
    try {
      // رفع الصورة إلى Firebase Storage
      String imageUrl = await _uploadImage(restaurantId, imageFile, item.id);

      // إضافة الوجبة لمجموعة الـ menu الفرعية داخل مستند المطعم
      await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .doc(item.id)
          .set(item.copyWith(imageUrl: imageUrl).toMap());
    } catch (e) {
      throw Exception("خطأ في إضافة الوجبة: $e");
    }
  }

  // 3. تحديث حالة توفر الوجبة (إخفاء/إظهار)
  // يتم استدعاؤه عند تبديل الـ Switch في لوحة التحكم
  Future<void> toggleProductAvailability(
      String resId, String itemId, bool status) async {
    await _db
        .collection('restaurants')
        .doc(resId)
        .collection('menu')
        .doc(itemId)
        .update({'isAvailable': status});
  }

  // 4. حذف وجبة من المنيو
  // يقوم بحذف المستند من Firestore لتختفي الوجبة فوراً عند الجميع
  Future<void> deleteDish(String resId, String itemId, String imageUrl) async {
    try {
      // حذف المستند من Firestore
      await _db
          .collection('restaurants')
          .doc(resId)
          .collection('menu')
          .doc(itemId)
          .delete();

      // ملاحظة: يفضل حذف الصورة من Storage أيضاً لتوفير المساحة
      if (imageUrl.isNotEmpty) {
        await _storage.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      throw Exception("خطأ في حذف الوجبة: $e");
    }
  }

  // تابع خاص (Private) لرفع الصور وتوليد الرابط
  Future<String> _uploadImage(
      String restaurantId, File file, String itemId) async {
    final ref = _storage
        .ref()
        .child('menu_images')
        .child(restaurantId)
        .child('$itemId.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
