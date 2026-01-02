import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? color; // ✅ تمت إضافة هذا المعامل لحل الخطأ
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.color, // ✅ استقبال اللون هنا
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة الثيم الحالية (فاتح أو داكن)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      // استخدام المارجن الممرر أو القيمة الافتراضية للتباعد بين البطاقات
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // ✅ التعديل هنا: استخدام 'color' إذا وجد، وإلا 'backgroundColor'، وإلا لون الثيم الافتراضي
        color: color ??
            backgroundColor ??
            (isDark ? AppColors.cardDark : AppColors.cardLight),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: Border.all(
          // استخدام ألوان الحدود التي حددناها في AppColors
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          // إضافة ظل خفيف جداً في الوضع الفاتح فقط لزيادة العمق
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      // استخدام Material و InkWell لإضافة تأثير اللمس (Ripple Effect)
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          splashColor: AppColors.primary.withOpacity(0.05),
          highlightColor: AppColors.primary.withOpacity(0.02),
          child: Padding(
            // الحشوة الداخلية للبطاقة لضمان مسافات مريحة للمحتوى
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
