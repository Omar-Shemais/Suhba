import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:islamic_app/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith_model.dart';

abstract class HadithRepository {
  Future<HadithResponse> getHadiths({
    String? book,
    int page = 1,
    int limit = 20,
  });

  Future<List<HadithModel>> searchHadiths({
    String? arabicQuery,
    String? englishQuery,
  });

  List<HadithModel> getCachedHadiths({String? book});
}

class HadithRepositoryImpl implements HadithRepository {
  final Dio dio;
  static const String baseUrl = ApiConstants.hadithApiBase;
  static const String apiKey = ApiConstants.hadithApiKey;
  static const String _prefsCacheKey = 'hadiths_user_cached_v1';

  static List<HadithModel>? _memoryCache;
  static bool _isLoadingCache = false;

  HadithRepositoryImpl({required this.dio}) {
    _ensureCacheLoaded();
  }

  /// تحميل الأحاديث من الكاش المخزن والأصول المدمجة
  Future<void> _ensureCacheLoaded() async {
    if (_memoryCache != null && _memoryCache!.isNotEmpty) return;
    if (_isLoadingCache) {
      while (_isLoadingCache) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    _isLoadingCache = true;
    try {
      final List<HadithModel> loaded = [];

      // 1. قراءة الكاش المحلي من SharedPreferences إن وجد
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString(_prefsCacheKey);
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final List<dynamic> decoded = json.decode(cachedJson);
          for (final item in decoded) {
            loaded.add(HadithModel.fromJson(item as Map<String, dynamic>));
          }
        }
      } catch (e) {
        debugPrint('⚠️ [HadithRepository] SharedPreferences read error: $e');
      }

      // 2. قراءة الكاش المدمج في assets/data/hadiths_cache.json
      try {
        final jsonStr = await rootBundle.loadString('assets/data/hadiths_cache.json');
        final Map<String, dynamic> data = json.decode(jsonStr);
        final List<dynamic> list = data['hadiths'] as List<dynamic>? ?? [];

        final existingIds = loaded.map((h) => h.id).toSet();
        for (final item in list) {
          final model = HadithModel.fromJson(item as Map<String, dynamic>);
          if (!existingIds.contains(model.id)) {
            loaded.add(model);
            existingIds.add(model.id);
          }
        }
      } catch (e) {
        debugPrint('⚠️ [HadithRepository] rootBundle cache read error: $e');
      }

      _memoryCache = loaded;
      debugPrint('📚 [HadithRepository] Cache loaded with ${_memoryCache?.length ?? 0} hadiths');
    } finally {
      _isLoadingCache = false;
    }
  }

  /// حفظ الأحاديث الجديدة في الكاش الدائم
  Future<void> _saveToPersistentCache(List<HadithModel> newHadiths) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = _memoryCache ?? [];
      final existingIds = current.map((h) => h.id).toSet();

      bool added = false;
      for (final h in newHadiths) {
        if (!existingIds.contains(h.id)) {
          current.add(h);
          existingIds.add(h.id);
          added = true;
        }
      }

      if (added) {
        _memoryCache = current;
        final jsonList = current.map((h) => h.toJson()).toList();
        await prefs.setString(_prefsCacheKey, json.encode(jsonList));
      }
    } catch (e) {
      debugPrint('⚠️ [HadithRepository] Cache save error: $e');
    }
  }

  @override
  List<HadithModel> getCachedHadiths({String? book}) {
    if (_memoryCache == null || _memoryCache!.isEmpty) return [];

    if (book == null || book == 'all') {
      return List.unmodifiable(_memoryCache!);
    }

    return _memoryCache!.where((h) => h.bookSlug == book).toList();
  }

  @override
  Future<HadithResponse> getHadiths({
    String? book,
    int page = 1,
    int limit = 20,
  }) async {
    await _ensureCacheLoaded();

    final List<HadithModel> localForBook = getCachedHadiths(book: book);
    final startIndex = (page - 1) * limit;
    final pagedLocal = startIndex < localForBook.length
        ? localForBook.skip(startIndex).take(limit).toList()
        : <HadithModel>[];

    // محاولة جلب أحدث الأحاديث من الشبكة
    try {
      final queryParams = {
        'apiKey': apiKey,
        'page': page.toString(),
        'limit': limit.toString(),
        if (book != null && book != 'all') 'book': book,
      };

      final response = await dio.get(
        '$baseUrl/hadiths/',
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        final apiResponse =
            HadithResponse.fromJson(response.data as Map<String, dynamic>);
        if (apiResponse.hadiths.isNotEmpty) {
          _saveToPersistentCache(apiResponse.hadiths);
          return apiResponse;
        }
      }
    } catch (e) {
      debugPrint('ℹ️ [HadithRepository] الشبكة غير متاحة أو معطلة، سيتم الاعتماد على الأحاديث المكيفة: $e');
    }

    // Fallback للكاش المحلي الفوري
    if (localForBook.isNotEmpty) {
      return HadithResponse(
        hadiths: pagedLocal.isNotEmpty ? pagedLocal : localForBook.take(limit).toList(),
        total: localForBook.length,
        page: page,
        limit: limit,
      );
    }

    throw Exception('فشل تحميل الأحاديث. يرجى التحقق من الاتصال.');
  }

  @override
  Future<List<HadithModel>> searchHadiths({
    String? arabicQuery,
    String? englishQuery,
  }) async {
    await _ensureCacheLoaded();

    // البحث المحلي الفوري في الكاش
    final localMatches = (_memoryCache ?? []).where((h) {
      final qAr = arabicQuery?.trim().toLowerCase() ?? '';
      final qEn = englishQuery?.trim().toLowerCase() ?? '';
      bool match = false;
      if (qAr.isNotEmpty) {
        match = h.hadithArabic.toLowerCase().contains(qAr) ||
            (h.arabicNarrator?.toLowerCase().contains(qAr) ?? false);
      }
      if (!match && qEn.isNotEmpty) {
        match = h.hadithEnglish.toLowerCase().contains(qEn) ||
            (h.englishNarrator?.toLowerCase().contains(qEn) ?? false);
      }
      return match;
    }).toList();

    // محاولة البحث عبر الشبكة إذا أمكن
    try {
      final queryParams = <String, dynamic>{'apiKey': apiKey, 'limit': '50'};
      if (arabicQuery != null && arabicQuery.isNotEmpty) {
        queryParams['hadithArabic'] = arabicQuery;
      }
      if (englishQuery != null && englishQuery.isNotEmpty) {
        queryParams['hadithEnglish'] = englishQuery;
      }

      if (queryParams.containsKey('hadithArabic') ||
          queryParams.containsKey('hadithEnglish')) {
        final response = await dio.get(
          '$baseUrl/hadiths/',
          queryParameters: queryParams,
        );

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['status'] != 404 && data['message'] != 'Hadiths not found.') {
            List<dynamic> hadithsList = [];
            if (data.containsKey('hadiths') && data['hadiths'] is Map) {
              final hadithsMap = data['hadiths'] as Map<String, dynamic>;
              hadithsList = (hadithsMap['data'] as List<dynamic>?) ?? [];
            } else if (data.containsKey('hadiths') && data['hadiths'] is List) {
              hadithsList = data['hadiths'] as List<dynamic>;
            }

            final networkResults = hadithsList
                .map((h) => HadithModel.fromJson(h as Map<String, dynamic>))
                .toList();

            if (networkResults.isNotEmpty) {
              _saveToPersistentCache(networkResults);
              return networkResults;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('ℹ️ [HadithRepository] فشل البحث الشبكي، الاعتماد على نتائج البحث المحلية: $e');
    }

    return localMatches;
  }
}
