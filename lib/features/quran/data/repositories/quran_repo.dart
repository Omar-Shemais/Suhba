import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:islamic_app/core/constants/api_constance.dart';
import 'package:islamic_app/core/constants/storage_constants.dart';
import 'package:islamic_app/core/network/dio_client.dart';
import 'package:islamic_app/core/utils/cache_helper.dart';
import '../models/hizb_model.dart';
import '../models/juz_model.dart';
import '../models/quran_models.dart';

abstract class QuranRepository {
  Future<List<SurahModel>> getAllSurahs();
  Future<SurahModel> getSurahById(int id);
  Future<List<SurahModel>> searchSurahs(String query);
  Future<QuranSectionModel> getJuzDetail(int juzNumber);
  Future<QuranSectionModel> getHizbDetail(int hizbNumber);

  // Synchronous cache checks for 0ms instant loading
  List<SurahModel>? getCachedSurahs();
  SurahModel? getCachedSurahById(int id);
  QuranSectionModel? getCachedJuzDetail(int juzNumber);
  QuranSectionModel? getCachedHizbDetail(int hizbNumber);

  // Background preloading
  void prefetchAdjacentAjza(int currentJuz);
  void prefetchAllAjzaInBackground();
  void prefetchAdjacentSurahs(int currentSurahId);
  void prefetchCommonSurahsInBackground();
}

class QuranRepositoryImpl implements QuranRepository {
  List<SurahModel>? _cachedSurahs;
  final Map<int, SurahModel> _cachedSurahDetails = {};
  final Map<int, QuranSectionModel> _cachedJuzDetails = {};
  final Map<int, QuranSectionModel> _cachedHizbDetails = {};
  final Set<int> _activePrefetches = {};
  bool _isBackgroundPrefetching = false;

