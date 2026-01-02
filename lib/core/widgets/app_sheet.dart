import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSheet extends StatelessWidget {
  final Widget child;
  final String? title;

  const AppSheet({super.key, required this.child, this.title});

  // دالة مساعدة ثابتة لعرض الـ Sheet لتوحيد الكود في كل التطبيق
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // لجعل حواف الحاوية تظهر بشكل صحيح
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // للتعامل مع لوحة المفاتيح
        ),
        child: AppSheet(title: title, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      // تحديد قياسات الحاوية بناءً على محتواها
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        // استخدام ألوان الخلفية المحددة في AppColors لضمان العزل البصري
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle (المقبض العلوي)
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo', // توحيد الخط للمشروع
              ),
            ),
            const SizedBox(height: 16),
          ],

          // تغليف المحتوى بـ Flexible للسماح بالتمرير إذا كان المحتوى طويلاً
          Flexible(child: child),
        ],
      ),
    );
  }
}
