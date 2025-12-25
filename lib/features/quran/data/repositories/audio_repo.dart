import 'dart:convert';
import 'package:flutter/services.dart';
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

  // ✅ تحميل بيانات الراديو من JSON
  Future<List<RadioStationModel>> _loadRadioData() async {
    if (_cachedRadios != null) return _cachedRadios!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/radio_stations.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      _cachedRadios = jsonData
          .map((json) => RadioStationModel.fromJson(json))
          .toList();
      return _cachedRadios!;
    } catch (e) {
      throw Exception('Failed to load radio data: $e');
    }
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
