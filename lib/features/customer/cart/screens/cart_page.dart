import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

// ✅ استيراد الشاشات والمزودات والسمات
import 'package:sudafood/features/customer/cart/screens/checkout_screen.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/providers/cart_provider.dart';
import 'package:sudafood/models/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ الاستماع للمزود (watch) لضمان تحديث الشاشة لحظياً عند تغيير الكميات
    final cartProvider = context.watch<CartProvider>();
    // تحويل عناصر السلة (Map) إلى قائمة (List) لسهولة العرض في ListView
    final List<CartItem> cartItems = cartProvider.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("سلة المشتريات",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item, cartProvider);
                    },
                  ),
                ),
                // ✅ ملخص الدفع المرتبط بالبيانات الحقيقية
                _buildPaymentSummary(context, cartProvider),
              ],
            ),
    );
  }

  // واجهة السلة عندما تكون فارغة
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shoppingCart, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("السلة فارغة حالياً",
              style: TextStyle(
                  color: Colors.grey, fontSize: 18, fontFamily: 'Cairo')),
          const Text("ابدأ بإضافة وجباتك المفضلة",
              style: TextStyle(
                  color: Colors.grey, fontSize: 14, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  // بناء عنصر الطعام داخل السلة
  Widget _buildCartItem(CartItem item, CartProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // عرض الصورة مع دعم التخزين المؤقت للأداء (Cache)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl, // استخدام imageUrl من المنتج
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[100]),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // تفاصيل المنتج (الاسم والسعر)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title, // استخدام title من المنتج
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Cairo')),
                const SizedBox(height: 4),
                Text("${item.product.price} ج.س", // استخدام price من المنتج
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // التحكم في الكمية (زيادة ونقصان)
          Row(
            children: [
              _qtyButton(LucideIcons.minus, () {
                // ✅ استخدام removeSingleItem لإنقاص الكمية وليس الحذف الكامل
                provider.removeSingleItem(item.product.id);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text("${item.quantity}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _qtyButton(LucideIcons.plus, () {
                // ✅ استخدام addItem لزيادة الكمية
                provider.addItem(
                  restaurantId: provider.restaurantId!,
                  restaurantName: provider.restaurantName!,
                  itemId: item.product.id,
                  name: item.product.title,
                  price: item.product.price,
                  image: item.product.imageUrl,
                );
              }, isPlus: true),
            ],
          ),
        ],
      ),
    );
  }

  // ملخص المبلغ وزر الانتقال للدفع
  Widget _buildPaymentSummary(BuildContext context, CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("الإجمالي",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Cairo')),
                Text("${provider.totalAmount.toStringAsFixed(2)} ج.س",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            // ✅ تمرير البيانات المحدثة لشاشة الدفع
            AppButton(
              text: "الانتقال للدفع",
              height: 50,
              onPressed: () {
                if (provider.items.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        // ✅ تمرير القيم المطلوبة
                        cartItems: provider.items.values.toList(),
                        totalAmount: provider.totalAmount,
                        restaurantId: provider.restaurantId!,
                        restaurantName: provider.restaurantName!,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, {bool isPlus = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isPlus ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Icon(icon, size: 16, color: isPlus ? Colors.white : Colors.black),
      ),
    );
  }
}
