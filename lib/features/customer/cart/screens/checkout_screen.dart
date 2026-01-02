import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // ✅ ضروري لتفريغ السلة

// ✅ استيراد المكونات والخدمات
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/core/services/order_service.dart';
import 'package:sudafood/core/providers/cart_provider.dart'; // ✅ استدعاء البروفايدر
import 'package:sudafood/models/order_model.dart';
import 'package:sudafood/models/cart_item_model.dart';
import 'package:sudafood/features/customer/orders/screens/order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final String restaurantId;
  final String restaurantName;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;
  String _currentCountry = "Sudan";
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentCountry = prefs.getString('selected_country') ?? "Sudan";
    });
  }

  // ✅ دالة إرسال الطلب (المحدثة لتوافق نظام تثبيت السعر)
  void _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      UIHelpers.showSnackBar(context, "يرجى تسجيل الدخول أولاً", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    // 1. إنشاء كائن الطلب وتضمين الوجبات بداخله (Snapshot)
    final order = OrderModel(
      id: const Uuid().v4(),
      customerId: user.uid,
      restaurantId: widget.restaurantId,
      restaurantName: widget.restaurantName,
      totalAmount: widget.totalAmount, // السعر النهائي المثبت
      status: 'pending',
      date: DateTime.now(),
      country: _currentCountry,
      items: widget.cartItems, // ✅ حفظ الوجبات بأسعارها الحالية داخل الطلب
    );

    try {
      // 2. إرسال الطلب للسيرفس (التي ستحفظه ككتلة واحدة)
      await OrderService().placeOrder(order);

      // 3. تفريغ السلة بعد النجاح
      if (mounted) {
        Provider.of<CartProvider>(context, listen: false).clearCart();

        UIHelpers.showSnackBar(context, "تم إرسال طلبك بنجاح ✅");

        // 4. الانتقال لصفحة التتبع
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderTrackingScreen()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showSnackBar(context, "فشل إرسال الطلب: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = _currentCountry == "Sudan" ? "ج.س" : "RWF";

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("إتمام الطلب",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("عنوان التوصيل"),
            UIHelpers.verticalSpaceSmall,
            _buildAddressCard(),
            UIHelpers.verticalSpaceMedium,
            _buildSectionTitle("طريقة الدفع"),
            UIHelpers.verticalSpaceSmall,
            _buildPaymentOption(
                0, "الدفع نقداً عند الاستلام", LucideIcons.banknote),
            _buildPaymentOption(
                1,
                _currentCountry == "Sudan" ? "تطبيق بنكك (BOK)" : "MTN Momo",
                LucideIcons.wallet),
            UIHelpers.verticalSpaceMedium,
            _buildSectionTitle("ملاحظات إضافية"),
            UIHelpers.verticalSpaceSmall,
            AppInput(
              label: "ملاحظات للمطعم",
              hint: "مثلاً: بدون شطة، زيادة كاتشب...",
              controller: _noteController,
            ),
            UIHelpers.verticalSpaceLarge,
            _buildFinalSummary(currency),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Cairo'));
  }

  Widget _buildAddressCard() {
    return AppCard(
      child: ListTile(
        leading: const Icon(LucideIcons.mapPin, color: AppColors.primary),
        title: const Text("الموقع الحالي",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        subtitle: Text(
            _currentCountry == "Sudan" ? "الخرطوم، السودان" : "كيجالي، رواندا"),
        trailing: TextButton(onPressed: () {}, child: const Text("تغيير")),
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              // ignore: deprecated_member_use
              isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            UIHelpers.horizontalSpaceMedium,
            Text(title,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalSummary(String currency) {
    return AppCard(
      // ignore: deprecated_member_use
      backgroundColor: AppColors.primary.withOpacity(0.05),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("إجمالي القيمة",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Cairo')),
              Text("${widget.totalAmount.toStringAsFixed(2)} $currency",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.primary)),
            ],
          ),
          UIHelpers.verticalSpaceMedium,
          AppButton(
            text: "تأكيد الطلب الآن",
            isLoading: _isProcessing,
            onPressed: _placeOrder,
          ),
        ],
      ),
    );
  }
}
