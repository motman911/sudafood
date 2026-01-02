import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  String _currency = 'ج.س';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  // تحميل العملة بناءً على الدولة المختارة لضمان دقة البيانات المالية
  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selected_country') ?? 'Sudan';
    setState(() {
      _currency = (country == 'Sudan') ? 'ج.س' : 'RWF';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("المحفظة والأرباح",
            style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. بطاقة الرصيد الكلي بتصميم متدرج (Gradient) لتعزيز الثقة المالية
            Container(
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
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text("الرصيد القابل للسحب",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Cairo')),
                  const SizedBox(height: 8),
                  Text("450.00 $_currency",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.trendingUp,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text("أرباح اليوم: 150.00 $_currency",
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'Cairo')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. ترويسة سجل العمليات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("سجل العمليات الأخير",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo')),
                TextButton(
                    onPressed: () {},
                    child: const Text("فلترة",
                        style: TextStyle(fontFamily: 'Cairo'))),
              ],
            ),

            const SizedBox(height: 8),

            // 3. قائمة العمليات التفصيلية
            _buildTransactionsList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(LucideIcons.arrowDownLeft,
                  color: Colors.green, size: 20),
            ),
            title: Text("توصيل طلب #${1020 + index}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            subtitle: Text("اليوم، ${02 + index}:30 م • مسافة 5 كم",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Cairo')),
            trailing: Text("+15.00 $_currency",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 15)),
          ),
        );
      },
    );
  }
}
