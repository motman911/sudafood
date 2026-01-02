import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

// ✅ استخدام Package Imports لضمان استقرار المسارات
import 'package:sudafood/core/services/restaurant_service.dart';
import 'package:sudafood/core/widgets/app_input.dart';
import 'package:sudafood/core/widgets/app_button.dart';
import 'package:sudafood/core/utils/ui_helpers.dart';
import 'package:sudafood/core/utils/validators.dart';
import 'package:sudafood/core/theme/app_colors.dart';
import 'package:sudafood/models/restaurant_model.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedCountry = 'Sudan';
  String _selectedCategory = 'عام';
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = [
    'عام',
    'بيتزا',
    'مشويات',
    'سوداني',
    'حلويات',
    'برجر'
  ];

  // دالة اختيار الصورة مع تحسين الجودة لتوفير مساحة التخزين
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // تقليل الجودة لسرعة الرفع وتوفير البيانات
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      UIHelpers.showSnackBar(context, "حدث خطأ أثناء اختيار الصورة",
          isError: true);
    }
  }

  // دالة الإرسال لربط الواجهة بالخدمة يدوياً
  void _submit() async {
    // 1. التحقق من اختيار الصورة أولاً
    if (_imageFile == null) {
      UIHelpers.showSnackBar(context, "يرجى اختيار صورة للمطعم أولاً",
          isError: true);
      return;
    }

    // 2. التحقق من صحة المدخلات عبر الـ Form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 3. إنشاء كائن الموديل (ID فريد لكل مطعم يتم إنشاؤه يدوياً)
    final restaurant = RestaurantModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      imageUrl: '', // سيتم تحديثه داخل RestaurantService بعد رفع الصورة
      rating: 0.0,
      deliveryTime: "30-45 min",
      country: _selectedCountry,
      city: _cityController.text.trim(),
      category: _selectedCategory,
      isOpen: true,
    );

    try {
      // إرسال البيانات للخدمة لرفع الصورة وحفظ البيانات في Firestore
      await RestaurantService().addRestaurant(restaurant, _imageFile!);

      if (mounted) {
        UIHelpers.showSnackBar(
            context, "تمت إضافة مطعم ${_nameController.text} بنجاح ✅");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showSnackBar(context, "فشل الإرسال: ${e.toString()}",
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة مطعم جديد",
            style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("صورة المطعم الرئيسية",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const SizedBox(height: 12),
              _buildImagePicker(isDark),
              UIHelpers.verticalSpaceMedium,
              AppInput(
                label: "اسم المطعم",
                hint: "مثلاً: مطعم نبع النيل",
                controller: _nameController,
                validator: (val) => Validators.required(val),
              ),
              UIHelpers.verticalSpaceSmall,
              AppInput(
                label: "المدينة / الحي",
                hint: "مثلاً: الخرطوم، حي الرياض، كيجالي",
                controller: _cityController,
                validator: (val) => Validators.required(val),
              ),
              UIHelpers.verticalSpaceSmall,
              Row(
                children: [
                  Expanded(
                    child: _buildLabelAndDropdown(
                      "الدولة",
                      _selectedCountry,
                      (val) => setState(() => _selectedCountry = val!),
                      ["Sudan", "Rwanda"],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildLabelAndDropdown(
                      "التصنيف",
                      _selectedCategory,
                      (val) => setState(() => _selectedCategory = val!),
                      _categories,
                    ),
                  ),
                ],
              ),
              UIHelpers.verticalSpaceExtraLarge,
              AppButton(
                text: "تأكيد وإضافة المطعم",
                onPressed: _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return GestureDetector(
      onTap: _pickImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.grey[100],
            border: Border.all(
                color: isDark ? AppColors.borderDark : Colors.grey[300]!),
          ),
          child: _imageFile != null
              ? Image.file(_imageFile!, fit: BoxFit.cover)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 50, color: AppColors.primary),
                    SizedBox(height: 10),
                    Text("اضغط لاختيار صورة المطعم",
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                    Text("(يفضل أبعاد عريضة)",
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLabelAndDropdown(String label, String value,
      Function(String?) onChanged, List<String> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark ? AppColors.borderDark : Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Cairo'),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e == "Sudan"
                            ? "السودان 🇸🇩"
                            : e == "Rwanda"
                                ? "رواندا 🇷🇼"
                                : e),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
