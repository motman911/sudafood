import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:sudafood/models/menu_item_model.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_card.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';

class MenuPage extends StatefulWidget {
  final String restaurantId;

  const MenuPage({super.key, required this.restaurantId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _currency = 'ج.س';
  String _country = 'Sudan';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _country = prefs.getString('selected_country') ?? 'Sudan';
      _currency = (_country == 'Sudan') ? 'ج.س' : 'RWF';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة قائمة الطعام",
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: AppColors.primary),
            onPressed: () => _showAddMenuItemDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menu')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final item =
                  MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              return _buildMenuItemCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.imageUrl.isNotEmpty
              ? Image.network(item.imageUrl,
                  width: 55, height: 55, fit: BoxFit.cover)
              : Container(
                  width: 55,
                  height: 55,
                  color: Colors.grey[200],
                  child: const Icon(LucideIcons.image)),
        ),
        title: Text(item.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        subtitle: Text("${item.price} $_currency",
            style: const TextStyle(color: AppColors.primary)),
        trailing: Switch(
          value: item.isAvailable,
          activeThumbColor: AppColors.primary,
          onChanged: (val) => _toggleAvailability(item.id, val),
        ),
      ),
    );
  }

  Future<void> _toggleAvailability(String itemId, bool status) async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('menu')
        .doc(itemId)
        .update({'isAvailable': status});
  }

  // نافذة إضافة الصنف مع منطق الرفع
  void _showAddMenuItemDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    File? selectedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("إضافة صنف جديد",
              style: TextStyle(fontFamily: 'Cairo')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final img = await ImagePicker().pickImage(
                        source: ImageSource.gallery, imageQuality: 70);
                    if (img != null) {
                      setDialogState(() => selectedImage = File(img.path));
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!)),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                Image.file(selectedImage!, fit: BoxFit.cover))
                        : const Icon(LucideIcons.camera,
                            size: 40, color: Colors.grey),
                  ),
                ),
                UIHelpers.verticalSpaceSmall,
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "اسم الوجبة")),
                TextField(
                    controller: priceController,
                    decoration:
                        InputDecoration(labelText: "السعر ($_currency)"),
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (titleController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          // ignore: curly_braces_in_flow_control_structures
                          selectedImage == null) return;

                      setDialogState(() => isUploading = true);
                      try {
                        // 1. الرفع لـ Storage
                        String fileName =
                            'menu/$_country/${const Uuid().v4()}.jpg';
                        TaskSnapshot upload = await FirebaseStorage.instance
                            .ref(fileName)
                            .putFile(selectedImage!);
                        String url = await upload.ref.getDownloadURL();

                        // 2. الحفظ في Firestore
                        await FirebaseFirestore.instance
                            .collection('restaurants')
                            .doc(widget.restaurantId)
                            .collection('menu')
                            .add({
                          'title': titleController.text,
                          'price': double.tryParse(priceController.text) ?? 0.0,
                          'imageUrl': url,
                          'isAvailable': true,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        setDialogState(() => isUploading = false);
                        UIHelpers.showSnackBar(
                            // ignore: use_build_context_synchronously
                            context,
                            "حدث خطأ أثناء الإضافة");
                      }
                    },
              child: isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.utensilsCrossed, size: 80, color: Colors.grey[300]),
          UIHelpers.verticalSpaceSmall,
          const Text("قائمة الطعام فارغة",
              style: TextStyle(
                  color: Colors.grey, fontSize: 16, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}
