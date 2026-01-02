import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class AppRatingBar extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color? activeColor;

  const AppRatingBar({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 16,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        IconData iconData;
        Color color;

        // 1. تحديد أيقونة النجمة بناءً على قيمة التقييم
        if (index < rating.floor()) {
          // نجمة ممتلئة بالكامل
          iconData = Icons.star_rounded;
          color = activeColor ?? AppColors.warning;
        } else if (index < rating && (rating - index) >= 0.1) {
          // نجمة نصف ممتلئة (للتقييمات مثل 4.5)
          iconData = Icons.star_half_rounded;
          color = activeColor ?? AppColors.warning;
        } else {
          // نجمة فارغة
          iconData = Icons.star_rounded;
          color = Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : Colors.grey[300]!;
        }

        return Icon(
          iconData,
          size: size,
          color: color,
        );
      }),
    );
  }
}
