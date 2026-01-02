import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ استخدام استدعاءات الحزم الموحدة لضمان استقرار المسارات
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: StreamBuilder<QuerySnapshot>(
        // ✅ جلب أحدث طلب نشط لهذا العميل لحظياً من Firestore
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerId', isEqualTo: user?.uid)
            .orderBy('date', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildNoActiveOrder(isDark, context);
          }

          final orderDoc = snapshot.data!.docs.first;
          final orderData = orderDoc.data() as Map<String, dynamic>;
          final String status = orderData['status'] ?? 'pending';

          return Stack(
            children: [
              // 1. عرض الخريطة الحية أو مكانها المخصص
              _buildMapPlaceholder(isDark, status),

              // 2. زر العودة بتصميم عائم متوافق مع الاتجاهات
              _buildFloatingBackButton(context, isDark),

              // 3. بطاقة معلومات التتبع الديناميكية
              _buildTrackingSheet(isDark, status, orderData),
            ],
          );
        },
      ),
    );
  }

  // ودجت بناء مكان الخريطة مع تغيير الأيقونات حسب الحالة
  Widget _buildMapPlaceholder(bool isDark, String status) {
    IconData mapIcon = LucideIcons.map;
    if (status == 'preparing') mapIcon = LucideIcons.chefHat;
    if (status == 'on_way' || status == 'delivering') {
      mapIcon = LucideIcons.bike;
    }
    if (status == 'delivered') mapIcon = LucideIcons.home;

    return Container(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[200],
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(mapIcon,
                size: 64, color: isDark ? Colors.grey[800] : Colors.grey[400]),
            UIHelpers.verticalSpaceSmall,
            Text(
              status == 'on_way' || status == 'delivering'
                  ? "السائق في طريقه إليك..."
                  : "جاري تحديث الموقع...",
              style: TextStyle(
                color: isDark ? Colors.grey[700] : Colors.grey[500],
                fontSize: 16,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة تتبع الحالة والتقدم مع دعم اللحظية
  Widget _buildTrackingSheet(
      bool isDark, String status, Map<String, dynamic> data) {
    double progressValue = 0.25;
    String statusMsg = "تم استلام طلبك وبانتظار الموافقة...";

    // تحديث شريط التقدم والرسائل بناءً على الحالة الحقيقية
    if (status == 'preparing') {
      progressValue = 0.5;
      statusMsg = "المطعم يقوم بتحضير وجبتك الآن 👨‍🍳";
    } else if (status == 'on_way' || status == 'delivering') {
      progressValue = 0.75;
      statusMsg = "طلبك مع السائق وفي طريقه إليك 🛵";
    } else if (status == 'delivered') {
      progressValue = 1.0;
      statusMsg = "تم توصيل الطلب.. بالعافية! ❤️";
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            UIHelpers.verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("وقت الوصول المتوقع",
                    style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
                Text("25-30 دقيقة",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black)),
              ],
            ),
            UIHelpers.verticalSpaceMedium,
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor:
                    isDark ? Colors.grey[900] : const Color(0xFFF3F4F6),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            UIHelpers.verticalSpaceSmall,
            Text(statusMsg,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: AppColors.primary)),
            const Divider(height: 40),
            _buildDriverSection(isDark, data),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSection(bool isDark, Map<String, dynamic> data) {
    return Row(
      children: [
        _buildDriverAvatar(),
        UIHelpers.horizontalSpaceMedium,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['driverName'] ?? "جاري تعيين سائق...",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Cairo',
                    color: isDark ? Colors.white : Colors.black),
              ),
              const Text("خدمة التوصيل السريع",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        if (data['driverPhone'] != null) _buildCallButton(),
      ],
    );
  }

  Widget _buildNoActiveOrder(bool isDark, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageCheck, size: 80, color: Colors.grey[300]),
          UIHelpers.verticalSpaceMedium,
          const Text("لا توجد طلبات نشطة حالياً",
              style: TextStyle(fontFamily: 'Cairo', fontSize: 18)),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("العودة للرئيسية")),
        ],
      ),
    );
  }

  Widget _buildFloatingBackButton(BuildContext context, bool isDark) {
    return Positioned(
      top: 50,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_forward,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildDriverAvatar() {
    return Container(
      width: 55,
      height: 55,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
      padding: const EdgeInsets.all(2),
      child: const ClipOval(
          child: Icon(Icons.person, color: Colors.white, size: 30)),
    );
  }

  Widget _buildCallButton() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
      child: IconButton(
          icon:
              const Icon(LucideIcons.phone, color: AppColors.primary, size: 22),
          onPressed: () {}),
    );
  }
}