  @override
  List<SurahModel>? getCachedSurahs() {
    if (_cachedSurahs != null && _cachedSurahs!.isNotEmpty) {
      return _cachedSurahs;
    }
    try {
      final raw = CacheHelper.getDataSync<String>(
        boxName: StorageConstants.quranBoxName,
        key: 'all_surahs_list',
      );
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _cachedSurahs = decoded
            .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return _cachedSurahs;
      }
    } catch (_) {}
    return null;
  }

  @override
  SurahModel? getCachedSurahById(int id) {
    if (_cachedSurahDetails.containsKey(id) &&
        _cachedSurahDetails[id]!.verses.isNotEmpty) {
      return _cachedSurahDetails[id];
    }
    try {
      final raw = CacheHelper.getDataSync<String>(
        boxName: StorageConstants.quranBoxName,
        key: 'surah_detail_$id',
      );
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final surah = SurahModel.fromJson(decoded);
        _cachedSurahDetails[id] = surah;
        return surah;
      }
    } catch (_) {}

    // استخراج فوري (0ms) من الأجزاء المخزنة إذا كانت متوفرة محلياً
    try {
      final containingAjza = JuzItem.ajza.where((j) => j.surahIds.contains(id)).toList();
      if (containingAjza.isNotEmpty) {
        final List<VerseModel> allVerses = [];
        SurahModel? surahInfo;
        bool allAjzaCached = true;

        for (final jItem in containingAjza) {
          final jDetail = getCachedJuzDetail(jItem.number);
          if (jDetail == null) {
            allAjzaCached = false;
            break;
          }
          surahInfo ??= jDetail.surahsMap[id];
          final versesForThisSurah = jDetail.verses.where((v) => v.surahId == id).toList();
          allVerses.addAll(versesForThisSurah);
        }

        if (allAjzaCached && allVerses.isNotEmpty && surahInfo != null) {
          allVerses.sort((a, b) => a.id.compareTo(b.id));
          if (allVerses.length >= surahInfo.totalVerses) {
            final reconstructed = SurahModel(
              id: id,
              name: surahInfo.name,
              transliteration: surahInfo.transliteration,
              translation: surahInfo.translation,
              type: surahInfo.type,
              totalVerses: surahInfo.totalVerses,
              verses: allVerses,
            );

            _cachedSurahDetails[id] = reconstructed;

            try {
              CacheHelper.saveData<String>(
                boxName: StorageConstants.quranBoxName,
                key: 'surah_detail_$id',
                value: jsonEncode(reconstructed.toJson()),
              );
            } catch (_) {}

            return reconstructed;
          }
        }
      }
    } catch (_) {}

    return null;
  }

  @override
  QuranSectionModel? getCachedJuzDetail(int juzNumber) {
    if (_cachedJuzDetails.containsKey(juzNumber)) {
      return _cachedJuzDetails[juzNumber];
    }
    try {
      final raw = CacheHelper.getDataSync<String>(
        boxName: StorageConstants.quranBoxName,
        key: 'juz_detail_$juzNumber',
      );
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final section = QuranSectionModel.fromJson(decoded);
        _cachedJuzDetails[juzNumber] = section;
        return section;
      }
    } catch (_) {}
    return null;
  }

  @override
  QuranSectionModel? getCachedHizbDetail(int hizbNumber) {
    if (_cachedHizbDetails.containsKey(hizbNumber)) {
      return _cachedHizbDetails[hizbNumber];
    }
    try {
      final raw = CacheHelper.getDataSync<String>(
        boxName: StorageConstants.quranBoxName,
        key: 'hizb_detail_v2_$hizbNumber',
      );
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final section = QuranSectionModel.fromJson(decoded);
        _cachedHizbDetails[hizbNumber] = section;
        return section;
      }
    } catch (_) {}

    // If parent juz is cached, extract the hizb immediately
    final juzNumber = ((hizbNumber - 1) ~/ 2) + 1;
    final parentJuz = getCachedJuzDetail(juzNumber);
    if (parentJuz != null) {
      final startQuarter = (hizbNumber - 1) * 4 + 1;
      final endQuarter = hizbNumber * 4;

      final hizbVerses = parentJuz.verses.where((v) {
        final hq = v.hizbQuarter;
        if (hq == null) return true;
        return hq >= startQuarter && hq <= endQuarter;
      }).toList();

      final hizbItem = HizbItem.ahzab[(hizbNumber - 1).clamp(0, HizbItem.ahzab.length - 1)];
      final firstVerse = hizbVerses.isNotEmpty ? hizbVerses.first : null;
      final startSurah = (firstVerse?.surahNameArabic != null && firstVerse!.surahNameArabic!.isNotEmpty)
          ? firstVerse.surahNameArabic!.replaceAll('سورة ', '').replaceAll('سُورَةُ ', '')
          : hizbItem.startSurahName;
      final startAyah = firstVerse?.id ?? hizbItem.startAyah;

      final section = QuranSectionModel(
        number: hizbNumber,
        title: hizbItem.name,
        subtitle: 'سورة $startSurah (آية $startAyah) • الجزء $juzNumber',
        verses: hizbVerses.isNotEmpty ? hizbVerses : parentJuz.verses,
        surahsMap: parentJuz.surahsMap,
      );

      _cachedHizbDetails[hizbNumber] = section;
      return section;
    }

    return null;
  }

  @override
  Future<List<SurahModel>> getAllSurahs() async {
    final cached = getCachedSurahs();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final response = await DioClient.getData(
        endPoint: '${ApiConstance.quranBaseUrl}${ApiConstance.surah}',
      );

      final List<dynamic> jsonData = response.data['data'] as List<dynamic>;
      _cachedSurahs = jsonData
          .map((json) => SurahModel.fromApiSurah(json as Map<String, dynamic>))
          .toList();

      try {
        final jsonList = _cachedSurahs!.map((s) => s.toJson()).toList();
        CacheHelper.saveData<String>(
          boxName: StorageConstants.quranBoxName,
          key: 'all_surahs_list',
          value: jsonEncode(jsonList),
        );
      } catch (_) {}

      return _cachedSurahs!;
    } catch (e) {
      throw Exception('Failed to load Quran surahs: $e');
    }
  }

  @override
  Future<SurahModel> getSurahById(int id) async {
    final cached = getCachedSurahById(id);
    if (cached != null) {
      prefetchAdjacentSurahs(id);
      return cached;
    }

    try {
      // 1. طلب النص العثماني فقط بنصف الحجم والوقت وبدون استهلاك بيانات زائد
      final response = await DioClient.getData(
        endPoint: '${ApiConstance.quranBaseUrl}${ApiConstance.surah}/$id/quran-uthmani',
      );

      final surahData = response.data['data'] as Map<String, dynamic>;
      final ayahs = (surahData['ayahs'] as List<dynamic>)
          .map((a) => VerseModel.fromApiAyah(a as Map<String, dynamic>))
          .toList();
      final surah = SurahModel.fromApiSurah(surahData, ayahs);
      _cachedSurahDetails[id] = surah;

      try {
        CacheHelper.saveData<String>(
          boxName: StorageConstants.quranBoxName,
          key: 'surah_detail_$id',
          value: jsonEncode(surah.toJson()),
        );
      } catch (_) {}

      prefetchAdjacentSurahs(id);
      return surah;
    } catch (_) {
      try {
        final response = await DioClient.getData(
          endPoint: '${ApiConstance.quranBaseUrl}${ApiConstance.surah}/$id',
        );
        final surahData = response.data['data'] as Map<String, dynamic>;
        final ayahs = (surahData['ayahs'] as List<dynamic>)
            .map((a) => VerseModel.fromApiAyah(a as Map<String, dynamic>))
            .toList();
        final surah = SurahModel.fromApiSurah(surahData, ayahs);
        _cachedSurahDetails[id] = surah;

        try {
          CacheHelper.saveData<String>(
            boxName: StorageConstants.quranBoxName,
            key: 'surah_detail_$id',
            value: jsonEncode(surah.toJson()),
          );
        } catch (_) {}

        prefetchAdjacentSurahs(id);
        return surah;
      } catch (e) {
        throw Exception('Failed to load Surah $id: $e');
      }
    }
  }

  @override
  Future<List<SurahModel>> searchSurahs(String query) async {
    final surahs = await getAllSurahs();
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) return surahs;

    return surahs.where((surah) {
      return surah.name.toLowerCase().contains(lowerQuery) ||
          surah.transliteration.toLowerCase().contains(lowerQuery) ||
          surah.translation.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<QuranSectionModel> getJuzDetail(int juzNumber) async {
    final cached = getCachedJuzDetail(juzNumber);
    if (cached != null) {
      prefetchAdjacentAjza(juzNumber);
      return cached;
    }

    try {
      final response = await DioClient.getData(
        endPoint: '${ApiConstance.quranBaseUrl}${ApiConstance.juz}/$juzNumber/quran-uthmani',
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final ayahsJson = data['ayahs'] as List<dynamic>;
      final surahsJson = data['surahs'] as Map<String, dynamic>? ?? {};

      final Map<int, SurahModel> surahsMap = {};
      surahsJson.forEach((key, val) {
        final sMap = val as Map<String, dynamic>;
        final surahId = (sMap['number'] as num).toInt();
        surahsMap[surahId] = SurahModel.fromApiSurah(sMap);
      });

      final List<VerseModel> verses = [];
      for (var a in ayahsJson) {
        final ayahMap = a as Map<String, dynamic>;
        final surahObj = ayahMap['surah'] as Map<String, dynamic>?;
        final int sId = surahObj != null ? ((surahObj['number'] as num).toInt()) : 1;
        final String sName = surahObj != null ? (surahObj['englishName'] as String? ?? '') : '';
        final String sNameAr = surahObj != null ? (surahObj['name'] as String? ?? '') : '';

        if (!surahsMap.containsKey(sId) && surahObj != null) {
          surahsMap[sId] = SurahModel.fromApiSurah(surahObj);
        }

        verses.add(
          VerseModel(
            id: ((ayahMap['numberInSurah'] ?? ayahMap['number']) as num).toInt(),
            text: (ayahMap['text'] as String?)?.trim() ?? '',
            translation: '',
            surahId: sId,
            surahName: sName,
            surahNameArabic: sNameAr,
            juz: (ayahMap['juz'] as num?)?.toInt(),
            hizbQuarter: (ayahMap['hizbQuarter'] as num?)?.toInt(),
          ),
        );
      }

      final juzItem = JuzItem.ajza[(juzNumber - 1).clamp(0, JuzItem.ajza.length - 1)];
      String subtitle = 'يبدأ من: سورة ${juzItem.startSurahName}';
      if (verses.isNotEmpty) {
        final firstV = verses.first;
        final lastV = verses.last;
        final rawStart = (firstV.surahNameArabic != null && firstV.surahNameArabic!.isNotEmpty)
            ? firstV.surahNameArabic!
            : (surahsMap[firstV.surahId]?.name ?? juzItem.startSurahName);
        final startSName = rawStart
            .replaceAll('سورة', '')
            .replaceAll('سُورَةُ', '')
            .trim();

        final rawEnd = (lastV.surahNameArabic != null && lastV.surahNameArabic!.isNotEmpty)
            ? lastV.surahNameArabic!
            : (surahsMap[lastV.surahId]?.name ?? startSName);
        final endSName = rawEnd
            .replaceAll('سورة', '')
            .replaceAll('سُورَةُ', '')
            .trim();
        subtitle = 'من سورة $startSName (آية ${firstV.id}) إلى سورة $endSName (آية ${lastV.id})';
      }

      final section = QuranSectionModel(
        number: juzNumber,
        title: juzItem.name,
        subtitle: subtitle,
        verses: verses,
        surahsMap: surahsMap,
      );

      _cachedJuzDetails[juzNumber] = section;

      // Save to Hive for persistent offline access
      try {
        final encoded = jsonEncode(section.toJson());
        CacheHelper.saveData<String>(
          boxName: StorageConstants.quranBoxName,
          key: 'juz_detail_$juzNumber',
          value: encoded,
        );
      } catch (e) {
        debugPrint('Failed to save juz $juzNumber to persistent cache: $e');
      }

      prefetchAdjacentAjza(juzNumber);
      return section;
    } catch (e) {
      throw Exception('Failed to load Juz $juzNumber: $e');
    }
  }

  @override
  Future<QuranSectionModel> getHizbDetail(int hizbNumber) async {
    final cached = getCachedHizbDetail(hizbNumber);
    if (cached != null) {
      return cached;
    }

    try {
      final juzNumber = ((hizbNumber - 1) ~/ 2) + 1;
      final juzSection = await getJuzDetail(juzNumber);

      final startQuarter = (hizbNumber - 1) * 4 + 1;
      final endQuarter = hizbNumber * 4;

      final hizbVerses = juzSection.verses.where((v) {
        final hq = v.hizbQuarter;
        if (hq == null) return true;
        return hq >= startQuarter && hq <= endQuarter;
      }).toList();

      final hizbItem = HizbItem.ahzab[(hizbNumber - 1).clamp(0, HizbItem.ahzab.length - 1)];
      final firstVerse = hizbVerses.isNotEmpty ? hizbVerses.first : null;
      final startSurah = (firstVerse?.surahNameArabic != null && firstVerse!.surahNameArabic!.isNotEmpty)
          ? firstVerse.surahNameArabic!.replaceAll('سورة ', '').replaceAll('سُورَةُ ', '')
          : hizbItem.startSurahName;
      final startAyah = firstVerse?.id ?? hizbItem.startAyah;

      final section = QuranSectionModel(
        number: hizbNumber,
        title: hizbItem.name,
        subtitle: 'سورة $startSurah (آية $startAyah) • الجزء $juzNumber',
        verses: hizbVerses.isNotEmpty ? hizbVerses : juzSection.verses,
        surahsMap: juzSection.surahsMap,
      );

      _cachedHizbDetails[hizbNumber] = section;

      try {
        final encoded = jsonEncode(section.toJson());
        CacheHelper.saveData<String>(
          boxName: StorageConstants.quranBoxName,
          key: 'hizb_detail_v2_$hizbNumber',
          value: encoded,
        );
      } catch (_) {}

      return section;
    } catch (e) {
      throw Exception('Failed to load Hizb $hizbNumber: $e');
    }
  }

  @override
  void prefetchAdjacentAjza(int currentJuz) {
    final targets = <int>[];
    if (currentJuz < 30) targets.add(currentJuz + 1);
    if (currentJuz > 1) targets.add(currentJuz - 1);
    if (currentJuz + 2 <= 30) targets.add(currentJuz + 2);

    for (final j in targets) {
      if (!_cachedJuzDetails.containsKey(j) && !_activePrefetches.contains(j)) {
        if (getCachedJuzDetail(j) != null) continue;

        _activePrefetches.add(j);
        Future.delayed(const Duration(milliseconds: 400), () async {
          try {
            await getJuzDetail(j);
          } catch (_) {
          } finally {
            _activePrefetches.remove(j);
          }
        });
      }
    }
  }

  @override
  void prefetchAllAjzaInBackground() {
    if (_isBackgroundPrefetching) return;
    _isBackgroundPrefetching = true;

    Future(() async {
      for (int j = 1; j <= 30; j++) {
        if (getCachedJuzDetail(j) == null) {
          try {
            await getJuzDetail(j);
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (_) {
            // Silently continue
          }
        }
      }
      _isBackgroundPrefetching = false;
    });
  }

  @override
  void prefetchAdjacentSurahs(int currentSurahId) {
    final targets = <int>[];
    if (currentSurahId < 114) targets.add(currentSurahId + 1);
    if (currentSurahId > 1) targets.add(currentSurahId - 1);
    if (currentSurahId + 2 <= 114) targets.add(currentSurahId + 2);

    for (final sId in targets) {
      if (!_cachedSurahDetails.containsKey(sId) && !_activePrefetches.contains(sId + 1000)) {
        if (getCachedSurahById(sId) != null) continue;

        _activePrefetches.add(sId + 1000);
        Future.delayed(const Duration(milliseconds: 300), () async {
          try {
            await getSurahById(sId);
          } catch (_) {
          } finally {
            _activePrefetches.remove(sId + 1000);
          }
        });
      }
    }
  }

  @override
  void prefetchCommonSurahsInBackground() {
    Future(() async {
      // السور الأكثر قراءة والمطلوبة في الورد والصلوات (الفاتحة، الكهف، يس، الملك، وجزء عم كاملاً)
      final prioritySurahs = <int>[
        1, 2, 18, 36, 55, 56, 67,
        ...List.generate(37, (i) => 78 + i),
      ];

      for (final sId in prioritySurahs) {
        if (getCachedSurahById(sId) == null) {
          try {
            await getSurahById(sId);
            await Future.delayed(const Duration(milliseconds: 400));
          } catch (_) {}
        }
      }
    });
  }
}

