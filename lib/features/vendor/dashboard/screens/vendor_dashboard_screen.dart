import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ✅ استيراد المكونات والخدمات الموحدة
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/vendor/menu/screens/menu_management_screen.dart';
import 'package:sudafood/models/menu_item_model.dart';
import 'package:sudafood/core/services/menu_service.dart';

// ✅ استيراد شاشة إضافة وجبة
import 'package:sudafood/features/vendor/menu/screens/add_dish_screen.dart'
    hide MenuService;

class MenuManagementScreen extends StatefulWidget {
  final String restaurantId;

  const MenuManagementScreen({super.key, required this.restaurantId});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final MenuService _menuService = MenuService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة قائمة الطعام",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<MenuItem>>(
        // جلب البيانات من السيرفس لحظياً
        stream: _menuService.getRestaurantMenu(widget.restaurantId),
        builder: (context, snapshot) {
          // 1. حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. حالة الخطأ
          if (snapshot.hasError) {
            return Center(
              child: Text("حدث خطأ: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)),
            );
          }

          // 3. حالة عدم وجود بيانات (المنيو فارغ)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final menuItems = snapshot.data!;

          // 4. عرض القائمة
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              return _buildMenuItemCard(menuItems[index]);
            },
          );
        },
      ),
      // زر العائم لإضافة وجبة جديدة
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () {
          // الانتقال لشاشة إضافة وجبة
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddDishScreen(restaurantId: widget.restaurantId),
            ),
          );
        },
      ),
    );
  }

  // تصميم الحالة الفارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.utensilsCrossed, size: 80, color: Colors.grey[300]),
          UIHelpers.verticalSpaceMedium,
          const Text("المنيو فارغ حالياً",
              style: TextStyle(
                  color: Colors.grey, fontSize: 18, fontFamily: 'Cairo')),
          const Text("ابدأ بإضافة وجباتك المميزة",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  // تصميم كارت الوجبة
  Widget _buildMenuItemCard(MenuItem item) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // صورة الوجبة
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              // ✅ التعديل الهام: حماية من الصور الفارغة لتجنب الـ Error
              imageUrl: item.imageUrl.isNotEmpty
                  ? item.imageUrl
                  : 'https://placehold.co/600x400/png?text=No+Image', // صورة بديلة آمنة
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),

          // تفاصيل الوجبة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${item.price} ج.س",
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
                if (item.category.isNotEmpty)
                  Text(item.category,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // أزرار التحكم
          Column(
            children: [
              // زر التوفر (متاح/غير متاح)
              Switch.adaptive(
                value: item.isAvailable,
                // ignore: deprecated_member_use
                activeColor: AppColors.primary,
                onChanged: (val) {
                  _menuService.toggleProductAvailability(
                      widget.restaurantId, item.id, val);
                },
              ),
              // زر الحذف
              IconButton(
                icon:
                    const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                onPressed: () {
                  _confirmDelete(item);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // نافذة تأكيد الحذف
  void _confirmDelete(MenuItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف الوجبة؟", style: TextStyle(fontFamily: 'Cairo')),
        content: Text("هل أنت متأكد من حذف ${item.title}؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _menuService.deleteDish(
                  widget.restaurantId, item.id, item.imageUrl);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
