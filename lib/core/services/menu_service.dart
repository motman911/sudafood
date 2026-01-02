import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sudafood/models/menu_item_model.dart';

class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. جلب قائمة الطعام (Stream)
  Stream<List<MenuItem>> getRestaurantMenu(String restaurantId) {
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menu')
        // ✅ تم تفعيل الترتيب لأننا نضيف createdAt عند الإضافة
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 2. إضافة وجبة جديدة (متوافقة مع AddDishScreen)
  Future<void> addDish(String restaurantId, MenuItem dish) async {
    try {
      // حفظ البيانات مباشرة مع طابع زمني
      await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .doc(dish.id)
          .set({
        ...dish.toMap(),
        'createdAt': FieldValue.serverTimestamp(), // لتتمكن من ترتيبها
      });

      // ✅ تحديث عداد الوجبات ليظهر في لوحة التحكم
      await _updateMenuCount(restaurantId);
    } catch (e) {
      throw Exception("فشل إضافة الوجبة: $e");
    }
  }

  // 3. تعديل حالة التوفر
  Future<void> toggleProductAvailability(
      String resId, String itemId, bool status) async {
    await _db
        .collection('restaurants')
        .doc(resId)
        .collection('menu')
        .doc(itemId)
        .update({'isAvailable': status});
  }

  // 4. حذف وجبة
  Future<void> deleteDish(String resId, String itemId, String imageUrl) async {
    try {
      // حذف المستند من Firestore
      await _db
          .collection('restaurants')
          .doc(resId)
          .collection('menu')
          .doc(itemId)
          .delete();

      // ✅ حذف ذكي: نحذف الصورة فقط إذا كانت مرفوعة على سيرفراتنا
      if (imageUrl.contains('firebasestorage')) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (_) {
          // نتجاهل الخطأ إذا لم يتم العثور على الصورة أو كانت محذوفة مسبقاً
        }
      }

      // ✅ تحديث العداد (إنقاص العدد)
      await _updateMenuCount(resId);
    } catch (e) {
      throw Exception("خطأ في حذف الوجبة: $e");
    }
  }

  // 🔄 دالة مساعدة لتحديث عدد الوجبات في مستند المطعم الرئيسي
  Future<void> _updateMenuCount(String restaurantId) async {
    // نستخدم count() وهي ميزة جديدة في Firestore وسريعة جداً ولا تستهلك قراءات كثيرة
    final snapshot = await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menu')
        .count()
        .get();

    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .update({'menuCount': snapshot.count});
  }
}
