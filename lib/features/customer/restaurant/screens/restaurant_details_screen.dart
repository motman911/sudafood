import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// استيراد المكونات والموديلات الأساسية
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/models/restaurant_model.dart';
import 'package:sudafood/core/providers/cart_provider.dart';
// ✅ استيراد شاشة السلة لتفعيل الزر السفلي
import 'package:sudafood/features/customer/cart/screens/cart_screen.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. الجزء العلوي: صورة المطعم
          _buildSliverAppBar(context),

          // 2. معلومات المطعم
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRestaurantInfo(),
            ),
          ),

          // 3. عرض المنيو
          _buildMenuSections(),
        ],
      ),
      // شريط السلة السفلي
      bottomNavigationBar: _buildBottomCartBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(restaurant.name,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: restaurant.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.grey),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(restaurant.category,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                Text(" ${restaurant.rating} (50+)",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        UIHelpers.verticalSpaceSmall,
        Row(
          children: [
            const Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text("${restaurant.city}, ${restaurant.country}",
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
        UIHelpers.verticalSpaceSmall,
        Row(
          children: [
            const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text("وقت التوصيل المتوقع: ${restaurant.deliveryTime}",
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildMenuSections() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurant.id)
          .collection('menu')
          .where('isAvailable', isEqualTo: true) // ✅ عرض الوجبات المتاحة فقط
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                  child: Text("لا توجد وجبات متاحة حالياً",
                      style: TextStyle(fontFamily: 'Cairo'))),
            ),
          );
        }

        final menuItems = snapshot.data!.docs;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = menuItems[index].data() as Map<String, dynamic>;
              return _buildMenuItem(context, item, menuItems[index].id);
            },
            childCount: menuItems.length,
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
      BuildContext context, Map<String, dynamic> item, String itemId) {
    final currency = restaurant.country == 'Sudan' ? 'ج.س' : 'RWF';

    // ✅ معالجة البيانات لتجنب الأخطاء (Null Safety)
    final String name = item['title'] ?? item['name'] ?? "وجبة";
    final String desc = item['description'] ?? "";
    final String imageUrl = item['imageUrl'] ?? item['image'] ?? "";
    // ✅ تحويل السعر بأمان سواء كان int أو double أو String
    final double price = double.tryParse(item['price'].toString()) ?? 0.0;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2),
                UIHelpers.verticalSpaceSmall,
                Text("$price $currency",
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(
                      Icons.fastfood,
                      color: Colors.grey), // أيقونة بديلة في حال الخطأ
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // ✅ إضافة الوجبة للسلة باستخدام البيانات المعالجة
                  context.read<CartProvider>().addItem(
                        restaurantId: restaurant.id,
                        restaurantName: restaurant.name,
                        itemId: itemId,
                        name: name,
                        price: price,
                        image: imageUrl,
                      );

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("تمت إضافة $name للسلة"),
                    duration: const Duration(milliseconds: 800),
                    backgroundColor: AppColors.primary,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(80, 30),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child:
                    const Icon(LucideIcons.plus, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomCartBar(BuildContext context) {
    // ✅ استخدام watch لتحديث الشريط عند إضافة وجبة
    final cart = context.watch<CartProvider>();
    final currency = restaurant.country == 'Sudan' ? 'ج.س' : 'RWF';

    if (cart.items.isEmpty) return null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppCard(
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          onTap: () {
            // ✅ الانتقال لشاشة السلة
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${cart.itemCount} أصناف | ${cart.totalAmount.toStringAsFixed(2)} $currency",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const Row(
                children: [
                  Text("عرض السلة",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(LucideIcons.shoppingBag, color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
