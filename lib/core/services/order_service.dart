import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudafood/models/order_model.dart';
import 'package:sudafood/models/cart_item_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. إنشاء طلب جديد (يرسله العميل للمطعم)
  // ✅ التعديل: حفظ الطلب + الوجبات في مستند واحد (لا حاجة لـ Batch أو Subcollections)
  Future<void> placeOrder(OrderModel order) async {
    try {
      // مرجع الطلب الرئيسي
      DocumentReference orderRef = _db.collection('orders').doc(order.id);

      // حفظ البيانات دفعة واحدة
      // دالة toMap() في OrderModel الآن تحتوي على قائمة 'items' بداخلها
      await orderRef.set({
        ...order.toMap(),
        'date': FieldValue.serverTimestamp(), // توقيت السيرفر للترتيب الدقيق
      });
    } catch (e) {
      throw Exception("فشل في إرسال الطلب: $e");
    }
  }

  // 2. جلب الطلبات مفلترة حسب الحالة والمطعم (لشاشة إدارة الطلبات)
  Stream<QuerySnapshot> getOrdersByStatus({
    required String restaurantId,
    required String status,
  }) {
    return _db
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // 3. تحديث حالة الطلب (قبول، تجهيز، إلخ)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus,
        // يمكن إضافة حقل لتتبع وقت آخر تحديث إذا أردت
        // 'lastUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("فشل تحديث الحالة: $e");
    }
  }

  // 4. جلب الطلبات النشطة (لشاشات العرض العامة)
  Stream<List<OrderModel>> getRestaurantActiveOrders(String restaurantId) {
    return _db
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('status',
            whereIn: ['pending', 'preparing', 'ready', 'delivering'])
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _mapDocumentToOrderModel(doc)).toList());
  }

  // 5. جلب تاريخ طلبات الزبون
  Stream<List<OrderModel>> getCustomerOrders(String userId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _mapDocumentToOrderModel(doc)).toList());
  }

  // ✅ دالة المساعدة: تحويل المستند إلى OrderModel
  // الآن أصبحت أبسط لأن fromMap في الموديل تتكفل بجلب الـ items من داخل المستند
  OrderModel _mapDocumentToOrderModel(DocumentSnapshot doc) {
    return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
