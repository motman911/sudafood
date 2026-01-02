import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استيراد المكونات والسمات الموحدة
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("محفظة الأرباح",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ جلب الطلبات التي قام هذا السائق بتوصيلها بنجاح فقط
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('driverId', isEqualTo: user?.uid)
            .where('status', isEqualTo: 'completed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          // ✅ حساب إجمالي الأرباح ديناميكياً
          double totalEarnings = orders.fold(0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return sum + (data['driverCommission'] ?? 0.0);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. كارت الملخص العلوي (تم استبدال AppCard بـ Container لحل مشكلة اللون)
                _buildTotalBalanceCard(totalEarnings),

                UIHelpers.verticalSpaceLarge,

                // 2. قائمة العمليات الأخيرة
                const Text("سجل التوصيل",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo')),
                UIHelpers.verticalSpaceSmall,

                if (orders.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order =
                          orders[index].data() as Map<String, dynamic>;
                      return _buildTransactionItem(order);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalBalanceCard(double total) {
    // استخدمنا Container هنا لأن AppCard قد لا تدعم معامل color مباشرة
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text("إجمالي الرصيد المتاح",
              style: TextStyle(color: Colors.white70, fontFamily: 'Cairo')),
          UIHelpers.verticalSpaceSmall,
          Text("${total.toStringAsFixed(2)} ج.س",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          UIHelpers.verticalSpaceMedium,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // منطق طلب سحب الرصيد يدوياً
            },
            child: const Text("طلب سحب الأرباح",
                style: TextStyle(fontFamily: 'Cairo')),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> order) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1), // تم تصحيح اللون هنا
          child: const Icon(LucideIcons.arrowUpRight, color: Colors.green),
        ),
        title: Text("طلب #${order['id'].toString().substring(0, 5)}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            order['date']?.toString().substring(0, 10) ?? "تاريخ غير متوفر"),
        trailing: Text("+${order['driverCommission']} ج.س",
            style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          UIHelpers.verticalSpaceLarge,
          Icon(LucideIcons.history, size: 60, color: Colors.grey[300]),
          UIHelpers.verticalSpaceSmall,
          const Text("لا توجد أرباح مسجلة بعد",
              style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}
