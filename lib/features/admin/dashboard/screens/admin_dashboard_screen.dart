import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

// استيراد المكونات المخصصة
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/features/admin/restaurants/screens/add_restaurant_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedMenuIndex = 0;
  String _activeCountryFilter = 'All';
  // ignore: unused_field
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(), // القائمة الجانبية المحدثة
          Expanded(
            child: Container(
              color: isDark ? AppColors.backgroundDark : Colors.grey[50],
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: _buildBodyContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- محتوى التبديل الديناميكي ---
  Widget _buildBodyContent() {
    switch (_selectedMenuIndex) {
      case 0:
        return _buildUsersList();
      case 1:
        return _buildRestaurantsManagement();
      case 2:
        return _buildAnalyticsDashboard();
      case 3:
        return _buildNotificationPanel(); // ميزة الإشعارات الجديدة
      default:
        return const SizedBox();
    }
  }

  // --- 1. لوحة الإحصائيات الذكية ---
  Widget _buildAnalyticsDashboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data?.docs ?? [];
        double totalSales = 0;
        int activeOrders = 0;

        for (var doc in orders) {
          final data = doc.data() as Map<String, dynamic>;
          if (_activeCountryFilter == 'All' ||
              data['country'] == _activeCountryFilter) {
            totalSales += (data['totalAmount'] ?? 0);
            if (data['status'] != 'completed' &&
                data['status'] != 'cancelled') {
              activeOrders++;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        "إجمالي المبيعات",
                        "${totalSales.toStringAsFixed(2)} \$",
                        LucideIcons.dollarSign,
                        Colors.green)),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildStatCard("الطلبات النشطة", "$activeOrders",
                        LucideIcons.package, Colors.blue)),
                const SizedBox(width: 20),
                _buildRestaurantCountCard(),
              ],
            ),
            const SizedBox(height: 32),
            _buildRegionDistributionChart(),
          ],
        );
      },
    );
  }

  // --- 2. واجهة إرسال الإشعارات العامة (ميزة جديدة) ---
  Widget _buildNotificationPanel() {
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController bodyCtrl = TextEditingController();
    // ignore: unused_local_variable
    String targetRegion = 'All';

    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("إرسال إشعار عام (Push Notification)",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo')),
          UIHelpers.verticalSpaceMedium,
          _buildRegionSelector(), // إعادة استخدام فلتر الدولة للاستهداف
          UIHelpers.verticalSpaceMedium,
          AppInput(
              label: "عنوان الإشعار",
              hint: "مثلاً: عروض نهاية الأسبوع",
              controller: titleCtrl),
          UIHelpers.verticalSpaceSmall,
          AppInput(
              label: "نص الرسالة",
              hint: "اكتب تفاصيل الإشعار هنا...",
              controller: bodyCtrl,
              maxLines: 3),
          UIHelpers.verticalSpaceLarge,
          AppButton(
            text: "إرسال الإشعار الآن",
            icon: const Icon(LucideIcons.send, size: 18),
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && bodyCtrl.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('notifications')
                    .add({
                  'title': titleCtrl.text.trim(),
                  'body': bodyCtrl.text.trim(),
                  'region': _activeCountryFilter,
                  'sentAt': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  UIHelpers.showSnackBar(context, "تم إرسال الإشعار بنجاح ✅");
                }
                titleCtrl.clear();
                bodyCtrl.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  // --- المكونات المساعدة للواجهة ---
  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: const Color(0xFF0D0D0D),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Icon(LucideIcons.shieldAlert,
              color: AppColors.primary, size: 50),
          const SizedBox(height: 15),
          const Text("SudaFood Admin Portal",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          _buildSidebarItem(0, LucideIcons.users, "إدارة المستخدمين"),
          _buildSidebarItem(1, LucideIcons.store, "إدارة المطاعم"),
          _buildSidebarItem(2, LucideIcons.barChart4, "الإحصائيات العامة"),
          _buildSidebarItem(
              3, LucideIcons.bellRing, "إرسال إشعارات"), // تبويب الإشعارات
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    bool isSelected = _selectedMenuIndex == index;
    return ListTile(
      selected: isSelected,
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontFamily: 'Cairo')),
      onTap: () => setState(() => _selectedMenuIndex = index),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          const Text("لوحة التحكم المركزية",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo')),
          const Spacer(),
          _buildRegionSelector(),
          const SizedBox(width: 20),
          AppButton(
              text: "إضافة مستخدم",
              isFullWidth: false,
              onPressed: _showAddUserDialog,
              height: 40),
        ],
      ),
    );
  }

  Widget _buildRegionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!)),
      child: DropdownButton<String>(
        value: _activeCountryFilter,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'All', child: Text("كل الدول")),
          DropdownMenuItem(value: 'Sudan', child: Text("السودان 🇸🇩")),
          DropdownMenuItem(value: 'Rwanda', child: Text("رواندا 🇷🇼")),
        ],
        onChanged: (val) => setState(() => _activeCountryFilter = val!),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 14, fontFamily: 'Cairo')),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRestaurantCountCard() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshot) {
          int count = snapshot.data?.docs.length ?? 0;
          return _buildStatCard(
              "المطاعم المسجلة", "$count", LucideIcons.store, Colors.orange);
        },
      ),
    );
  }

  Widget _buildRegionDistributionChart() {
    return AppCard(
      child: Column(
        children: [
          const Text("توزيع العمليات الإقليمي",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo')),
          const SizedBox(height: 40),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                      value: 60,
                      color: Colors.green,
                      title: "السودان",
                      radius: 60,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(
                      value: 40,
                      color: Colors.blue,
                      title: "رواندا",
                      radius: 60,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        final users = snapshot.data?.docs ?? [];
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final data = users[index].data() as Map<String, dynamic>;
            return AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(LucideIcons.user)),
                title: Text(data['email'] ?? 'No Email'),
                subtitle: Text(
                    "الدور: ${data['role']} - الإقليم: ${data['country']}"),
                trailing: const Icon(LucideIcons.edit3),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRestaurantsManagement() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            text: "إضافة مطعم جديد",
            isFullWidth: false,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddRestaurantScreen())),
            height: 45,
          ),
        ),
        const SizedBox(height: 20),
        const Text("قائمة المطاعم النشطة تظهر هنا"),
      ],
    );
  }

  void _showAddUserDialog() {
    // منطق إضافة المستخدم موجود مسبقاً في كودك الأصلي
  }
}
