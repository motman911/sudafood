import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 1. التأكد من الصلاحيات والحصول على الموقع الحالي
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // هل خدمة الموقع مفعلة في الجهاز؟
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('خدمة الموقع غير مفعلة في جهازك.');
    }

    // التحقق من الصلاحيات
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('تم رفض صلاحية الوصول للموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'صلاحيات الموقع مرفوضة نهائياً، يرجى تفعيلها من الإعدادات.');
    }

    // الحصول على الموقع الحالي بدقة عالية
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// 2. تتبع الموقع المباشر (مفيد جداً للسائقين في السودان ورواندا)
  /// يقوم بإرسال تحديثات الموقع فقط عند التحرك لمسافة معينة
  Stream<Position> getLiveLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // تحديث الموقع كل 10 أمتار لتوفير البيانات والبطارية
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 3. حساب المسافة بين نقطتين بالكيلومتر
  double calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    double distanceInMeters =
        Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    return distanceInMeters / 1000; // تحويل لكيلومتر
  }

  /// 4. حساب وقت الوصول التقريبي (Estimated Time)
  /// يفترض سرعة متوسطة 30 كم/ساعة (مناسب لظروف الزحام)
  String getEstimatedTime(double distanceKm) {
    double timeHours = distanceKm / 30;
    int timeMinutes = (timeHours * 60).round();
    if (timeMinutes < 1) return "قريب جداً";
    return "$timeMinutes دقيقة";
  }
}
