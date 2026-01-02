import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart'; // لفتح خرائط جوجل والاتصال

import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final String orderId; // معرف الطلب لجلب البيانات الحقيقية

  const ActiveDeliveryScreen({super.key, required this.orderId});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  // دالة لتحديث حالة الطلب في Firestore وربطها مع نظام التتبع
  Future<void> _updateStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .update({
      'status': status,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  // فتح خرائط جوجل للتوجه للموقع
  Future<void> _openMap(String address) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final String status = orderData['status'] ?? 'preparing';

          return Column(
            children: [
              // 1. الجزء العلوي: الخريطة التفاعلية (أو محاكاة لها)
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(LucideIcons.map,
                            size: 100, color: Colors.grey),
                      ),
                    ),
                    // زر العودة
                    Positioned(
                      top: 50,
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. لوحة التحكم السفلية (Bottom Sheet UI)
              _buildControlPanel(orderData, status),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlPanel(Map<String, dynamic> data, String status) {
    // تحديد الوجهة الحالية بناءً على حالة الطلب
    bool isGoingToStore = status == 'preparing' || status == 'ready';
    String destinationName =
        isGoingToStore ? data['restaurantName'] : "منزل العميل";
    String destinationAddress =
        isGoingToStore ? "موقع المطعم" : data['deliveryAddress'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مؤشر المرحلة (Progress Stepper)
          _buildDeliveryStepper(status),
          const SizedBox(height: 20),

          // معلومات الوجهة
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    isGoingToStore ? LucideIcons.store : LucideIcons.home,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destinationName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo')),
                    Text(destinationAddress,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              // زر التنقل عبر الخرائط
              IconButton(
                icon: const Icon(LucideIcons.navigation, color: Colors.blue),
                onPressed: () => _openMap(destinationAddress),
              ),
            ],
          ),

          const Divider(height: 40),

          // زر الإجراء الرئيسي بناءً على الحالة
          _buildActionButton(status),
        ],
      ),
    );
  }

  Widget _buildDeliveryStepper(String status) {
    // رسم توضيحي لمراحل التوصيل
    return Row(
      children: [
        _stepperNode(true, "المطعم"),
        _stepperLine(status == 'delivering' || status == 'completed'),
        _stepperNode(
            status == 'delivering' || status == 'completed', "الاستلام"),
        _stepperLine(status == 'completed'),
        _stepperNode(status == 'completed', "العميل"),
      ],
    );
  }

  Widget _buildActionButton(String status) {
    String text = "";
    VoidCallback? action;

    if (status == 'preparing' || status == 'ready') {
      text = "وصلت للمطعم";
      action = () => _updateStatus('at_store');
    } else if (status == 'at_store') {
      text = "تم استلام الطلب";
      action = () => _updateStatus('delivering');
    } else if (status == 'delivering') {
      text = "تم التسليم للعميل";
      action = () async {
        await _updateStatus('completed');
        if (mounted) Navigator.pop(context);
      };
    }

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: action,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo')),
      ),
    );
  }

  // ويدجت مساعدة لرسم الخطوات (Stepper)
  Widget _stepperNode(bool active, String label) {
    return Column(
      children: [
        Icon(active ? Icons.check_circle : Icons.radio_button_unchecked,
            color: active ? AppColors.primary : Colors.grey, size: 20),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: active ? Colors.black : Colors.grey,
                fontFamily: 'Cairo')),
      ],
    );
  }

  Widget _stepperLine(bool active) {
    return Expanded(
        child: Container(
            height: 2, color: active ? AppColors.primary : Colors.grey[300]));
  }
}
