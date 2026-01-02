import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استيراد المكونات الموحدة
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/models/menu_item_model.dart';
import 'package:sudafood/core/services/menu_service.dart';

class AddDishScreen extends StatefulWidget {
  final String restaurantId;
  const AddDishScreen({super.key, required this.restaurantId});

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();

  // وحدات التحكم بالنصوص
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  bool _isLoading = false;

  void _saveDish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // توليد ID بسيط للوجبة (أو يمكنك ترك Firestore يولد ID تلقائي إذا عدلت الموديل)
      final String dishId = DateTime.now().millisecondsSinceEpoch.toString();

      // إنشاء كائن الوجبة
      final newDish = MenuItem(
        id: dishId,
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        // إذا لم يدخل صورة، نضع صورة افتراضية
        imageUrl: _imageController.text.isNotEmpty
            ? _imageController.text.trim()
            : "",
        category: _categoryController.text.trim(),
        isAvailable: true,
      );

      // إرسال للخدمة (Service)
      await MenuService().addDish(widget.restaurantId, newDish);

      if (mounted) {
        UIHelpers.showSnackBar(context, "تم إضافة الوجبة بنجاح ✅");
        Navigator.pop(context); // العودة للشاشة السابقة
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showSnackBar(context, "حدث خطأ: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة وجبة جديدة",
            style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppInput(
                label: "اسم الوجبة",
                hint: "مثلاً: برجر دجاج",
                controller: _nameController,
                prefixIcon: LucideIcons.utensils,
                validator: (val) => val!.isEmpty ? "مطلوب" : null,
              ),
              UIHelpers.verticalSpaceMedium,
              AppInput(
                label: "السعر",
                hint: "مثلاً: 2500",
                controller: _priceController,
                prefixIcon: LucideIcons.dollarSign,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "مطلوب" : null,
              ),
              UIHelpers.verticalSpaceMedium,
              AppInput(
                label: "التصنيف",
                hint: "مثلاً: وجبات سريعة",
                controller: _categoryController,
                prefixIcon: LucideIcons.tag,
                validator: (val) => val!.isEmpty ? "مطلوب" : null,
              ),
              UIHelpers.verticalSpaceMedium,
              AppInput(
                label: "رابط الصورة (URL)",
                hint: "https://example.com/image.png",
                controller: _imageController,
                prefixIcon: LucideIcons.image,
              ),
              UIHelpers.verticalSpaceMedium,
              AppInput(
                label: "الوصف",
                hint: "مكونات الوجبة...",
                controller: _descController,
                prefixIcon: LucideIcons.fileText,
                maxLines: 3,
                validator: (val) => val!.isEmpty ? "مطلوب" : null,
              ),
              UIHelpers.verticalSpaceLarge,
              AppButton(
                text: "حفظ الوجبة",
                isLoading: _isLoading,
                onPressed: _saveDish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
