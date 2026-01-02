import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ✅ استيراد ملفات Firebase والخيارات
import 'firebase_options.dart';

// ✅ استيراد الثيم والألوان
import 'package:sudafood/core/theme/app_colors.dart';

// ✅ استيراد المزودات (Providers)
import 'package:sudafood/core/providers/cart_provider.dart';

// ✅ استيراد الموجه الذكي (الذي أنشأناه في الخطوات السابقة)
import 'package:sudafood/features/auth/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SudaFoodApp());
}

class SudaFoodApp extends StatelessWidget {
  const SudaFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ تسجيل سلة المشتريات لتكون متاحة لكل التطبيق
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const SudaFoodMaterialApp(),
    );
  }
}

class SudaFoodMaterialApp extends StatelessWidget {
  const SudaFoodMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SudaFood - سودافود',
      debugShowCheckedModeBanner: false,

      // ✅ إعداد الثيم (Theme) باستخدام ألواننا الموحدة
      theme: ThemeData(
        fontFamily: 'Cairo', // الخط العربي
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo'),
        ),
      ),

      // ✅ دعم اللغة العربية
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ✅ نقطة البداية: الموجه الذكي (ينقلنا للوجين أو الصفحة الرئيسية حسب الحالة)
      home: const AuthWrapper(),
    );
  }
}
