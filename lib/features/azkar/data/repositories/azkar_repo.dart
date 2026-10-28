import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/dio_client.dart';
import '../models/azkar_model.dart';
import '../../../../../core/constants/api_constants.dart';

class AzkarRepo {
  static const String _morningCacheKey = 'cache_morning_azkar';
  static const String _eveningCacheKey = 'cache_evening_azkar';
  static const String _afterPrayerCacheKey = 'cache_after_prayer_azkar';

  // Tier 1: In-memory cache (0ms instant access)
  static AzkarModel? _cachedMorning;
  static AzkarModel? _cachedEvening;
  static AzkarModel? _cachedAfterPrayer;

  // Synchronous getters
  static AzkarModel? get cachedMorning => _cachedMorning;
  static AzkarModel? get cachedEvening => _cachedEvening;
  static AzkarModel? get cachedAfterPrayer => _cachedAfterPrayer;

  /// Preload all Azkar into memory cache for instant UI rendering
  static Future<void> preloadAllAzkar() async {
    try {
      await Future.wait([
        getMorningAzkar(),
        getEveningAzkar(),
        getAfterPrayerAzkar(),
      ]);
      log('✅ [AzkarRepo] All Azkar preloaded successfully');
    } catch (e) {
      log('⚠️ [AzkarRepo] Azkar preload error: $e');
    }
  }

  static Future<Either<String, AzkarModel>> getMorningAzkar() async {
    // 1. In-memory cache
    if (_cachedMorning != null) {
      return right(_cachedMorning!);
    }

    // 2. SharedPreferences persistent cache
    final cached = await _getFromCache(_morningCacheKey);
    if (cached != null) {
      _cachedMorning = cached;
      return right(cached);
    }

    // 3. Bundled local assets (offline-first)
    try {
      final jsonStr = await rootBundle.loadString('assets/data/azkar_sabah.json');
      final data = jsonDecode(jsonStr);
      final azkar = AzkarModel.fromJson(data);
      _cachedMorning = azkar;
      _saveToCache(_morningCacheKey, jsonStr);
      return right(azkar);
    } catch (e) {
      log('Bundled morning azkar asset read error: $e');
    }

    // 4. Remote API fallback
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarMorningApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);
      _cachedMorning = azkar;
      _saveToCache(_morningCacheKey, jsonEncode(res.data));
      return right(azkar);
    } catch (e) {
      log('Fetching morning azkar failed: $e');
      return left(e.toString());
    }
  }

  static Future<Either<String, AzkarModel>> getEveningAzkar() async {
    // 1. In-memory cache
    if (_cachedEvening != null) {
      return right(_cachedEvening!);
    }

    // 2. SharedPreferences persistent cache
    final cached = await _getFromCache(_eveningCacheKey);
    if (cached != null) {
      _cachedEvening = cached;
      return right(cached);
    }

    // 3. Bundled local assets (offline-first)
    try {
      final jsonStr = await rootBundle.loadString('assets/data/azkar_massa.json');
      final data = jsonDecode(jsonStr);
      final azkar = AzkarModel.fromJson(data);
      _cachedEvening = azkar;
      _saveToCache(_eveningCacheKey, jsonStr);
      return right(azkar);
    } catch (e) {
      log('Bundled evening azkar asset read error: $e');
    }

    // 4. Remote API fallback
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarMassaApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);
      _cachedEvening = azkar;
      _saveToCache(_eveningCacheKey, jsonEncode(res.data));
      return right(azkar);
    } catch (e) {
      log('Fetching evening azkar failed: $e');
      return left(e.toString());
    }
  }

  static Future<Either<String, AzkarModel>> getAfterPrayerAzkar() async {
    // 1. In-memory cache
    if (_cachedAfterPrayer != null) {
      return right(_cachedAfterPrayer!);
    }

    // 2. SharedPreferences persistent cache
    final cached = await _getFromCache(_afterPrayerCacheKey);
    if (cached != null) {
      _cachedAfterPrayer = cached;
      return right(cached);
    }

    // 3. Bundled local assets (offline-first)
    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/azkar_post_prayer.json');
      final data = jsonDecode(jsonStr);
      final azkar = AzkarModel.fromJson(data);
      _cachedAfterPrayer = azkar;
      _saveToCache(_afterPrayerCacheKey, jsonStr);
      return right(azkar);
    } catch (e) {
      log('Bundled after-prayer azkar asset read error: $e');
    }

    // 4. Remote API fallback
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarPostPrayerApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);
      _cachedAfterPrayer = azkar;
      _saveToCache(_afterPrayerCacheKey, jsonEncode(res.data));
      return right(azkar);
    } catch (e) {
      log('Fetching after prayer azkar failed: $e');
      return left(e.toString());
    }
  }

  static Future<void> _saveToCache(String key, String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonString);
    } catch (e) {
      log('Cache save error for $key: $e');
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
