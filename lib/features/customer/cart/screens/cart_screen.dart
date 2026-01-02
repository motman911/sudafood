import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ✅ استيراد الحزم الموحدة والمزودات
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/core/providers/cart_provider.dart';
import 'package:sudafood/models/cart_item_model.dart';
import 'package:sudafood/features/customer/cart/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة الوضع الداكن وجلب بيانات السلة من المزود لحظياً
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartProvider = context.watch<CartProvider>();

    // ✅ تحويل العناصر من Map إلى List<CartItem> لضمان توافق الأنواع
    final List<CartItem> cartItemsList = cartProvider.items.values.toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("سلة المشتريات",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (cartItemsList.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2,
                  color: Colors.redAccent, size: 20),
              onPressed: () => _confirmClearCart(context, cartProvider),
            ),
        ],
      ),
      body: cartItemsList.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // 1. قائمة المنتجات المضافة فعلياً للسلة
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItemsList.length,
                    itemBuilder: (context, index) {
                      final item = cartItemsList[index];
                      return _buildCartItem(
                          context, item, cartProvider, isDark);
                    },
                  ),
                ),

                // 2. ملخص الفاتورة وزر إتمام الطلب النهائي
                _buildCartSummary(context, cartProvider, isDark, cartItemsList),
              ],
            ),
    );
  }

  // واجهة السلة الفارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shoppingCart, size: 100, color: Colors.grey[300]),
          UIHelpers.verticalSpaceMedium,
          const Text("سلتك فارغة حالياً",
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  // بناء عنصر واحد داخل السلة
  Widget _buildCartItem(
      BuildContext context, CartItem item, CartProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.product.imageUrl, // استخدام imageUrl من المنتج
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[100]),
                errorWidget: (context, url, error) =>
                    const Icon(LucideIcons.imageOff),
              ),
            ),
            UIHelpers.horizontalSpaceMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Cairo')),
                  Text("${item.product.price} ج.س",
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Row(
              children: [
                _buildQtyBtn(LucideIcons.minus,
                    () => provider.removeSingleItem(item.product.id)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("${item.quantity}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _buildQtyBtn(LucideIcons.plus, () {
                  // ✅ استدعاء addItem بالتوقيع الصحيح
                  provider.addItem(
                    restaurantId: provider.restaurantId!,
                    restaurantName: provider.restaurantName!,
                    itemId: item.product.id,
                    name: item.product.title,
                    price: item.product.price,
                    image: item.product.imageUrl,
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ملخص السلة وزر الانتقال للدفع
  Widget _buildCartSummary(BuildContext context, CartProvider provider,
      bool isDark, List<CartItem> itemsList) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow("إجمالي الطلبات",
                "${provider.totalAmount.toStringAsFixed(2)} ج.س"),
            UIHelpers.verticalSpaceSmall,
            _buildSummaryRow("رسوم التوصيل", "تحدد عند الدفع"),
            const Divider(height: 32),
            _buildSummaryRow("الإجمالي النهائي",
                "${provider.totalAmount.toStringAsFixed(2)} ج.س",
                isBold: true),
            UIHelpers.verticalSpaceMedium,
            AppButton(
              text: "إتمام الطلب (Checkout)",
              onPressed: () {
                // ✅ إرسال القائمة المجهزة مباشرة لتجنب خطأ التوقعات
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      cartItems: itemsList,
                      totalAmount: provider.totalAmount,
                      restaurantId: provider.restaurantId!,
                      restaurantName: provider.restaurantName!,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: isBold ? AppColors.primary : null,
                fontSize: isBold ? 18 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14),
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("مسح السلة؟", style: TextStyle(fontFamily: 'Cairo')),
        content: const Text("هل أنت متأكد من رغبتك في تفريغ سلة المشتريات؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              provider.clearCart();
              Navigator.pop(context);
            },
            child: const Text("مسح الكل", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
