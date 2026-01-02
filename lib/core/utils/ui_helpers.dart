import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UIHelpers {
  // --- مسافات عمودية ثابتة (Vertical Spaces) ---
  static const SizedBox verticalSpaceExtraSmall = SizedBox(height: 5);
  static const SizedBox verticalSpaceSmall = SizedBox(height: 10);
  static const SizedBox verticalSpaceMedium = SizedBox(height: 20);
  static const SizedBox verticalSpaceLarge = SizedBox(height: 40);
  static const SizedBox verticalSpaceExtraLarge = SizedBox(height: 60);

  // --- مسافات أفقية ثابتة (Horizontal Spaces) ---
  static const SizedBox horizontalSpaceSmall = SizedBox(width: 10);
  static const SizedBox horizontalSpaceMedium = SizedBox(width: 20);
  static const SizedBox horizontalSpaceLarge = SizedBox(width: 30);

  // --- أدوات قياس الشاشة الديناميكية ---
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // --- عرض رسالة منبثقة (SnackBar) محسنة ---
  // تم ربط الألوان بـ AppColors لضمان التناسق مع الهوية
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    // تحديد اللون بناءً على حالة الرسالة
    Color bgColor = AppColors.success;
    if (isError) bgColor = AppColors.error;
    if (isWarning) bgColor = AppColors.warning;

    ScaffoldMessenger.of(context)
        .clearSnackBars(); // إغلاق أي رسالة سابقة فوراً
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Cairo', // استخدام الخط الموحد للمشروع
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- حواف العناصر الموحدة (BorderRadius) ---
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(8);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(12);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(20);
}
