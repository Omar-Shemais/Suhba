import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_app/core/constants/api_constance.dart';
import 'package:islamic_app/core/network/dio_client.dart';
import '../models/audio_model.dart';

abstract class AudioRepository {
  Future<List<ReciterModel>> getAllReciters();
  Future<ReciterModel> getReciterById(int id);
  Future<List<RadioStationModel>> getRadioStations();
  Future<String> getAudioUrl(int reciterId, int surahNumber);
  Future<String> getAyahAudioUrl(
    int reciterId,
    int surahNumber,
    int ayahNumber,
  );
}

class AudioRepositoryImpl implements AudioRepository {
  List<ReciterModel>? _cachedReciters;
  List<RadioStationModel>? _cachedRadios;

  // ✅ تحميل بيانات القراء من JSON
  Future<List<ReciterModel>> _loadRecitersData() async {
    if (_cachedReciters != null) return _cachedReciters!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/reciters.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      _cachedReciters = jsonData
          .map((json) => ReciterModel.fromJson(json))
          .toList();
      return _cachedReciters!;
    } catch (e) {
      throw Exception('Failed to load reciters data: $e');
    }
  }

  // ✅ تحميل بيانات الراديو المفلترة والمصنفة (عربي فقط - قرآن 15، أحاديث 15، أذكار، أدعية 15)
  Future<List<RadioStationModel>> _loadRadioData() async {
    if (_cachedRadios != null && _cachedRadios!.isNotEmpty) {
      return _cachedRadios!;
    }

    // 1. تحميل القائمة المحلية المنسقة والمحققة مسبقاً (فورية وبدون إنترنت)
    List<RadioStationModel> localStations = [];
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/radio_stations.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      localStations = jsonData
          .map((item) => RadioStationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {}

    if (localStations.isNotEmpty) {
      _cachedRadios = localStations;
      return _cachedRadios!;
    }

    // 2. Fallback: جلب البيانات من MP3Quran API v3 مع فلترة صارمة للمحتوى العربي
    try {
      final response = await DioClient.getData(
        endPoint: ApiConstance.mp3QuranRadios,
      );
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is String
            ? json.decode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;
        final List<dynamic> radiosList = data['radios'] as List<dynamic>? ?? [];
        if (radiosList.isNotEmpty) {
          // استبعاد أي إذاعة ليست باللغة العربية (ترجمات اللغات الأجنبية)
          final arabicList = radiosList.where((item) {
            final name = (item['name'] ?? '').toString();
            final url = (item['url'] ?? '').toString().toLowerCase();
            return !name.contains('ترجمة') && !url.contains('translation');
          }).toList();

          _cachedRadios = arabicList
              .map((item) => RadioStationModel.fromJson(item as Map<String, dynamic>))
              .toList();
          return _cachedRadios!;
        }
      }
    } catch (_) {}

    return localStations;
  }

  @override
  Future<List<ReciterModel>> getAllReciters() async {
    return await _loadRecitersData();
  }

  @override
  Future<ReciterModel> getReciterById(int id) async {
    final reciters = await _loadRecitersData();
    return reciters.firstWhere(
      (reciter) => reciter.id == id,
      orElse: () => throw Exception('Reciter not found'),
    );
  }

  @override
  Future<List<RadioStationModel>> getRadioStations() async {
    return await _loadRadioData();
  }

  @override
  Future<String> getAudioUrl(int reciterId, int surahNumber) async {
    final reciter = await getReciterById(reciterId);
    return reciter.getAudioUrl(surahNumber);
  }

  // ✅ دالة للحصول على رابط صوت الآية
  @override
  Future<String> getAyahAudioUrl(
    int reciterId,
    int surahNumber,
    int ayahNumber,
  ) async {
    final reciter = await getReciterById(reciterId);
    return reciter.getAyahAudioUrl(surahNumber, ayahNumber);
  }
}
