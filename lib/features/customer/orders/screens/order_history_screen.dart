import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

// استيراد المكونات والموديلات الأساسية
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/models/order_model.dart';
import 'package:sudafood/features/customer/orders/screens/order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("طلباتي",
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle:
                TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "الطلبات النشطة"),
              Tab(text: "السابقة"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // عرض الطلبات النشطة (قيد المراجعة، التحضير، أو التوصيل)
            _buildFirestoreOrderList(context, isActive: true),
            // عرض الطلبات المنتهية (المكتملة أو الملغاة)
            _buildFirestoreOrderList(context, isActive: false),
          ],
        ),
      ),
    );
  }

  // دالة لجلب البيانات من Firestore لحظياً بناءً على هوية العميل وحالة الطلب
  Widget _buildFirestoreOrderList(BuildContext context,
      {required bool isActive}) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('customerId', isEqualTo: user?.uid)
          // تصفية الحالات بناءً على التبويب المختار
          .where('status',
              whereIn: isActive
                  ? ['pending', 'preparing', 'ready', 'delivering']
                  : ['completed', 'cancelled'])
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isActive);
        }

        final ordersDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ordersDocs.length,
          itemBuilder: (context, index) {
            // تحويل مستند Firestore إلى كائن OrderModel
            final order = OrderModel.fromMap(
                ordersDocs[index].data() as Map<String, dynamic>,
                ordersDocs[index].id);

            return _buildOrderCard(context, order, isActive);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(
      BuildContext context, OrderModel order, bool isActive) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      // النقر على الطلب النشط ينقلك مباشرة لشاشة التتبع
      onTap: isActive
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OrderTrackingScreen()),
              )
          : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.store,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurantName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(_getStatusText(order.status),
                          style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo')),
                    ],
                  ),
                ],
              ),
              Text("#${order.id.substring(0, 5)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "المجموع: ${order.totalAmount} ${order.country == 'Sudan' ? 'ج.س' : 'RWF'}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              if (!isActive && order.status == 'completed')
                OutlinedButton.icon(
                  onPressed: () {}, // منطق إعادة الطلب مستقبلاً
                  icon: const Icon(LucideIcons.rotateCw, size: 14),
                  label:
                      const Text("إعادة طلب", style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // تحويل حالات الطلب البرمجية إلى نصوص عربية مفهومة
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return "انتظار الموافقة...";
      case 'preparing':
        return "يتم التحضير حالياً 👨‍🍳";
      case 'ready':
        return "طلبك جاهز ✅";
      case 'delivering':
        return "في الطريق إليك 🛵";
      case 'completed':
        return "تم التوصيل بنجاح 💵";
      case 'cancelled':
        return "تم الإلغاء ❌";
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'completed') return Colors.green;
    if (status == 'cancelled') return Colors.red;
    return AppColors.primary;
  }

  Widget _buildEmptyState(bool isActive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.package, size: 64, color: Colors.grey[300]),
          UIHelpers.verticalSpaceSmall,
          Text(isActive ? "لا توجد طلبات نشطة حالياً" : "سجل طلباتك فارغ",
              style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}
