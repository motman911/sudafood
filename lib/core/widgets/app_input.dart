import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppInput extends StatelessWidget {
  final String? label; // ✅ جعلناه اختيارياً
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;

  const AppInput({
    super.key,
    this.label, // ✅ لم يعد required
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ عرض العنوان فقط إذا تم تمريره
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Cairo',
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Cairo',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
            // ✅ تحويل IconData إلى Widget وتلوينه حسب المود
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon,
                    color: isDark ? Colors.grey[400] : Colors.grey)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? AppColors.cardDark : Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            // الحدود
            border: _buildBorder(
                isDark ? AppColors.borderDark : AppColors.borderLight),
            enabledBorder: _buildBorder(
                isDark ? AppColors.borderDark : AppColors.borderLight),
            focusedBorder: _buildBorder(AppColors.primary, width: 2),
            errorBorder: _buildBorder(AppColors.error),
            focusedErrorBorder: _buildBorder(AppColors.error, width: 2),
            errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
