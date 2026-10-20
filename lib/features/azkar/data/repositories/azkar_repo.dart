import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/dio_client.dart';
import '../models/azkar_model.dart';
import '../../../../../core/constants/api_constants.dart';

class AzkarRepo {
  static const String _morningCacheKey = 'cache_morning_azkar';
  static const String _eveningCacheKey = 'cache_evening_azkar';
  static const String _afterPrayerCacheKey = 'cache_after_prayer_azkar';

  static Future<Either<String, AzkarModel>> getMorningAzkar() async {
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarMorningApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);
      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_morningCacheKey, jsonEncode(res.data));

      return right(azkar);
    } catch (e) {
      log('Fetching morning azkar failed, attempting cache: $e');
      final cached = await _getFromCache(_morningCacheKey);
      if (cached != null) return right(cached);
      return left(e.toString());
    }
  }

  static Future<Either<String, AzkarModel>> getEveningAzkar() async {
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarMassaApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);
      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_eveningCacheKey, jsonEncode(res.data));

      return right(azkar);
    } catch (e) {
      log('Fetching evening azkar failed, attempting cache: $e');
      final cached = await _getFromCache(_eveningCacheKey);
      if (cached != null) return right(cached);
      return left(e.toString());
    }
  }

  static Future<Either<String, AzkarModel>> getAfterPrayerAzkar() async {
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarPostPrayerApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);
      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_afterPrayerCacheKey, jsonEncode(res.data));

      return right(azkar);
    } catch (e) {
      log('Fetching after prayer azkar failed, attempting cache: $e');
      final cached = await _getFromCache(_afterPrayerCacheKey);
      if (cached != null) return right(cached);
      return left(e.toString());
    }
  }

  static Future<AzkarModel?> _getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(key);
      if (str != null && str.isNotEmpty) {
        final data = jsonDecode(str);
        return AzkarModel.fromJson(data);
      }
    } catch (e) {
      log('Cache read error for $key: $e');
    }
    return null;
  }
}
