import 'package:islamic_app/core/constants/api_constance.dart';
import 'package:islamic_app/core/network/dio_client.dart';
import '../models/quran_models.dart';

abstract class QuranRepository {
  Future<List<SurahModel>> getAllSurahs();
  Future<SurahModel> getSurahById(int id);
  Future<List<SurahModel>> searchSurahs(String query);
}

class QuranRepositoryImpl implements QuranRepository {
  List<SurahModel>? _cachedSurahs;
  final Map<int, SurahModel> _cachedSurahDetails = {};

  @override
  Future<List<SurahModel>> getAllSurahs() async {
    if (_cachedSurahs != null && _cachedSurahs!.isNotEmpty) {
      return _cachedSurahs!;
    }

    try {
      final response = await DioClient.getData(
        endPoint: '${ApiConstance.quranBaseUrl}${ApiConstance.surah}',
      );

      final List<dynamic> jsonData = response.data['data'] as List<dynamic>;
      _cachedSurahs = jsonData
          .map((json) => SurahModel.fromApiSurah(json as Map<String, dynamic>))
          .toList();
      return _cachedSurahs!;
    } catch (e) {
      throw Exception('Failed to load Quran surahs: $e');
    }
  }

  @override
  Future<SurahModel> getSurahById(int id) async {
    if (_cachedSurahDetails.containsKey(id) &&
        _cachedSurahDetails[id]!.verses.isNotEmpty) {
      return _cachedSurahDetails[id]!;
    }

    try {
      final response = await DioClient.getData(
        endPoint:
            '${ApiConstance.quranBaseUrl}${ApiConstance.surah}/$id/editions/quran-uthmani,en.sahih',
      );

      final editions = response.data['data'] as List<dynamic>;
      final surah = SurahModel.fromApiEditions(editions);
      _cachedSurahDetails[id] = surah;
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
}

