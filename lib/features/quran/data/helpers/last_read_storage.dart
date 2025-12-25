import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LastReadManager {
  static const String _keySurahId = 'quran_last_read_surah_id';
  static const String _keyAyahNumber = 'quran_last_read_ayah_number';
  static const String _keySurahName = 'quran_last_read_surah_name';
  static const String _keySurahNameArabic = 'quran_last_read_surah_name_arabic';

  // 🔥 إشعار عند التحديث
  static final ValueNotifier<bool> lastReadUpdated = ValueNotifier(false);

  // ✅ حفظ آخر قراءة
  static Future<void> saveLastRead({
    required int surahId,
    required int ayahNumber,
    required String surahName,
    required String surahNameArabic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySurahId, surahId);
    await prefs.setInt(_keyAyahNumber, ayahNumber);
    await prefs.setString(_keySurahName, surahName);
    await prefs.setString(_keySurahNameArabic, surahNameArabic);

    // 🔔 نحدث المستمعين
    lastReadUpdated.value = !lastReadUpdated.value;
  }

  // ✅ استرجاع آخر قراءة (مع قيمة افتراضية - الفاتحة)
  static Future<LastReadModel> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surahId = prefs.getInt(_keySurahId);
    final ayahNumber = prefs.getInt(_keyAyahNumber);
    final surahName = prefs.getString(_keySurahName);
    final surahNameArabic = prefs.getString(_keySurahNameArabic);

    if (surahId == null || ayahNumber == null) {
      return LastReadModel(
        surahId: 1,
        ayahNumber: 1,
        surahName: 'Al-Fatihah',
        surahNameArabic: 'سُورَةُ ٱلْفَاتِحَةِ',
        isDefault: true,
      );
    }

    return LastReadModel(
      surahId: surahId,
      ayahNumber: ayahNumber,
      surahName: surahName ?? 'Al-Fatihah',
      surahNameArabic: surahNameArabic ?? 'سُورَةُ ٱلْفَاتِحَةِ',
      isDefault: false,
    );
  }

  // ✅ مسح آخر قراءة
  static Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySurahId);
    await prefs.remove(_keyAyahNumber);
    await prefs.remove(_keySurahName);
    await prefs.remove(_keySurahNameArabic);
  }

  // ✅ التحقق من وجود آخر قراءة
  static Future<bool> hasLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keySurahId);
  }
}

class LastReadModel {
  final int surahId;
  final int ayahNumber;
  final String surahName;
  final String surahNameArabic;
  final bool isDefault;

  LastReadModel({
    required this.surahId,
    required this.ayahNumber,
    required this.surahName,
    required this.surahNameArabic,
    this.isDefault = false,
  });
}
