import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ استخدام استدعاءات الـ Package الموحدة للمشروع
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
// تأكد أنك أنشأت AppInput (سأرسل كوده في الأسفل إذا لم يكن لديك)
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/customer/home/screens/home_screen.dart';
import 'package:sudafood/features/auth/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;

  // ✅ تسجيل الدخول بالبريد الإلكتروني
  void _handleEmailLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // التوجيه سيتم تلقائياً عبر AuthWrapper في main.dart
      } catch (e) {
        if (mounted) {
          UIHelpers.showSnackBar(
              context, "خطأ: البريد أو كلمة المرور غير صحيحة",
              isError: true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ✅ الدخول كزائر (بدون حساب)
  void _handleGuestLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Center(
          // ✅ توسيط المحتوى
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار (Logo)
                  const Icon(LucideIcons.chefHat,
                      size: 80, color: AppColors.primary),
                  UIHelpers.verticalSpaceMedium,
                  const Text("مرحباً بك في سودافود",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo')),
                  const Text("طعم يجمعنا في كل مكان",
                      style:
                          TextStyle(color: Colors.grey, fontFamily: 'Cairo')),

                  UIHelpers.verticalSpaceLarge,

                  // مدخلات البريد وكلمة المرور
                  AppInput(
                    label: "البريد الإلكتروني",
                    hint: "example@mail.com",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: LucideIcons.mail, // ✅ إضافة أيقونة
                    validator: (val) => val!.isEmpty ? "مطلوب" : null,
                  ),
                  UIHelpers.verticalSpaceMedium,

                  AppInput(
                    label: "كلمة المرور",
                    hint: "********",
                    controller: _passwordController,
                    obscureText: _obscureText,
                    prefixIcon: LucideIcons.lock, // ✅ إضافة أيقونة
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                          color: Colors.grey),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    ),
                    validator: (val) =>
                        val!.length < 6 ? "كلمة المرور قصيرة" : null,
                  ),

                  UIHelpers.verticalSpaceLarge,

                  // زر تسجيل الدخول
                  AppButton(
                    text: "تسجيل الدخول",
                    onPressed: _handleEmailLogin,
                    isLoading: _isLoading,
                  ),

                  UIHelpers.verticalSpaceMedium,
                  _buildDivider(),
                  UIHelpers.verticalSpaceMedium,

                  // ✅ أزرار الدخول البديلة (جوجل وزائر)
                  _buildSocialButtons(),

                  UIHelpers.verticalSpaceLarge,

                  // ✅ رابط التسجيل الجديد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("ليس لديك حساب؟ ",
                          style: TextStyle(fontFamily: 'Cairo')),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen())),
                        child: const Text("سجل الآن",
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text("أو المتابعة عبر",
                style: TextStyle(
                    fontSize: 12, color: Colors.grey, fontFamily: 'Cairo'))),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // زر جوجل (شكل فقط حالياً)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            icon: const Icon(LucideIcons.chrome, color: Colors.red),
            label: const Text("Google",
                style: TextStyle(fontFamily: 'Cairo', color: Colors.black)),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
          ),
        ),
        UIHelpers.verticalSpaceSmall,
        TextButton(
          onPressed: _handleGuestLogin,
          child: const Text("الدخول كزائر (بدون تسجيل)",
              style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                  fontFamily: 'Cairo')),
        ),
      ],
    );
  }
}
