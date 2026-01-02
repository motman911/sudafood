// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استيراد المسارات الموحدة
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  // 1: التوجه للمطعم، 2: الاستلام والتحقق، 3: التوجه للعميل
  int _currentStep = 1;

  void _nextStep() {
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
      } else {
        // ✅ إتمام العملية بنجاح وتحديث حالة الطلب في Firebase يدوياً مستقبلاً
        _showSuccessAndFinish();
      }
    });
  }

  void _showSuccessAndFinish() {
    UIHelpers.showSnackBar(context, "تم توصيل الطلب بنجاح! 💵");
    // العودة للشاشة الرئيسية للسائق للبحث عن طلبات جديدة
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // نصوص الأزرار والعناوين الديناميكية بناءً على المرحلة الحالية
  String get _buttonText {
    switch (_currentStep) {
      case 1:
        return "وصلت للمطعم";
      case 2:
        return "تم استلام الطلب (بدء التوصيل)";
      case 3:
        return "تم التسليم للعميل";
      default:
        return "";
    }
  }

  String get _titleText {
    switch (_currentStep) {
      case 1:
        return "توجه إلى المطعم";
      case 2:
        return "تحقق من محتويات الطلب";
      case 3:
        return "توجه إلى موقع العميل";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("توصيل نشط",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. منطقة الخريطة (Navigation Placeholder)
          Expanded(
            child: _buildMapArea(isDark),
          ),

          // 2. لوحة تحكم السائق (Control Panel)
          _buildDriverControlPanel(isDark),
        ],
      ),
    );
  }

  Widget _buildMapArea(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[900] : Colors.grey[200],
      child: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.navigation,
                    size: 64, color: AppColors.primary),
                SizedBox(height: 16),
                Text("جاري عرض المسار الأسرع...",
                    style: TextStyle(
                        color: Colors.grey, fontSize: 16, fontFamily: 'Cairo')),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: "recenter",
              backgroundColor: Colors.blue,
              child: const Icon(LucideIcons.locateFixed, color: Colors.white),
              onPressed: () {
                // فتح خرائط جوجل الخارجية مستقبلاً
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverControlPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مؤشر الخطوات (Stepper)
          Row(
            children: [
              _buildStepDot(1),
              _buildStepLine(1),
              _buildStepDot(2),
              _buildStepLine(2),
              _buildStepDot(3),
            ],
          ),
          const SizedBox(height: 24),

          // معلومات الوجهة الحالية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_titleText,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo')),
                  Text(
                      _currentStep <= 2
                          ? "مطعم البيك - شارع 15"
                          : "منزل العميل - حي الرياض",
                      style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                          fontSize: 13)),
                ],
              ),
              _buildActionButton(LucideIcons.phone, AppColors.primary, () {}),
            ],
          ),
          const SizedBox(height: 20),

          // تفاصيل الطلب تظهر فقط عند التواجد في المطعم (المرحلة 2)
          if (_currentStep == 2) _buildOrderChecklist(isDark),

          // زر الانتقال للمرحلة التالية
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: _nextStep,
              child: Text(_buttonText,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderChecklist(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("تأكد من استلام الوجبات التالية:",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  fontSize: 14)),
          SizedBox(height: 8),
          Text("• 2x وجبة برجر عائلي", style: TextStyle(fontSize: 13)),
          Text("• 1x بطاطس حجم كبير", style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step) {
    bool isActive = _currentStep >= step;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey[300],
        shape: BoxShape.circle,
        border: isActive ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Icon(isActive ? Icons.check : Icons.circle,
          size: 16, color: Colors.white),
    );
  }

  Widget _buildStepLine(int step) {
    bool isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration:
          BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: IconButton(
          icon: Icon(icon, color: color, size: 20), onPressed: onTap),
    );
  }
}
