import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ استيراد المكونات والخدمات الموحدة
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/models/restaurant_model.dart';
import 'package:sudafood/features/customer/restaurant/screens/restaurant_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _userCountry = "Sudan";

  @override
  void initState() {
    super.initState();
    _getUserCountry();
  }

  // ✅ جلب دولة المستخدم لفلترة النتائج إقليمياً
  void _getUserCountry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() => _userCountry = doc.data()?['country'] ?? "Sudan");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("البحث في سودافود",
              style: TextStyle(fontFamily: 'Cairo'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppInput(
              hint: "ابحث عن مطعم (مثلاً: البرنس، كنتاكي...)",
              controller: _searchController,
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) return _buildSearchPlaceholder();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .where('country', isEqualTo: _userCountry)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("حدث خطأ في جلب البيانات"));
        }

        // فلترة المطاعم بناءً على الاسم المكتوب في البحث (Client-side filtering for search)
        final results = snapshot.data!.docs.where((doc) {
          final name = (doc.data() as Map<String, dynamic>)['name']
              .toString()
              .toLowerCase();
          return name.contains(_searchQuery.toLowerCase());
        }).toList();

        // ✅ الحالة: المطعم غير مربوط بالتطبيق
        if (results.isEmpty) {
          return _buildNotFoundState(_searchQuery);
        }

        // ✅ الحالة: المطعم موجود ومربوط
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final data = results[index].data() as Map<String, dynamic>;
            // تحويل البيانات للموديل
            final restaurant = RestaurantModel.fromMap(data, results[index].id);
            return _buildRestaurantTile(restaurant);
          },
        );
      },
    );
  }

  Widget _buildRestaurantTile(RestaurantModel restaurant) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetailsScreen(restaurant: restaurant),
            ));
      },
      child: ListTile(
        leading: CircleAvatar(
          // ignore: deprecated_member_use
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: restaurant.imageUrl.isNotEmpty
              ? NetworkImage(restaurant.imageUrl)
              : null,
          child: restaurant.imageUrl.isEmpty
              ? const Icon(LucideIcons.store, color: AppColors.primary)
              : null,
        ),
        title: Text(restaurant.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        subtitle: Text("${restaurant.category} • ${restaurant.city}"),
        trailing: const Icon(LucideIcons.chevronRight,
            size: 18, color: AppColors.primary),
      ),
    );
  }

  // ✅ واجهة المطعم "غير الموجود"
  Widget _buildNotFoundState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle,
                size: 64, color: Colors.orange),
            UIHelpers.verticalSpaceMedium,
            Text(
              "عذراً، مطعم '$query' غير متوفر حالياً",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
            UIHelpers.verticalSpaceSmall,
            const Text(
              "ربما المطعم غير موجود على تطبيق سودافود حالياً. نحن نعمل على إضافة المزيد من المطاعم يومياً!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.search, size: 80, color: Colors.grey[200]),
          const Text("اكتشف المطاعم المتاحة في دولتك",
              style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}
