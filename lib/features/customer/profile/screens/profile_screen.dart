import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استخدام استيراد الـ Package لضمان استقرار المسارات
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة الثيم لضبط الألوان
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title:
            const Text("الملف الشخصي", style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. قسم معلومات المستخدم
            _buildUserHeader(isDark),

            UIHelpers.verticalSpaceLarge,

            // 2. قائمة الخيارات
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                      context, "تعديل المعلومات", LucideIcons.edit),
                  _buildDivider(isDark),
                  _buildProfileOption(
                      context, "العناوين المحفوظة", LucideIcons.mapPin),
                  _buildDivider(isDark),
                  _buildProfileOption(
                      context, "المحفظة وطرق الدفع", LucideIcons.creditCard),
                  _buildDivider(isDark),
                  _buildProfileOption(
                      context, "الإعدادات", LucideIcons.settings),
                  _buildDivider(isDark),
                  _buildProfileOption(
                      context, "مركز المساعدة", LucideIcons.helpCircle),
                ],
              ),
            ),

            UIHelpers.verticalSpaceLarge,

            // 3. زر تسجيل الخروج
            _buildLogoutOption(context),
          ],
        ),
      ),
    );
  }

  // رأس الصفحة
  Widget _buildUserHeader(bool isDark) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor:
              isDark ? AppColors.cardDark : const Color(0xFFF3F4F6),
          child: Icon(LucideIcons.user,
              size: 45, color: isDark ? Colors.grey[400] : Colors.grey),
        ),
        UIHelpers.verticalSpaceSmall,
        const Text(
          "محمد أحمد",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        const Text(
          "0912345678", // مثال لرقم سوداني
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // خيارات القائمة
  Widget _buildProfileOption(BuildContext context, String title, IconData icon,
      {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      leading: Icon(icon,
          color: isDestructive ? Colors.red : AppColors.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Cairo',
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  // زر تسجيل الخروج المعدل
  Widget _buildLogoutOption(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildProfileOption(context, "تسجيل الخروج", LucideIcons.logOut,
          isDestructive: true, onTap: () {
        // ✅ تم تغيير الوجهة إلى AuthPage بدلاً من LoginScreen
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthPage()),
            (route) => false);
      }),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: isDark ? Colors.grey[800] : Colors.grey[200]);
  }
}
