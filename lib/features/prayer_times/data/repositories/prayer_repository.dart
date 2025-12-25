// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import '../models/prayer_times_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/core/constants/api_constants.dart';
import 'package:islamic_app/core/network/dio_client.dart';

abstract class PrayerRepository {
  Future<Either<String, PrayerTimesModel>> getPrayerTimes({
    double? latitude,
    double? longitude,
    String? date,
  });

  Future<PrayerTimesModel?> getCachedPrayerTimes();
  Future<void> cachePrayerTimes(PrayerTimesModel prayerTimes);
  Future<bool> shouldUpdatePrayerTimes();
}

class PrayerRepositoryImpl implements PrayerRepository {
  static const String _prayerTimesKey = 'prayer_times_cache';
  static const String _lastUpdateKey = 'last_prayer_update';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<Either<String, PrayerTimesModel>> getPrayerTimes({
    double? latitude,
    double? longitude,
    String? date,
  }) async {
    try {
      final formattedDate =
          date ?? DateFormat('dd-MM-yyyy').format(DateTime.now());

      // ✅ استخدام endpoint الـ timings مع coordinates
      final endpoint = '${ApiConstants.aladhanBase}/timings/$formattedDate';

      final response = await DioClient.getData(
        endPoint: endpoint,
        queryParameters: {
          'latitude': latitude ?? 31.0409, // المنصورة (default)
          'longitude': longitude ?? 31.3785,
          'method': 5, // المعيار المصري
        },
      );

      if (response.statusCode == 200) {
        final prayerTimes = PrayerTimesModel.fromJson(response.data);
        await cachePrayerTimes(prayerTimes);
        return Right(prayerTimes);
      } else {
        return Left('فشل في جلب مواقيت الصلاة');
      }
    } catch (e) {
      return Left('خطأ في الاتصال: ${e.toString()}');
    }
  }

  @override
  Future<PrayerTimesModel?> getCachedPrayerTimes() async {
    try {
      final prefs = await _getPrefs;
      final cachedString = prefs.getString(_prayerTimesKey);

      if (cachedString == null || cachedString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> cachedMap = json.decode(cachedString);
      final prayerTimes = PrayerTimesModel.fromMap(cachedMap);

      if (prayerTimes.isValidForToday()) {
        return prayerTimes;
      } else {
        await prefs.remove(_prayerTimesKey);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cachePrayerTimes(PrayerTimesModel prayerTimes) async {
    try {
      final prefs = await _getPrefs;
      final mapData = prayerTimes.toMap();
      final jsonString = json.encode(mapData);

      await prefs.setString(_prayerTimesKey, jsonString);
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {}
  }

  @override
  Future<bool> shouldUpdatePrayerTimes() async {
    try {
      final prefs = await _getPrefs;
      final lastUpdateString = prefs.getString(_lastUpdateKey);

      if (lastUpdateString == null || lastUpdateString.isEmpty) {
        return true;
      }

      final lastUpdate = DateTime.parse(lastUpdateString);
      final now = DateTime.now();

      final isDifferentDay =
          lastUpdate.year != now.year ||
          lastUpdate.month != now.month ||
          lastUpdate.day != now.day;

      return isDifferentDay;
    } catch (e) {
      return true;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await _getPrefs;
      await prefs.remove(_prayerTimesKey);
      await prefs.remove(_lastUpdateKey);
    } catch (e) {}
  }
}
