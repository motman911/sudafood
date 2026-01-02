// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ استخدام استدعاءات الـ Package لضمان استقرار المسارات
import 'package:sudafood/core/services/auth_service.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/core/constants/app_constants.dart';

class AuthController {
  // نمط الـ Singleton لضمان وجود نسخة واحدة فقط في الذاكرة
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final AuthService _authService = AuthService();

  // متغيرات الحالة لمراقبة تقدم العمليات
  bool isLoading = false;

  // 1. دالة تسجيل الدخول المحسنة (إرسال رمز التحقق)
  Future<void> login({
    required BuildContext context,
    required String phone,
    required String countryCode,
  }) async {
    try {
      // التحقق من صحة المدخلات قبل بدء العملية
      if (phone.isEmpty) {
        UIHelpers.showSnackBar(context, "الرجاء إدخال رقم الهاتف أولاً",
            isError: true);
        return;
      }

      // إظهار حالة التحميل (Loading)
      _setLoading(true);

      // دمج رمز الدولة مع الرقم (مثلاً: +249912345678)
      final fullPhoneNumber = countryCode + phone;

      // استدعاء خدمة Firebase Auth لإرسال الرمز
      final bool success = await _authService.login(fullPhoneNumber);

      if (success) {
        UIHelpers.showSnackBar(
            context, "تم إرسال رمز التحقق إلى $fullPhoneNumber");
      }
    } catch (e) {
      UIHelpers.showSnackBar(context, "خطأ في الاتصال: ${e.toString()}",
          isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // 2. دالة التحقق من الرمز (OTP Verification)
  Future<bool> verifyOtp({
    required BuildContext context,
    required String otp,
  }) async {
    if (otp.length < 4) {
      UIHelpers.showSnackBar(context, "الرجاء إدخال الرمز المكون من 4 أرقام",
          isError: true);
      return false;
    }

    try {
      _setLoading(true);

      // هنا يتم استدعاء AuthService للتحقق الفعلي من Firebase
      // سنبقي على محاكاة النجاح حالياً للتطوير
      await Future.delayed(const Duration(seconds: 1));

      if (otp == "0000") {
        await _onAuthSuccess(); // حفظ بيانات الجلسة عند النجاح
        return true;
      } else {
        UIHelpers.showSnackBar(context, "رمز التحقق غير صحيح، حاول مرة أخرى",
            isError: true);
        return false;
      }
    } finally {
      _setLoading(false);
    }
  }

  // حفظ حالة تسجيل الدخول محلياً لضمان بقاء المستخدم متصلاً
  Future<void> _onAuthSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, true);
  }

  // دالة مساعدة لتحديث حالة التحميل
  void _setLoading(bool value) {
    isLoading = value;
    // ملاحظة: إذا كنت تستخدم Provider أو GetX، قم بإضافة notifyListeners() هنا
  }
}
