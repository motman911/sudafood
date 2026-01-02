class AppConstants {
  // --- إعدادات النظام وتعدد الدول ---
  static const String appName = "SudaFood";

  // مفاتيح الدول المدعومة
  static const String countrySudan = "Sudan";
  static const String countryRwanda = "Rwanda";

  // --- إعدادات الاتصال بالسيرفر (API) ---
  // ملاحظة: بما أننا نستخدم Firebase، سنستخدم هذه الروابط للوظائف المخصصة (Cloud Functions)
  static const String apiBaseUrl = "https://api.sudafood.com/v1";
  static const int apiTimeout =
      20000; // تم رفعها لـ 20 ثانية لتناسب سرعة الإنترنت في المنطقة

  // --- مفاتيح التخزين المحلي (SharedPreferences Keys) ---
  // نستخدم هذه المفاتيح لعزل تجربة المستخدم حسب موقعه
  static const String countryKey = "selected_country";
  static const String isLoggedInKey =
      "is_logged_in"; // ✅ تم إضافته لحل خطأ الـ Controller
  static const String currencyKey = "app_currency";
  static const String tokenKey = "auth_token";
  static const String userKey = "user_data";
  static const String themeKey = "is_dark_mode";
  static const String localeKey = "app_locale";
  static const String onboardingKey = "onboarding_complete";

  // --- مسارات Firebase Storage (Firebase Storage Paths) ---
  // لتنظيم رفع الصور في السيرفر حسب الدولة
  static const String pathRestaurants = "restaurants_images";
  static const String pathMenu = "menu_items_images";
  static const String pathProfiles = "user_profiles";

  // --- قيود التحقق (Validation Limits) ---
  static const int minPasswordLength = 8;
  static const int phoneLengthSudan = 10;
  static const int phoneLengthRwanda = 9;

  // --- رموز العملات والمفاتيح الجغرافية ---
  static const String currencySudan = "SDG";
  static const String currencyRwanda = "RWF";
  static const String codeSudan = "+249";
  static const String codeRwanda = "+250";
}
