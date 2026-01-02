import 'package:flutter/material.dart';

class AppColors {
  // --- ألوان الهوية الأساسية (SudaFood Brand) ---
  // اللون البرتقالي الأساسي - يرمز للحيوية والطعام
  static const Color primary = Color(0xFFF97316);
  static const Color primaryDark = Color(0xFFC2410C);
  static const Color primaryLight = Color(0xFFFFF7ED);

  // --- ألوان التفاعل والتوازن (Interaction) ---
  static const Color accent = Color(0xFF0F172A); // كحلي غامق للتوازن البصري
  static const Color highlight = Color(0xFFFB923C);

  // --- ألوان الخلفيات (Backgrounds) ---
  // تم تحسين الدرجات لتناسب معايير Shadcn UI
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF020817);

  // --- ألوان البطاقات والعناصر (Surface) ---
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B);

  // --- ألوان النصوص (Typography) ---
  // تباين عالي لضمان القراءة السهلة في ظروف الإضاءة المختلفة
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textInverse = Colors.white;

  // --- الحدود والفواصل (Borders) ---
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // --- ألوان الحالات (Semantic Colors) ---
  static const Color success = Color(0xFF10B981); // أخضر زمردي للطلبات المكتملة
  static const Color error = Color(0xFFEF4444); // أحمر للطلبات الملغاة
  static const Color warning = Color(0xFFF59E0B); // برتقالي للطلبات المعلقة
  static const Color info = Color(0xFF0EA5E9); // أزرق لمعلومات التوصيل

  // --- ألوان خاصة بتعدد الدول (Country Specific) ---
  // تستخدم بلمسات خفيفة لتمييز الفرع
  static const Color sudanGreen = Color(0xFF007229);
  static const Color rwandaBlue = Color(0xFF00A1DE);
}
