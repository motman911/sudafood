import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

// ✅ استيراد الموديلات والخدمات والـ Provider
import 'package:sudafood/models/restaurant_model.dart';
import 'package:sudafood/models/menu_item_model.dart';
import 'package:sudafood/core/services/menu_service.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/core/providers/cart_provider.dart';
// ✅ التأكد من استيراد شاشة السلة بالاسم الصحيح
import 'package:sudafood/features/customer/cart/screens/cart_screen.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    // مراقبة السلة لتحديث عدد العناصر في الزر السفلي
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo')),
                  const SizedBox(height: 8),
                  Text("${restaurant.category} • ${restaurant.city}",
                      style: TextStyle(
                          color: Colors.grey[600], fontFamily: 'Cairo')),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBadge(LucideIcons.star, "${restaurant.rating}"),
                      _buildInfoBadge(
                          LucideIcons.clock, restaurant.deliveryTime),
                      _buildInfoBadge(LucideIcons.truck,
                          restaurant.isFreeDelivery ? "مجاني" : "مدفوع"),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text("قائمة الطعام",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo')),
                ],
              ),
            ),
          ),
          _buildMenuStream(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),

      // ✅ زر السلة الديناميكي: يظهر فقط إذا كانت السلة تحتوي على عناصر
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cartProvider.items.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppButton(
                text:
                    "عرض السلة (${cartProvider.items.length}) - ${cartProvider.totalAmount} ج.س",
                height: 50,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartScreen()));
                },
              ),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.black)),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: restaurant.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[300]),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildMenuStream() {
    return StreamBuilder<List<MenuItem>>(
      stream: MenuService().getRestaurantMenu(restaurant.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
                child: Text("لا توجد وجبات متاحة حالياً",
                    style: TextStyle(fontFamily: 'Cairo'))),
          );
        }

        final items = snapshot.data!;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildMenuItem(context, items[index]),
            childCount: items.length,
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Cairo')),
                  const SizedBox(height: 4),
                  Text(item.description,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      maxLines: 2),
                  const SizedBox(height: 8),
                  Text("${item.price} ج.س",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
            ),
            if (item.isAvailable)
              IconButton(
                icon: const Icon(Icons.add_circle,
                    color: AppColors.primary, size: 30),
                onPressed: () {
                  // ✅ تم التصحيح: استخدام addItem بدلاً من addToCart للتوافق مع CartProvider المحدث
                  Provider.of<CartProvider>(context, listen: false).addItem(
                    restaurantId: restaurant.id,
                    restaurantName: restaurant.name,
                    itemId: item.id,
                    name: item.title,
                    price: item.price,
                    image: item.imageUrl,
                  );

                  UIHelpers.showSnackBar(
                      context, "تمت إضافة ${item.title} للسلة");
                },
              )
            else
              const Text("نفد",
                  style: TextStyle(
                      color: Colors.red, fontSize: 12, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 6),
          Text(text,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
