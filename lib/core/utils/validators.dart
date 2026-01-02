import '../constants/app_constants.dart';

class Validators {
  // 1. التحقق من أن الحقل ليس فارغاً
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  // 2. التحقق الذكي من رقم الهاتف (سوداني أو رواندي)
  static String? phone(String? value, String country) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';

    if (country == AppConstants.countrySudan) {
      // التحقق من رقم السودان: 10 أرقام يبدأ بـ 01 أو 09
      final sudanRegex = RegExp(r'^(01|09|012|091|092|096|090)[0-9]{7,8}$');
      if (value.length != AppConstants.phoneLengthSudan ||
          !sudanRegex.hasMatch(value)) {
        return 'رقم هاتف سوداني غير صحيح (10 أرقام)';
      }
    } else if (country == AppConstants.countryRwanda) {
      // التحقق من رقم رواندا: 9 أرقام يبدأ بـ 07
      final rwandaRegex = RegExp(r'^(07)[2|3|8|9][0-9]{7}$');
      if (value.length != AppConstants.phoneLengthRwanda ||
          !rwandaRegex.hasMatch(value)) {
        return 'رقم هاتف رواندي غير صحيح (9 أرقام)';
      }
    }
    return null;
  }

  // 3. التحقق من البريد الإلكتروني
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  // 4. التحقق من قوة كلمة المرور
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن لا تقل عن ${AppConstants.minPasswordLength} أحرف';
    }
    return null;
  }
}
