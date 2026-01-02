import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ استدعاء المكونات والخدمات الموحدة
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/auth/auth_controller.dart';
import 'location_permission_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode; // لإظهار الرمز الصحيح (+249 أو +250)

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isVerifying = false;

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // تنفيذ التحقق تلقائياً عند إدخال آخر رقم
    if (index == 3 && value.isNotEmpty) _verify();
  }

  Future<void> _verify() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 4) return;

    setState(() => _isVerifying = true);

    // استدعاء المتحكم لإتمام العملية
    bool success = await AuthController().verifyOtp(
      context: context,
      otp: otp,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const LocationPermissionScreen()),
      );
    }
    setState(() => _isVerifying = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "رمز التحقق",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
            UIHelpers.verticalSpaceExtraSmall,
            Text(
              "أدخل الرمز المرسل إلى ${widget.countryCode} ${widget.phoneNumber}",
              style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
            ),
            UIHelpers.verticalSpaceLarge,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  List.generate(4, (index) => _buildOtpField(index, isDark)),
            ),
            const Spacer(),
            AppButton(
              text: "تأكيد الرمز",
              isLoading: _isVerifying, // دعم حالة التحميل
              onPressed: _verify,
            ),
            UIHelpers.verticalSpaceMedium,
          ],
        ),
      ),
    );
  }

  Widget _buildOtpField(int index, bool isDark) {
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
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: isDark ? AppColors.cardDark : Colors.grey.shade50,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
