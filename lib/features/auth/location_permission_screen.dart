import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استخدام استدعاءات الحزم الموحدة لضمان استقرار المسارات
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/customer/home/screens/home_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة الوضع الداكن لضبط ألوان النصوص
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

              // شعار الموقع الجغرافي بتصميم SudaFood المطور
              Container(
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  // استخدام تدرج لوني خفيف خلف الأيقونة
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  LucideIcons.mapPin,
                  size: 70,
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
                  fontFamily: 'Cairo', // الخط الموحد للمشروع
                ),
              ),

              UIHelpers.verticalSpaceSmall,

              Text(
                "نحتاج الوصول لموقعك الحالي لعرض المطاعم القريبة منك في الخرطوم أو كيجالي وتوصيل طلبك بدقة.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),

              const Spacer(),

              // زر السماح الأساسي
              AppButton(
                text: "السماح بالوصول للموقع",
                onPressed: () {
                  // مستقبلاً: التكامل مع حزمة geolocator
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),

              UIHelpers.verticalSpaceSmall,

              // زر الإدخال اليدوي
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text(
                  "إدخال الموقع يدوياً",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    fontSize: 16,
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
}
