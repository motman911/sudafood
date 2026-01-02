import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // للمؤثرات الحركية
import 'package:lucide_icons/lucide_icons.dart'; // الأيقونات
import 'package:sudafood/core/theme/app_colors.dart';

// ✅ استدعاء شاشة اختيار الدولة بدلاً من تسجيل الدخول مباشرة
import 'country_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // الانتقال التلقائي بعد 3 ثوانٍ لضمان ظهور المؤثرات
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const CountrySelectionScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary, // البرتقالي الأساسي لـ SudaFood
              AppColors.primaryDark, // البرتقالي الغامق للعمق البصري
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // حركة دوران واختفاء للأيقونة
            ZoomIn(
              duration: const Duration(seconds: 1),
              child: Spin(
                duration: const Duration(seconds: 2),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.utensilsCrossed,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // حركة ظهور النص المحدث "SUDAFOOD"
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  const Text(
                    "SUDAFOOD",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo', // استخدام خط المشروع الموحد
                      letterSpacing: 2.0,
                    ),
                  ),
                  FadeIn(
                    delay: const Duration(milliseconds: 1200),
                    child: Text(
                      "Sudan 🇸🇩 & Rwanda 🇷🇼",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Cairo',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
