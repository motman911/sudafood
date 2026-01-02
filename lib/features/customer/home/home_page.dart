import 'package:flutter/material.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_card.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("طلبات المطبخ"),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: "جديد (2)"),
              Tab(text: "قيد التجهيز"),
              Tab(text: "جاهز"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(context, "new"),
            _buildOrdersList(context, "processing"),
            _buildOrdersList(context, "ready"),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, String status) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // تفاصيل الطلب
              const Text("طلب #1023",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text("2x تشيز برجر", style: TextStyle(fontSize: 14)),
              const SizedBox(height: 20),

              // الأزرار المصححة
              if (status == "new")
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: "قبول",
                        height: 45, // ✅ تم تحديد الارتفاع المطلوب
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        // ✅ استخدام زر عادي للرفض لتجنب خطأ ButtonType
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("رفض"),
                      ),
                    ),
                  ],
                )
              else if (status == "processing")
                AppButton(
                  text: "جاهز للتوصيل",
                  height: 45, // ✅ تم تحديد الارتفاع
                  onPressed: () {},
                )
            ],
          ),
        );
      },
    );
  }
}
