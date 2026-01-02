import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استدعاء المكونات والخدمات الموحدة
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/services/order_service.dart';
import 'package:sudafood/models/order_model.dart';

class VendorOrdersPage extends StatelessWidget {
  // ✅ 1. إضافة متغير لمعرف المطعم
  final String restaurantId;

  const VendorOrdersPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات المطعم الواردة",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ 2. تعديل الاستعلام لفلترة الطلبات الخاصة بهذا المطعم فقط
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('restaurantId',
                isEqualTo: restaurantId) // 🔒 فلترة أمنية هامة
            .where('status', whereIn: ['pending', 'preparing'])
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // ملاحظة: قد تحتاج لإنشاء Index في Firebase Console ليختفي هذا الخطأ
            return const Center(
                child: Text("حدث خطأ في تحميل البيانات (تأكد من الـ Index)"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              // تحويل بيانات Firestore إلى موديل OrderModel يدوياً
              final order = OrderModel.fromMap(
                  orders[index].data() as Map<String, dynamic>,
                  orders[index].id);
              return _buildOrderVendorCard(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderVendorCard(BuildContext context, OrderModel order) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("طلب #${order.id.substring(0, 5)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              _buildStatusBadge(order.status),
            ],
          ),
          const Divider(height: 24),

          // تفاصيل الطلب المالية
          const Text("ملخص الطلب:",
              style: TextStyle(
                  color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
          Text(
              "إجمالي القيمة: ${order.totalAmount} ${order.country == 'Sudan' ? 'ج.س' : 'RWF'}",
              style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          // أزرار التحكم في سير العمل (Workflow)
          Row(
            children: [
              if (order.status == 'pending')
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.play, size: 16),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () =>
                        OrderService().updateOrderStatus(order.id, 'preparing'),
                    label: const Text("بدء التحضير",
                        style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ),
              if (order.status == 'preparing')
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.checkCircle, size: 16),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () =>
                        OrderService().updateOrderStatus(order.id, 'ready'),
                    label: const Text("جاهز للاستلام",
                        style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    String text = "انتظار";

    if (status == 'preparing') {
      color = Colors.blue;
      text = "قيد التجهيز";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo')),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.chefHat, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("المطبخ هادئ حالياً",
              style: TextStyle(
                  color: Colors.grey, fontSize: 18, fontFamily: 'Cairo')),
          const Text("لا توجد طلبات جديدة بانتظار التحضير",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
