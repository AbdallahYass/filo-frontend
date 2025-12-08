// lib/services/location_service.dart

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// يتحقق من تصريح الموقع ويطلبه إذا لزم الأمر، ثم يجلب الموقع الحالي.
  Future<Position?> getCurrentPositionSafe() async {
    // 1. فحص ما إذا كانت خدمة الموقع مفعلة على الجهاز (GPS)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // إذا كانت الخدمة معطلة، يمكن هنا فتح إعدادات الموقع
      Geolocator.openLocationSettings();
      if (kDebugMode) {
        print("Location services are disabled.");
      }
      return null;
    }

    // 2. فحص حالة التصريح الممنوح للتطبيق
    LocationPermission permission = await Geolocator.checkPermission();

    // إذا كان التصريح مرفوضاً مسبقاً، اطلب التصريح
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // إذا ظل التصريح مرفوضاً أو تم رفضه نهائياً، أوقف العملية
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print("Location permissions are denied or permanently denied.");
      }
      return null;
    }

    // 3. جلب الموقع (أعلى دقة ممكنة)
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (kDebugMode) {
        print("Location fetched: ${position.latitude}, ${position.longitude}");
      }
      return position;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
      return null;
    }
  }
}
