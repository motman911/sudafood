import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استخدام Package Imports لضمان استقرار المسارات وتجنب أخطاء URI
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/auth/screens/login_screen.dart';
import 'package:sudafood/features/customer/profile/screens/edit_profile_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة الثيم لضبط ألوان الخلفية والبطاقات ديناميكياً
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title:
            const Text("الملف الشخصي", style: TextStyle(fontFamily: 'Cairo')),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. قسم الصورة الشخصية والبيانات الأساسية
            _buildHeader(isDark),

            UIHelpers.verticalSpaceLarge,

            // 2. قائمة الخيارات الرئيسية
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                    context,
                    "تعديل المعلومات",
                    LucideIcons.edit,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfileScreen()),
                    ),
                  ),
                  _buildDivider(isDark),
                  _buildProfileOption(
                      context, "العناوين المحفوظة", LucideIcons.mapPin),
                  _buildDivider(isDark),
                  _buildProfileOption(
                      context, "طلباتي السابقة", LucideIcons.shoppingBag),
                  _buildDivider(isDark),
                  _buildProfileOption(
                      context, "المحفظة وطرق الدفع", LucideIcons.creditCard),
                  _buildDivider(isDark),
                  _buildProfileOption(
                      context, "الإعدادات", LucideIcons.settings),
                ],
              ),
            ),

            UIHelpers.verticalSpaceMedium,

            // 3. زر تسجيل الخروج بتصميم بارز
            _buildLogoutButton(context, isDark),

            UIHelpers.verticalSpaceMedium,
            const Text(
              "SudaFood v1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت عرض رأس الصفحة (الصورة والاسم)
  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: isDark ? AppColors.cardDark : Colors.grey[200],
              child: Icon(LucideIcons.user,
                  size: 55,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child:
                  const Icon(LucideIcons.camera, size: 16, color: Colors.white),
            ),
          ],
        ),
        UIHelpers.verticalSpaceSmall,
        const Text(
          "محمد أحمد",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        Text(
          "0912345678",
          style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  // ودجت بناء خيارات القائمة
  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDestructive
        ? Colors.redAccent
        : (isDark ? Colors.white : Colors.black87);

    return ListTile(
      onTap: onTap ?? () {},
      leading: Icon(icon, color: contentColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Cairo',
          color: contentColor,
          fontSize: 15,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  // زر تسجيل الخروج المنفصل
  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? Colors.red.withOpacity(0.1) : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildProfileOption(
        context,
        "تسجيل الخروج",
        LucideIcons.logOut,
        isDestructive: true,
        onTap: () {
          // استخدام pushAndRemoveUntil لمسح سجل التنقل والعودة لصفحة الهوية
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthPage()),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
        height: 1,
        indent: 50,
        endIndent: 20,
        color: isDark ? Colors.grey[800] : Colors.grey[100]);
  }
}
