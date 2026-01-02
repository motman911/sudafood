import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sudafood/models/restaurant_model.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. إضافة مطعم جديد مع رفع الصورة وتنظيمها حسب الدولة
  // هذه الدالة تسمح للسوبر أدمن ببناء النظام يدوياً من واجهة الويب أو التطبيق
  Future<void> addRestaurant(RestaurantModel restaurant, File imageFile) async {
    try {
      // تنظيم مسار الصورة في Storage لسهولة الإدارة:
      // restaurants_images/Sudan/1735812345.jpg
      String fileName =
          'restaurants_images/${restaurant.country}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // رفع الصورة إلى Firebase Storage
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // الحصول على رابط الصورة المباشر بعد الرفع بنجاح
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // حفظ بيانات المطعم في Firestore
      // نستخدم .set لإنشاء المستند بالمعرف (ID) المولد مسبقاً من UUID
      await _firestore.collection('restaurants').doc(restaurant.id).set({
        ...restaurant.toMap(), // تحويل بيانات الموديل لخريطة (Map)
        'imageUrl': downloadUrl,
        'isOpen': true, // الحالة الافتراضية عند الإضافة هي "مفتوح"
        'createdAt':
            FieldValue.serverTimestamp(), // توقيت السيرفر لترتيب المطاعم
      });
    } catch (e) {
      throw Exception("فشل في إضافة المطعم يدوياً: $e");
    }
  }

  // 2. جلب المطاعم حسب الدولة (عزل بيانات السودان عن رواندا)
  // يستخدمها تطبيق الزبون لعرض المطاعم المضافة يدوياً فقط
  Stream<List<RestaurantModel>> getRestaurantsByCountry(String country) {
    return _firestore
        .collection('restaurants')
        .where('country', isEqualTo: country)
        .where('isOpen',
            isEqualTo: true) // جلب المطاعم التي لم يغلقها الأدمن أو صاحب المطعم
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // 3. جلب مطاعم تصنيف معين (مثلاً: "سوداني" أو "برجر") في دولة محددة
  Stream<List<RestaurantModel>> getRestaurantsByCategory(
      String country, String category) {
    return _firestore
        .collection('restaurants')
        .where('country', isEqualTo: country)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // 4. تحديث حالة المطعم يدوياً (مفتوح / مغلق) من قبل صاحب المطعم أو الأدمن
  Future<void> toggleRestaurantStatus(String restaurantId, bool isOpen) async {
    await _firestore.collection('restaurants').doc(restaurantId).update({
      'isOpen': isOpen,
    });
  }

  // 5. جلب بيانات مطعم واحد (مفيد لشاشة تفاصيل المطعم للزبون)
  Future<RestaurantModel?> getRestaurantById(String restaurantId) async {
    final doc =
        await _firestore.collection('restaurants').doc(restaurantId).get();
    if (doc.exists) {
      return RestaurantModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // 6. حذف مطعم وصورته نهائياً من النظام
  Future<void> deleteRestaurant(String restaurantId, String imageUrl) async {
    try {
      // حذف الملف الفيزيائي من Storage لتوفير المساحة والتكلفة
      if (imageUrl.isNotEmpty) {
        await _storage.refFromURL(imageUrl).delete();
      }
      // حذف السجل من قاعدة البيانات
      await _firestore.collection('restaurants').doc(restaurantId).delete();
    } catch (e) {
      throw Exception("حدث خطأ أثناء محاولة الحذف: $e");
    }
  }
}
