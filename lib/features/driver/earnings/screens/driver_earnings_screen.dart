import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  String _currency = 'ج.س';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selected_country') ?? 'Sudan';
    setState(() {
      _currency = (country == 'Sudan') ? 'ج.س' : 'RWF';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المحفظة والأرباح",
            style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. بطاقة المحفظة الرئيسية
            _buildWalletCard(),

            const SizedBox(height: 24),

            // 2. إحصائيات سريعة
            const Text("ملخص الأداء",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo')),
            const SizedBox(height: 12),
            _buildQuickStats(),

            const SizedBox(height: 24),

            // 3. سجل العمليات
            const Text("سجل العمليات الأخير",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo')),
            const SizedBox(height: 12),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.wallet, color: Colors.white54, size: 30),
          const SizedBox(height: 12),
          const Text("الرصيد القابل للسحب",
              style: TextStyle(color: Colors.white70, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          Text("4,500 $_currency",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text("طلب سحب الرصيد",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
            child: _statItem(
                "طلبات اليوم", "12", LucideIcons.shoppingBag, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(
            child:
                _statItem("المسافة", "45 كم", LucideIcons.mapPin, Colors.blue)),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(LucideIcons.arrowDownLeft,
                  color: Colors.green, size: 20),
            ),
            title: const Text("أرباح طلب #1023",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            subtitle:
                const Text("24 يناير، 02:30 م", style: TextStyle(fontSize: 12)),
            trailing: Text("+150 $_currency",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16)),
          ),
        );
      },
    );
  }
}
