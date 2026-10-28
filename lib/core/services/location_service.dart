import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationKey = 'saved_location';
  static const String _lastLocationUpdateKey = 'last_location_update';

  /// التحقق من الصلاحيات والحصول على الموقع
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // التحقق من تفعيل خدمات الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // التحقق من صلاحيات الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // تحويل الإحداثيات إلى عنوان
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String city = place.locality ?? place.subAdministrativeArea ?? 'Cairo';
        String country = place.country ?? 'Egypt';

        // ✅ حفظ الموقع مع الـ Coordinates
        final locationData = {
          'city': city,
          'country': country,
          'latitude': position.latitude,
          'longitude': position.longitude,
        };

        await saveLocation(locationData);

        return locationData;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// حفظ الموقع في SharedPreferences
  Future<void> saveLocation(Map<String, dynamic> location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, json.encode(location));
    await prefs.setString(
      _lastLocationUpdateKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// جلب الموقع المحفوظ
  Future<Map<String, dynamic>?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedString = prefs.getString(_locationKey);

      if (savedString != null) {
        return json.decode(savedString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// التحقق إذا كان يجب تحديث الموقع (مرتين في اليوم)
  Future<bool> shouldUpdateLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getString(_lastLocationUpdateKey);

      if (lastUpdate == null) return true;

      final lastUpdateDate = DateTime.parse(lastUpdate);
      final now = DateTime.now();
      final difference = now.difference(lastUpdateDate);

      // تحديث كل 12 ساعة (مرتين في اليوم)
      return difference.inHours >= 12;
    } catch (e) {
      return true;
    }
  }

  /// مسح الموقع المحفوظ
  Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_locationKey);
    await prefs.remove(_lastLocationUpdateKey);
  }
}
