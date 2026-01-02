import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ استخدام Package Imports لضمان استقرار المسارات البرمجية
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/customer/home/screens/home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode; // ✅ إضافة المتغير لاستقبال رمز الدولة

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode, // ✅ تحديث المشيد لحل خطأ شاشة Login
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // للتحكم في خانات الإدخال الأربعة
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      // الانتقال للخانة التالية تلقائياً عند الإدخال
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // العودة للخانة السابقة عند الحذف لتجربة مستخدم أفضل
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOTP() {
    String otp = _controllers.map((e) => e.text).join();

    if (otp.length == 4) {
      // محاكاة نجاح الدخول -> التوجه للواجهة الرئيسية
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      UIHelpers.showSnackBar(
          context, "الرجاء إدخال الرمز كاملاً المكون من 4 أرقام",
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                UIHelpers.verticalSpaceMedium,
                const Text(
                  "رمز التحقق",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo', // توحيد الخط للمشروع
                  ),
                ),
                UIHelpers.verticalSpaceSmall,
                Text(
                  "أدخل الرمز المرسل إلى ${widget.countryCode} ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                ),

                UIHelpers.verticalSpaceLarge,

                // خانات الـ OTP بتصميم متناسق
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 65,
                      height: 65,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) => _onDigitChanged(value, index),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor:
                              isDark ? AppColors.cardDark : Colors.grey[50],
                          enabledBorder: _buildBorder(isDark
                              ? AppColors.borderDark
                              : Colors.grey[300]!),
                          focusedBorder:
                              _buildBorder(AppColors.primary, width: 2),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    );
                  }),
                ),

                UIHelpers.verticalSpaceExtraLarge,

                // زر التحقق الموحد
                AppButton(
                  text: "تحقق والدخول",
                  onPressed: _verifyOTP,
                ),

                UIHelpers.verticalSpaceMedium,
                TextButton(
                  onPressed: () {
                    // منطق إعادة إرسال الرمز
                  },
                  child: const Text(
                    "إعادة إرسال الرمز",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
