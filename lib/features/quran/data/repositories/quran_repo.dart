import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quran_models.dart';

abstract class QuranRepository {
  Future<List<SurahModel>> getAllSurahs();
  Future<SurahModel> getSurahById(int id);
  Future<List<SurahModel>> searchSurahs(String query);
}

class QuranRepositoryImpl implements QuranRepository {
  List<SurahModel>? _cachedSurahs;

  Future<List<SurahModel>> _loadQuranData() async {
    if (_cachedSurahs != null) return _cachedSurahs!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/quran_en.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      _cachedSurahs = jsonData
          .map((json) => SurahModel.fromJson(json))
          .toList();
      return _cachedSurahs!;
    } catch (e) {
      throw Exception('Failed to load Quran data: $e');
    }
  }

  @override
  Future<List<SurahModel>> getAllSurahs() async {
    return await _loadQuranData();
  }

  @override
  Future<SurahModel> getSurahById(int id) async {
    final surahs = await _loadQuranData();
    return surahs.firstWhere(
      (surah) => surah.id == id,
      orElse: () => throw Exception('Surah not found'),
    );
  }

  @override
  Future<List<SurahModel>> searchSurahs(String query) async {
    final surahs = await _loadQuranData();
    final lowerQuery = query.toLowerCase();

    return surahs.where((surah) {
      return surah.name.toLowerCase().contains(lowerQuery) ||
          surah.transliteration.toLowerCase().contains(lowerQuery) ||
          surah.translation.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
