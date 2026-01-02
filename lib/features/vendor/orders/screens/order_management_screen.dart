import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ✅ استدعاء المكونات والخدمات الموحدة من مشروع SudaFood
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/core/services/order_service.dart';

class OrderManagementScreen extends StatefulWidget {
  final String restaurantId;

  const OrderManagementScreen({super.key, required this.restaurantId});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final OrderService _orderService = OrderService();

  // 🔒 متغير لمنع الضغط المتكرر (Double Tap Flag)
  bool _isUpdating = false;

  // 🔒 دالة مركزية لتحديث الحالة بأمان
  Future<void> _handleStatusUpdate(String orderId, String newStatus) async {
    // 1. إذا كانت هناك عملية جارية، نوقف التنفيذ فوراً
    if (_isUpdating) return;

    // 2. تفعيل القفل وبدء التحميل
    setState(() => _isUpdating = true);

    try {
      // 3. تنفيذ التحديث عبر السيرفس
      await _orderService.updateOrderStatus(orderId, newStatus);

      if (mounted) {
        // رسالة نجاح اختيارية
        // UIHelpers.showSnackBar(context, "تم تحديث حالة الطلب");
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showSnackBar(context, "فشل التحديث: $e", isError: true);
      }
    } finally {
      // 4. فك القفل في كل الأحوال (سواء نجح أو فشل)
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إدارة طلبات المطبخ",
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            labelStyle:
                TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "جديد"),
              Tab(text: "قيد التجهيز"),
              Tab(text: "جاهز"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList("pending"), // طلبات تنتظر الموافقة
            _buildOrdersList("preparing"), // طلبات تحت الطبخ حالياً
            _buildOrdersList("ready"), // طلبات بانتظار السائق
          ],
        ),
      ),
    );
  }

  // ✅ جلب الطلبات لحظياً مع فلترة صارمة حسب المطعم والحالة المختارة من Firestore
  Widget _buildOrdersList(String status) {
    return StreamBuilder<QuerySnapshot>(
      // 🔄 المصدر الموحد للبيانات
      stream: _orderService.getOrdersByStatus(
        restaurantId: widget.restaurantId,
        status: status,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text("حدث خطأ في الاتصال بقاعدة البيانات",
                  style: TextStyle(fontFamily: 'Cairo')));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(status);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final orderData = doc.data() as Map<String, dynamic>;

            return AppCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(doc.id, orderData['date']),
                  const Divider(height: 25),
                  _buildOrderDetail(orderData),
                  UIHelpers.verticalSpaceMedium,

                  // تمرير حالة التحميل للأزرار
                  _isUpdating
                      ? const Center(child: LinearProgressIndicator())
                      : _buildActionButtons(doc.id, status),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderHeader(String id, dynamic date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("طلب #${id.substring(0, 5)}",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Cairo')),
        _buildTimeTag(date),
      ],
    );
  }

  Widget _buildOrderDetail(Map<String, dynamic> data) {
    String currency = data['country'] == 'Sudan' ? 'ج.س' : 'RWF';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("إجمالي القيمة:",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
        Text("${data['totalAmount']} $currency",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 18)),
      ],
    );
  }

  Widget _buildActionButtons(String orderId, String status) {
    if (status == "pending") {
      return Row(
        children: [
          Expanded(
              child: AppButton(
            text: "قبول وتحضير",
            // 🔒 استخدام الدالة الآمنة بدلاً من الاستدعاء المباشر
            onPressed: () => _handleStatusUpdate(orderId, "preparing"),
          )),
          UIHelpers.horizontalSpaceSmall,
          Expanded(child: _buildCancelButton(orderId)),
        ],
      );
    } else if (status == "preparing") {
      return AppButton(
        text: "تم الطبخ (جاهز للتسليم) ✅",
        // 🔒 استخدام الدالة الآمنة
        onPressed: () => _handleStatusUpdate(orderId, "ready"),
      );
    } else if (status == "ready") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: const Center(
          child: Text("بانتظار استلام السائق...",
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo')),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCancelButton(String orderId) {
    return OutlinedButton(
      // 🔒 استخدام الدالة الآمنة
      onPressed: () => _handleStatusUpdate(orderId, "cancelled"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text("رفض الطلب", style: TextStyle(fontFamily: 'Cairo')),
    );
  }

  Widget _buildEmptyState(String status) {
    String msg = status == "pending"
        ? "لا توجد طلبات جديدة حالياً"
        : (status == "preparing"
            ? "لا يوجد شيء يُطبخ الآن"
            : "كل الطلبات استلمها السائقون");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(msg,
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTimeTag(dynamic timestamp) {
    String time = "الآن";
    if (timestamp is Timestamp) {
      time = DateFormat('hh:mm a').format(timestamp.toDate());
    }
    return Text(time,
        style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold));
  }
}
