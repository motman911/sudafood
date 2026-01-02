import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/driver/delivery/delivery_page.dart';

class NewOrderAlertScreen extends StatelessWidget {
  // ✅ تعريف المعاملات لاستقبال بيانات الطلب الحقيقي
  final String? restaurantName;
  final double? earnings;
  final String? customerLocation;
  final String? restaurantDistance;
  final String? deliveryDistance;

  const NewOrderAlertScreen({
    super.key,
    this.restaurantName,
    this.earnings,
    this.customerLocation,
    this.restaurantDistance,
    this.deliveryDistance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.primary, // الخلفية البرتقالية المميزة لجذب الانتباه
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // 1. عداد تنازلي بصري (Progress Timer)
              _buildTimerProgress(),

              const SizedBox(height: 30),

              const Text(
                "طلب جديد متاح الآن!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const Text(
                "اضغط قبول قبل انتهاء الوقت",
                style: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
              ),

              const Spacer(),

              // 2. بطاقة تفاصيل الطلب (دمج التصميم الاحترافي)
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text("صافي ربحك المتوقع",
                        style:
                            TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
                    Text(
                      "${earnings ?? '18.50'} ج.س",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(height: 32),

                    // تفاصيل المسار: من المطعم إلى العميل
                    _buildRouteInfo(
                      LucideIcons.store,
                      restaurantName ?? "مطعم البيك - الرياض",
                      restaurantDistance ?? "2.5 كم من موقعك",
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.more_vert,
                              size: 20, color: Colors.grey),
                        ),
                      ),
                    ),
                    _buildRouteInfo(
                      LucideIcons.mapPin,
                      customerLocation ?? "منزل العميل - حي المطار",
                      deliveryDistance ?? "5.0 كم إضافية",
                    ),

                    UIHelpers.verticalSpaceLarge,

                    // 3. أزرار القرار (Accept / Decline)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: "قبول الطلب",
                            onPressed: () {
                              // التوجه لصفحة التوصيل النشط وإغلاق شاشة التنبيه
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const DeliveryPage()),
                              );
                            },
                            height: 55,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("تجاهل",
                                style: TextStyle(
                                    color: Colors.grey, fontFamily: 'Cairo')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ودجت العداد التنازلي الدائري
  Widget _buildTimerProgress() {
    return const Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: 0.7, // يتم ربطه لاحقاً بـ AnimationController
            color: Colors.white,
            strokeWidth: 8,
            backgroundColor: Colors.white24,
          ),
        ),
        Text(
          "21",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ],
    );
  }

  // ودجت عرض معلومات الموقع والمسافة
  Widget _buildRouteInfo(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Cairo'),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
