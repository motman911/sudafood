import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استخدام استدعاءات الـ Package الموحدة للمشروع
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/core/services/auth_service.dart'; // ✅ استخدام السيرفس الموحد

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // ✅

  String _selectedCountry = 'Sudan';
  String _selectedRole = 'customer'; // ✅ الدور الافتراضي
  bool _isLoading = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // ✅ استخدام السيرفس الذي يضمن إنشاء ملف المطعم تلقائياً
        await _authService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          country: _selectedCountry,
          role: _selectedRole, // إرسال الدور المختار
        );

        if (mounted) {
          UIHelpers.showSnackBar(context, "تم إنشاء الحساب بنجاح ✅");
          Navigator.pop(context); // العودة لتسجيل الدخول
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showSnackBar(context, "حدث خطأ: ${e.toString()}",
              isError: true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("إنشاء حساب جديد",
              style: TextStyle(fontFamily: 'Cairo'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("انضم إلى عائلة سودافود واستمتع بأشهى الوجبات",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
              UIHelpers.verticalSpaceLarge,

              AppInput(
                  label: "الاسم الكامل",
                  hint: "محمد أحمد",
                  controller: _nameController,
                  prefixIcon: LucideIcons.user, // ✅ أيقونة
                  validator: (val) => val!.isEmpty ? "مطلوب" : null),
              UIHelpers.verticalSpaceSmall,

              AppInput(
                  label: "البريد الإلكتروني",
                  hint: "example@mail.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress, // ✅ نوع الكيبورد
                  prefixIcon: LucideIcons.mail,
                  validator: (val) => val!.isEmpty ? "مطلوب" : null),
              UIHelpers.verticalSpaceSmall,

              AppInput(
                  label: "رقم الهاتف",
                  hint: "0912345678",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: LucideIcons.phone,
                  validator: (val) => val!.isEmpty ? "مطلوب" : null),
              UIHelpers.verticalSpaceSmall,

              // ✅ اختيار الدولة
              _buildDropdown(
                label: "الدولة",
                value: _selectedCountry,
                items: const [
                  DropdownMenuItem(value: 'Sudan', child: Text("السودان 🇸🇩")),
                  DropdownMenuItem(value: 'Rwanda', child: Text("رواندا 🇷🇼")),
                ],
                onChanged: (val) => setState(() => _selectedCountry = val!),
              ),
              UIHelpers.verticalSpaceSmall,

              // ✅ اختيار نوع الحساب (مهم جداً!)
              _buildDropdown(
                label: "نوع الحساب",
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(
                      value: 'customer', child: Text("زبون (أريد طلب طعام)")),
                  DropdownMenuItem(
                      value: 'vendor', child: Text("مطعم (أريد بيع طعام)")),
                  DropdownMenuItem(
                      value: 'driver', child: Text("سائق (أريد توصيل)")),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),

              UIHelpers.verticalSpaceSmall,
              AppInput(
                  label: "كلمة المرور",
                  hint: "********",
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: LucideIcons.lock,
                  validator: (val) => val!.length < 6 ? "قصيرة جداً" : null),

              UIHelpers.verticalSpaceLarge,
              AppButton(
                  text: "إنشاء الحساب",
                  onPressed: _handleRegister,
                  isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ويدجت موحد للقوائم المنسدلة
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!), // لون حدود أوضح
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
