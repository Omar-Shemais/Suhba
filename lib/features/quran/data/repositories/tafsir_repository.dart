import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tafsir_model.dart';

class TafsirRepository {
  static const String tafsirBaseUrl = 'https://quranenc.com/api/v1/';

  final Dio _dio;
  final Map<String, AyahTafsirModel> _memoryAyahCache = {};
  final Map<String, List<AyahTafsirModel>> _memorySurahCache = {};

  TafsirRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: tafsirBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Accept': 'application/json',
                  'User-Agent':
                      'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
                },
              ),
            );

  /// تصحيح مفتاح التفسير إذا أرسل المستخدم أو الرابط بصيغة muyassar بدلاً من moyassar
  String _normalizeKey(String key) {
    if (key == 'arabic_muyassar') return 'arabic_moyassar';
    return key;
  }

  /// جلب تفسير آية واحدة
  Future<AyahTafsirModel> getAyahTafsir({
    required int suraNumber,
    required int ayaNumber,
    String tafsirKey = 'arabic_moyassar',
  }) async {
    final normalizedKey = _normalizeKey(tafsirKey);
    final cacheKey = '$normalizedKey-$suraNumber-$ayaNumber';

    if (_memoryAyahCache.containsKey(cacheKey)) {
      return _memoryAyahCache[cacheKey]!;
    }

    // فحص التخزين المحلي الدائم
    final prefs = await SharedPreferences.getInstance();
    final localJson = prefs.getString('tafsir_ayah_$cacheKey');
    if (localJson != null && localJson.isNotEmpty) {
      try {
        final decoded = json.decode(localJson);
        final model = AyahTafsirModel.fromJson(decoded);
        _memoryAyahCache[cacheKey] = model;
        return model;
      } catch (_) {}
    }

    try {
      // Endpoint: translation/aya/{tafsir_key}/{sura_number}/{aya_number}
      final response = await _dio.get(
        'translation/aya/$normalizedKey/$suraNumber/$ayaNumber',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data as String)
            : response.data;

        final result = data['result'];
        if (result != null) {
          final model = AyahTafsirModel.fromJson(result as Map<String, dynamic>);
          _memoryAyahCache[cacheKey] = model;

          // حفظ محلياً للقراءة بدون إنترنت لاحقاً
          await prefs.setString('tafsir_ayah_$cacheKey', json.encode(result));
          return model;
        }
      }
      throw Exception('لم يتم العثور على تفسير لهذه الآية');
    } catch (e) {
      debugPrint('❌ خطأ في جلب تفسير الآية: $e');
      rethrow;
    }
  }

  /// جلب تفسير سور كاملة
  Future<List<AyahTafsirModel>> getSurahTafsir({
    required int suraNumber,
    String tafsirKey = 'arabic_moyassar',
  }) async {
    final normalizedKey = _normalizeKey(tafsirKey);
    final cacheKey = '$normalizedKey-$suraNumber';

    if (_memorySurahCache.containsKey(cacheKey)) {
      return _memorySurahCache[cacheKey]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final localJson = prefs.getString('tafsir_surah_$cacheKey');
    if (localJson != null && localJson.isNotEmpty) {
      try {
        final decoded = json.decode(localJson) as List<dynamic>;
        final list = decoded
            .map((item) => AyahTafsirModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _memorySurahCache[cacheKey] = list;
        return list;
      } catch (_) {}
    }

    try {
      // Endpoint: translation/sura/{tafsir_key}/{sura_number}
      final response = await _dio.get(
        'translation/sura/$normalizedKey/$suraNumber',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data as String)
            : response.data;

        final results = data['result'] as List<dynamic>?;
        if (results != null) {
          final list = results
              .map((item) => AyahTafsirModel.fromJson(item as Map<String, dynamic>))
              .toList();

          _memorySurahCache[cacheKey] = list;

          // Cache each ayah in memory as well
          for (final ayah in list) {
            _memoryAyahCache['$normalizedKey-$suraNumber-${ayah.aya}'] = ayah;
          }

          await prefs.setString('tafsir_surah_$cacheKey', json.encode(results));
          return list;
        }
      }
      throw Exception('فشل في جلب تفسير السورة');
    } catch (e) {
      debugPrint('❌ خطأ في جلب تفسير السورة: $e');
      rethrow;
    }
  }
}
