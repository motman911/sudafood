import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استخدام Package Imports بدلاً من المسارات النسبية لضمان الاستقرار
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/customer/home/screens/home_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // أيقونة الموقع الجغرافي بتنسيق SudaFood
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.mapPin,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),

              UIHelpers.verticalSpaceLarge,

              const Text(
                "تفعيل الموقع الجغرافي",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo', // توحيد الخط للمشروع
                ),
              ),

              UIHelpers.verticalSpaceSmall,

              Text(
                "نحتاج الوصول لموقعك الحالي في السودان أو رواندا لعرض المطاعم القريبة وتوصيل طلبك بدقة.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // زر السماح باستخدام AppButton المخصص
              AppButton(
                text: "السماح بالوصول للموقع",
                onPressed: () {
                  // هنا سيتم إضافة منطق طلب الصلاحيات الفعلي لاحقاً (Geolocator)
                  _navigateToHome(context);
                },
              ),

              UIHelpers.verticalSpaceSmall,

              // زر التخطي وإدخال الموقع يدوياً
              TextButton(
                onPressed: () => _navigateToHome(context),
                child: const Text(
                  "إدخال الموقع يدوياً",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),

              UIHelpers.verticalSpaceMedium,
            ],
          ),
        ),
      ),
    );
  }

  // دالة الملاحة الموحدة
  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
