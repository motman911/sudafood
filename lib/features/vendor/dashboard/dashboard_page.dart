// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../models/order_model.dart';

class VendorDashboardPage extends StatefulWidget {
  final String restaurantId;

  const VendorDashboardPage({super.key, required this.restaurantId});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  bool _isOpen = true;
  String _currency = 'ج.س';
  String _country = 'Sudan';

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selected_country') ?? 'Sudan';

    final doc = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .get();

    if (mounted) {
      setState(() {
        _country = country;
        _currency = (country == 'Sudan') ? 'ج.س' : 'RWF';
        _isOpen = doc.data()?['isOpen'] ?? true;
      });
    }
  }

  Future<void> _toggleStoreStatus(bool val) async {
    setState(() => _isOpen = val);
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .update({'isOpen': val});

    if (mounted) {
      UIHelpers.showSnackBar(
          context,
          val
              ? "المطعم متاح الآن لاستقبال الطلبات ✅"
              : "تم إغلاق المطعم مؤقتاً 🛑");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم سودافود",
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. حالة المتجر
            _buildStoreStatusCard(),

            const SizedBox(height: 24),

            // 2. إحصائيات المبيعات
            const Text("نظرة عامة اليوم",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard("المبيعات", "1,250 $_currency",
                        LucideIcons.banknote, Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard("الطلبات", "24",
                        LucideIcons.shoppingBag, AppColors.primary)),
              ],
            ),

            const SizedBox(height: 24),

            // 3. الطلبات الجديدة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("طلبات جديدة 🔥",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo')),
                TextButton(
                    onPressed: () {},
                    child: const Text("عرض الكل",
                        style: TextStyle(fontFamily: 'Cairo'))),
              ],
            ),

            _buildOrdersStream(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreStatusCard() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isOpen
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.store,
                    color: _isOpen ? Colors.green : Colors.red),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isOpen ? "المطعم مفتوح" : "المطعم مغلق",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  Text(
                      _isOpen
                          ? "تستقبل طلبات من $_country"
                          : "المتجر متوقف حالياً",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Cairo')),
                ],
              ),
            ],
          ),
          Switch(
            value: _isOpen,
            activeColor: Colors.green,
            onChanged: _toggleStoreStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('restaurantId', isEqualTo: widget.restaurantId)
          .where('status', isEqualTo: 'pending')
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text("لا توجد طلبات جديدة حالياً",
                      style:
                          TextStyle(fontFamily: 'Cairo', color: Colors.grey))));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildOrderItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildOrderItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                        backgroundColor: Color(0xFFF3F4F6),
                        child: Icon(LucideIcons.user,
                            color: Colors.grey, size: 20)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("طلب #${doc.id.substring(0, 5)}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text("الإجمالي: ${data['totalAmount']} $_currency",
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                _statusBadge("جديد"),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(data['deliveryAddress'] ?? "العنوان غير محدد",
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: 'Cairo'))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: AppButton(
                        text: "قبول",
                        onPressed: () => _updateStatus(doc.id, 'preparing'),
                        height: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(doc.id, 'cancelled'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(double.infinity, 40)),
                    child: const Text("رفض",
                        style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              fontFamily: 'Cairo')),
    );
  }

  Future<void> _updateStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(id)
        .update({'status': status, 'lastUpdate': FieldValue.serverTimestamp()});
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              const Icon(LucideIcons.trendingUp, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 11, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}
