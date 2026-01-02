import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ضروري لجلب معرف السائق
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ استيراد المكونات والخدمات والموديلات
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/core/services/order_service.dart';
import 'package:sudafood/features/driver/delivery/delivery_page.dart';
import 'package:sudafood/models/order_model.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = true;
  String _currency = 'ج.س';
  final OrderService _orderService = OrderService();

  // معرف السائق الحالي لربطه بالطلب
  final String _currentDriverId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadDriverSettings();
  }

  // تحميل العملة بناءً على الدولة
  Future<void> _loadDriverSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String country = prefs.getString('selected_country') ?? 'Sudan';
    if (mounted) {
      setState(() {
        _currency = (country == 'Sudan') ? 'ج.س' : 'RWF';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات التوصيل المتاحة",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        actions: [
          _buildOnlineStatusSwitch(),
          const SizedBox(width: 16),
        ],
      ),
      body: _isOnline ? _buildOrdersStream() : _buildOfflineState(),
    );
  }

  // جلب الطلبات التي حالتها "Ready" (جاهزة للاستلام من المطبخ)
  Widget _buildOrdersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'ready') //  فقط الجاهزة
          // يمكن إضافة فلتر الدولة هنا أيضاً إذا أردت
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoOrdersState();
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = OrderModel.fromMap(
                orders[index].data() as Map<String, dynamic>, orders[index].id);
            return _buildOrderItemCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderItemCard(OrderModel order) {
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
              Text("${order.totalAmount} $_currency",
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          const Divider(height: 24),
          _buildLocationInfo(LucideIcons.store, "من: ${order.restaurantName}",
              "استلام الطلب من المطعم"),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert, size: 16, color: Colors.grey),
          ),
          _buildLocationInfo(
              LucideIcons.mapPin, "إلى: منزل العميل", "التوصيل للوجهة المحددة"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: "قبول واستلام",
                  onPressed: () async {
                    try {
                      // 1. تحديث الحالة + تعيين السائق المسؤول
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(order.id)
                          .update({
                        'status': 'delivering',
                        'driverId': _currentDriverId, // 👈 ربط الطلب بالسائق
                      });

                      // 2. الانتقال لصفحة التوصيل النشط
                      if (mounted) {
                        Navigator.pushReplacement(
                          // استخدمنا Replacement لكي لا يعود لهذه القائمة بالخطأ
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DeliveryPage(order: order)), // ✅ نمرر الطلب
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        UIHelpers.showSnackBar(context, "حدث خطأ: $e",
                            isError: true);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // منطق التجاهل المحلي (إخفاء العنصر من القائمة مؤقتاً)
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text("تجاهل",
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineStatusSwitch() {
    return Row(
      children: [
        Text(_isOnline ? "متصل" : "متوقف",
            style: TextStyle(
                color: _isOnline ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        Switch.adaptive(
          value: _isOnline,
          activeColor: Colors.green,
          onChanged: (val) => setState(() => _isOnline = val),
        ),
      ],
    );
  }

  Widget _buildNoOrdersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageSearch, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("لا توجد طلبات جاهزة حالياً",
              style: TextStyle(
                  color: Colors.grey, fontSize: 16, fontFamily: 'Cairo')),
          const Text("سيظهر الطلب هنا فور تجهيزه من المطبخ",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.moon, size: 80, color: Colors.blueGrey[100]),
          const SizedBox(height: 16),
          const Text("أنت في وضع الراحة",
              style: TextStyle(
                  color: Colors.grey, fontSize: 18, fontFamily: 'Cairo')),
          const Text("قم بتفعيل الاتصال لاستقبال الطلبات",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
