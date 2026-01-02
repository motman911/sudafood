// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// استيراد المكونات المخصصة والثوابت لضمان وحدة التصميم
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/auth/screens/country_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // إعداد تأثير ظهور تدريجي (Fade) لتحسين تجربة المستخدم
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToNext() async {
    // انتظار 3 ثوانٍ لعرض الهوية البصرية وترسيخ العلامة التجارية
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // الانتقال السلس لشاشة اختيار الدولة
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CountrySelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // تطبيق التدرج اللوني الموحد للهوية البصرية
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار المطور في دائرة شبه شفافة لتعزيز الوضوح
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  LucideIcons.utensilsCrossed,
                  size: 70, // تكبير الحجم قليلاً للتأثير البصري
                  color: Colors.white,
                ),
              ),
              UIHelpers.verticalSpaceMedium,

              // النص الرئيسي باستخدام خط Cairo المعتمد للمشروع
              const Text(
                "SUDAFOOD",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  letterSpacing: 3.0,
                ),
              ),

              UIHelpers.verticalSpaceExtraSmall,

              // شعار التوسع الإقليمي لتعزيز ثقة المستخدم في المنطقتين
              Text(
                "Sudan 🇸🇩 | Rwanda 🇷🇼",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontFamily: 'Cairo',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
