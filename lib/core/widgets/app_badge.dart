import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isBold;

  const AppBadge({
    super.key,
    required this.text,
    required this.color,
    this.isBold = true,
  });

  // منشئ مسمى لحالات الطلب لتوحيد الألوان في التطبيق
  factory AppBadge.status(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'new':
        return const AppBadge(text: "جديد", color: AppColors.warning);
      case 'preparing':
        return const AppBadge(text: "قيد التجهيز", color: AppColors.info);
      case 'ready':
        return const AppBadge(text: "جاهز للاستلام", color: AppColors.primary);
      case 'delivered':
      case 'completed':
        return const AppBadge(text: "مكتمل", color: AppColors.success);
      case 'cancelled':
        return const AppBadge(text: "ملغى", color: AppColors.error);
      default:
        return AppBadge(text: status, color: AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // استخدام شفافية أقل في الوضع الداكن لزيادة الوضوح
        color: color.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          fontFamily: 'Cairo', // ضمان استخدام خط المشروع
        ),
      ),
    );
  }
}
