import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ استيراد الخدمات والموديلات الموحدة
import 'package:sudafood/core/services/restaurant_service.dart';
import 'package:sudafood/models/restaurant_model.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/features/customer/restaurant/screens/restaurant_details_screen.dart';

// ✅ استيراد الشاشات الفرعية الحقيقية
import 'package:sudafood/features/customer/search/screens/search_screen.dart'; // شاشة البحث الحقيقية
import 'package:sudafood/features/customer/orders/screens/order_history_screen.dart';
import 'package:sudafood/features/customer/profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ✅ القوائم الرئيسية (تم استبدال SearchTab بـ SearchScreen الحقيقية)
  final List<Widget> _pages = [
    const HomeTab(),
    const SearchScreen(), // 👈 الربط هنا
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.search), label: "بحث"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.shoppingBag), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: "حسابي"),
        ],
      ),
    );
  }
}

// ==========================================
// محتوى التبويب الرئيسي المرتبط بـ Firebase
// ==========================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCountry = "Sudan";

  @override
  void initState() {
    super.initState();
    _loadUserConfig();
  }

  // تحميل الدولة المختارة يدوياً من الإعدادات
  Future<void> _loadUserConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCountry = prefs.getString('selected_country') ?? "Sudan";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUserConfig,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoriesSection(),
                  _buildRestaurantsSection(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("توصيل إلى",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Row(
                    children: [
                      Text(
                        _selectedCountry == "Sudan"
                            ? "الخرطوم، السودان 🇸🇩"
                            : "كيجالي، رواندا 🇷🇼",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Icon(LucideIcons.chevronDown, size: 16),
                    ],
                  ),
                ],
              ),
              const Icon(LucideIcons.bell, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ الضغط على حقل البحث ينقل للتبويب الثاني (SearchScreen)
          GestureDetector(
            onTap: () {
              // يمكننا استخدام Controller للتحكم في الـ BottomNav من هنا إذا أردنا
              // أو تركه كما هو كحقل وهمي ينقلنا لصفحة البحث
            },
            child: const AppInput(
              hint: "ابحث عن مطعم في سودافود...",
              prefixIcon: LucideIcons.search,
              // enabled: false, // لنجعله غير قابل للكتابة هنا (اختياري)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = ['الكل', 'بيتزا', 'مشويات', 'سوداني', 'برجر'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("التصنيفات",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: index == 0 ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(categories[index],
                  style: TextStyle(
                      color: index == 0 ? Colors.white : Colors.black,
                      fontSize: 13,
                      fontFamily: 'Cairo')),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRestaurantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("المطاعم المتاحة حالياً",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<RestaurantModel>>(
          // جلب المطاعم التي أضافها الأدمن يدوياً بناءً على الدولة
          stream: RestaurantService().getRestaurantsByCountry(_selectedCountry),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final restaurants = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: restaurants.length,
              itemBuilder: (context, index) =>
                  _buildRestaurantCard(context, restaurants[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(LucideIcons.store, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text("لا توجد مطاعم متاحة في منطقتك حالياً",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
      BuildContext context, RestaurantModel restaurant) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        // الانتقال لتفاصيل المطعم
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RestaurantDetailsScreen(restaurant: restaurant)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: restaurant.imageUrl.isNotEmpty
                  ? restaurant.imageUrl
                  : 'https://placehold.co/600x400/png?text=No+Image', // حماية من الصور الفارغة
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(restaurant.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Cairo')),
                    _buildRatingTag(restaurant.rating),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(restaurant.deliveryTime,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(width: 16),
                    Icon(LucideIcons.bike, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                        restaurant.isFreeDelivery
                            ? "توصيل مجاني"
                            : "توصيل مأجور",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const Spacer(),
                    Text(restaurant.isOpen ? "مفتوح" : "مغلق",
                        style: TextStyle(
                            color:
                                restaurant.isOpen ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingTag(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(LucideIcons.star, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(rating.toString(),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
