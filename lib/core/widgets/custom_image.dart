import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import 'app_skeleton.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final bool isCircle;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12, // القيمة الافتراضية متوافقة مع AppCard
    this.fit = BoxFit.cover,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(isCircle ? (width ?? 100) / 2 : borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        // تحسين الذاكرة المؤقتة (Cache) لتقليل استهلاك البيانات
        maxWidthDiskCache: 500,
        maxHeightDiskCache: 500,
        // استخدام الهيكل العظمي المخصص أثناء التحميل
        placeholder: (context, url) => isCircle
            ? AppSkeleton.circle(size: width ?? 50)
            : AppSkeleton(
                width: width,
                height: height,
                borderRadius: 0, // الـ ClipRRect الخارجي يتكفل بالانحناء
              ),
        // تحسين مظهر الخطأ ليتناسب مع الوضع الليلي
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: isDark ? AppColors.cardDark : Colors.grey[200],
          child: Icon(
            Icons.image_not_supported_outlined,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            size: (width != null && width! < 50) ? 20 : 30,
          ),
        ),
      ),
    );
  }
}
