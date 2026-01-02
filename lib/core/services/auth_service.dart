import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ استخدام الاستيراد الموحد للثوابت
import 'package:sudafood/core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. تسجيل الدخول باستخدام رقم الهاتف (نظام OTP) - (مرحلة مستقبلية)
  Future<bool> login(String fullPhoneNumber) async {
    try {
      // هنا منطق Firebase Phone Auth
      // ignore: avoid_print
      print("تم إرسال الرمز إلى: $fullPhoneNumber");
      return true;
    } catch (e) {
      return false;
    }
  }

  // 2. تسجيل الدخول بالبريد الإلكتروني
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // تحديث الحالة محلياً
      await _saveLoginStatus(true);
      await _saveToken(userCredential.user?.uid ?? "");

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  // 3. إنشاء حساب جديد (مع منطق إنشاء المطعم تلقائياً)
  Future<UserCredential?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String country,
    String role = 'customer',
  }) async {
    try {
      // أ) إنشاء المستخدم في المصادقة
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // ب) حفظ بيانات المستخدم في Firestore
      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'country': country,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ج) ⚠️ خطوة مهمة جداً: إذا كان "مطعم"، ننشئ له ملفاً في كوليكشن المطاعم
      // بدون هذه الخطوة، ستفشل شاشة VendorDashboardScreen
      if (role == 'vendor') {
        await _firestore.collection('restaurants').doc(uid).set({
          'id': uid,
          'name': name, // اسم المطعم الافتراضي
          'imageUrl': '',
          'rating': 5.0,
          'deliveryTime': '30-45 دقيقة',
          'isFreeDelivery': false,
          'country': country,
          'city': 'الخرطوم', // يمكن تعديلها لاحقاً من الإعدادات
          'category': 'عام',
          'isOpen': true,
          'totalSales': 0,
          'orderCount': 0,
          'menuCount': 0,
        });
      }

      // د) حفظ البيانات محلياً
      await _saveLoginStatus(true);
      await _saveCountryPreference(country);
      await _saveToken(uid);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  // 4. التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool loginStatus = prefs.getBool(AppConstants.isLoggedInKey) ?? false;
    // التأكد من أن المستخدم موجود فعلاً في Firebase وليس فقط في الذاكرة المحلية
    return loginStatus && _auth.currentUser != null;
  }

  // 5. تسجيل الخروج
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  // 6. دالة لجلب بيانات المستخدم الحالي (مطلوبة لـ AuthWrapper)
  Future<DocumentSnapshot> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore.collection('users').doc(user.uid).get();
    }
    throw Exception("لا يوجد مستخدم مسجل");
  }

  // --- دالات مساعدة (Private) ---

  Future<void> _saveLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, status);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> _saveCountryPreference(String country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.countryKey, country);
  }

  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return "المستخدم غير موجود.";
      case 'wrong-password':
        return "كلمة المرور غير صحيحة.";
      case 'email-already-in-use':
        return "البريد الإلكتروني مستخدم بالفعل.";
      case 'weak-password':
        return "كلمة المرور ضعيفة جداً.";
      default:
        return "حدث خطأ: $code";
    }
  }
}
