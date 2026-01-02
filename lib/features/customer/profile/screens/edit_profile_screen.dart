import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ✅ استخدام استدعاءات الـ Package لضمان استقرار المسارات وتجنب أخطاء URI
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // متحكمات النصوص (تستبدل لاحقاً ببيانات المستخدم الفعلية من Firebase)
  final TextEditingController _nameController =
      TextEditingController(text: "محمد أحمد");
  final TextEditingController _phoneController =
      TextEditingController(text: "0912345678");
  final TextEditingController _emailController =
      TextEditingController(text: "mohamed@example.com");

  bool _isSaving = false;

  void _saveChanges() async {
    setState(() => _isSaving = true);

    // محاكاة الاتصال بـ Firebase Firestore لتحديث البيانات
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSaving = false);

    // إظهار رسالة نجاح باستخدام UIHelpers الموحد
    UIHelpers.showSnackBar(context, "تم تحديث ملفك الشخصي بنجاح ✅");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("تعديل الملف الشخصي",
            style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. قسم الصورة الشخصية مع زر التعديل
            _buildImagePicker(isDark),

            UIHelpers.verticalSpaceLarge,

            // 2. حقول الإدخال
            AppInput(
              controller: _nameController,
              label: "الاسم الكامل",
              hint: "أدخل اسمك الثلاثي",
              prefixIcon: const Icon(LucideIcons.user, size: 20),
            ),

            UIHelpers.verticalSpaceSmall,

            AppInput(
              controller: _phoneController,
              label: "رقم الهاتف",
              hint: "09XXXXXXXX",
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(LucideIcons.phone, size: 20),
            ),

            UIHelpers.verticalSpaceSmall,

            AppInput(
              controller: _emailController,
              label: "البريد الإلكتروني",
              hint: "example@mail.com",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(LucideIcons.mail, size: 20),
            ),

            UIHelpers.verticalSpaceExtraLarge,

            // 3. زر الحفظ المطور
            AppButton(
              text: "حفظ التغييرات",
              isLoading: _isSaving, // دعم حالة التحميل داخل الزر نفسه
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl:
                    "https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=400",
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(LucideIcons.user,
                    size: 60,
                    color: isDark ? Colors.grey[700] : Colors.grey[300]),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {/* منطق اختيار صورة من معرض الصور */},
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(LucideIcons.camera,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
