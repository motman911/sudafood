import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

// استيراد المكونات المخصصة والثوابت
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/constants/app_constants.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/customer/home/screens/home_screen.dart';

class CountrySelectionScreen extends StatelessWidget {
  const CountrySelectionScreen({super.key});

  // دالة حفظ الدولة وتوجيه المستخدم بناءً على الهوية الجغرافية
  Future<void> _onCountrySelected(
      BuildContext context, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();

    // حفظ الدولة المختارة لعزل البيانات (مطاعم السودان عن رواندا)
    await prefs.setString(AppConstants.countryKey, countryCode);

    if (context.mounted) {
      // التوجه للصفحة الرئيسية مع تطبيق الهوية الجديدة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار SudaFood المطور
            const Icon(
              LucideIcons.utensilsCrossed,
              size: 80,
              color: AppColors.primary,
            ),
            UIHelpers.verticalSpaceMedium,
            const Text(
              "مرحباً بك في SudaFood",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo', // استخدام الخط الموحد
              ),
            ),
            UIHelpers.verticalSpaceExtraSmall,
            Text(
              "الرجاء اختيار الدولة لتخصيص تجربتك الجغرافية",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 15,
                fontFamily: 'Cairo',
              ),
            ),
            UIHelpers.verticalSpaceLarge,

            // خيار السودان باستخدام AppCard الموحد
            _buildCountryItem(
              context: context,
              title: "السودان",
              flag: "🇸🇩",
              countryCode: AppConstants.countrySudan,
              subtitle: "اطلب أشهى الوجبات في الخرطوم والولايات",
            ),

            UIHelpers.verticalSpaceSmall,

            // خيار رواندا باستخدام AppCard الموحد
            _buildCountryItem(
              context: context,
              title: "رواندا",
              flag: "🇷🇼",
              countryCode: AppConstants.countryRwanda,
              subtitle: "Enjoy the best food delivery in Kigali",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryItem({
    required BuildContext context,
    required String title,
    required String flag,
    required String countryCode,
    required String subtitle,
  }) {
    return AppCard(
      onTap: () => _onCountrySelected(context, countryCode),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          // عرض العلم بحجم واضح
          Text(flag, style: const TextStyle(fontSize: 36)),
          UIHelpers.horizontalSpaceMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronLeft, color: AppColors.primary),
        ],
      ),
    );
  }
}
