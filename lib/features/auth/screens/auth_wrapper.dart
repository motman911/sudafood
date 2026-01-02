import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ استيراد الشاشات الأساسية
import 'package:sudafood/features/auth/screens/splash_screen.dart';
import 'package:sudafood/features/auth/screens/country_selection_screen.dart';
import 'package:sudafood/features/auth/screens/login_screen.dart';

// ✅ استيراد لوحات التحكم حسب الدور
import 'package:sudafood/features/customer/home/screens/home_screen.dart'; // للزبون
import 'package:sudafood/features/driver/home/screens/driver_home_screen.dart'; // للسائق
import 'package:sudafood/features/vendor/dashboard/screens/vendor_dashboard_screen.dart'; // للمطعم
import 'package:sudafood/features/admin/dashboard/screens/admin_dashboard_screen.dart'; // للأدمن

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. حالة انتظار الاتصال بـ Firebase Auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // 2. إذا لم يكن المستخدم مسجلاً للدخول -> يذهب لاختيار الدولة
        if (!authSnapshot.hasData) {
          return const CountrySelectionScreen();
        }

        // 3. المستخدم مسجل دخول -> جلب بياناته (الدور - Role) من Firestore
        final User user = authSnapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            // حالة انتظار جلب البيانات
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final String role = userData['role'] ?? 'customer';

              // 🔥 منطق التوجيه حسب الدور (Role Based Routing)

              // أ) المشرف العام (Admin)
              if (role == 'admin') {
                return const AdminPanel();
              }

              // ب) المطعم (Vendor)
              else if (role == 'vendor') {
                // ✅ هنا نمرر الـ uid ليتم فتح لوحة التحكم الخاصة بمطعمه فقط
                return VendorDashboardScreen(restaurantId: user.uid);
              }

              // ج) السائق (Driver)
              else if (role == 'driver') {
                return const DriverHomeScreen();
              }

              // د) الزبون (Customer) - الحالة الافتراضية
              else {
                return const HomeScreen();
              }
            }

            // في حال وجود خطأ في البيانات (مثلاً المستخدم محذوف من Firestore لكنه موجود في Auth)
            // نقوم بتسجيل الخروج لتجنب المشاكل وإعادته لشاشة الدخول
            if (userSnapshot.connectionState == ConnectionState.done) {
              FirebaseAuth.instance.signOut();
            }
            return const LoginScreen();
          },
        );
      },
    );
  }
}
