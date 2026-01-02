import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final BoxShape shape;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12, // توحيد الحواف مع AppCard
    this.margin,
    this.shape = BoxShape.rectangle,
  });

  // منشئ مسمى للهياكل الدائرية (مثل صور الملف الشخصي)
  const AppSkeleton.circle({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة الثيم لضبط ألوان الوميض
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        // استخدام درجات رمادية تتوافق مع AppColors.cardDark في الوضع الليلي
        baseColor: isDark ? AppColors.borderDark : Colors.grey[300]!,
        highlightColor:
            isDark ? AppColors.cardDark.withOpacity(0.5) : Colors.grey[100]!,
        period: const Duration(milliseconds: 1500), // سرعة وميض مريحة للعين
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: shape,
            borderRadius: shape == BoxShape.circle
                ? null
                : BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
