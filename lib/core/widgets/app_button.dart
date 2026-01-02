import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonType { primary, outline, ghost, destructive }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double height; // تحويلها لـ double وتفعيل استخدامها

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 50.0, // قيمة افتراضية اختيارية
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // تحديد الألوان بناءً على النوع والوضع (فاتح/داكن)
    Color backgroundColor;
    Color textColor;
    BorderSide? borderSide;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case ButtonType.destructive:
        backgroundColor = AppColors.error;
        textColor = Colors.white;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = isDark ? Colors.white : AppColors.textPrimary;
        borderSide = BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight);
        break;
      case ButtonType.ghost:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        break;
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height, // استخدام المعامل الممرر فعلياً
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: (type == ButtonType.primary && !isDark) ? 2 : 0,
          side: borderSide,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Cairo', // ضمان استخدام خط المشروع
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
