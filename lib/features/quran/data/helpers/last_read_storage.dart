import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LastReadManager {
  static const String _keySurahId = 'quran_last_read_surah_id';
  static const String _keyAyahNumber = 'quran_last_read_ayah_number';
  static const String _keySurahName = 'quran_last_read_surah_name';
  static const String _keySurahNameArabic = 'quran_last_read_surah_name_arabic';

  // 🔥 إشعار عند التحديث
  static final ValueNotifier<bool> lastReadUpdated = ValueNotifier(false);

  // ذاكرة مؤقتة فائقة السرعة تمنع القراءة من القرص أثناء التمرير (O(1) in-memory cache)
  static LastReadModel? _cachedLastRead;

  /// فحص فوري وسريع لمعرفة إن كانت الآية هي آخر قراءة
  static bool isAyahLastRead(int surahId, int ayahNumber) {
    if (_cachedLastRead == null || _cachedLastRead!.isDefault) {
      return false;
    }
    return _cachedLastRead!.surahId == surahId &&
        _cachedLastRead!.ayahNumber == ayahNumber;
  }

  // ✅ حفظ آخر قراءة
  static Future<void> saveLastRead({
    required int surahId,
    required int ayahNumber,
    required String surahName,
    required String surahNameArabic,
  }) async {
    _cachedLastRead = LastReadModel(
      surahId: surahId,
      ayahNumber: ayahNumber,
      surahName: surahName,
      surahNameArabic: surahNameArabic,
      isDefault: false,
    );

    // 🔔 نحدث المستمعين فوراً
    lastReadUpdated.value = !lastReadUpdated.value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySurahId, surahId);
    await prefs.setInt(_keyAyahNumber, ayahNumber);
    await prefs.setString(_keySurahName, surahName);
    await prefs.setString(_keySurahNameArabic, surahNameArabic);
  }

  // ✅ استرجاع آخر قراءة (مع قيمة افتراضية - الفاتحة)
  static Future<LastReadModel> getLastRead() async {
    if (_cachedLastRead != null) {
      return _cachedLastRead!;
    }

    final prefs = await SharedPreferences.getInstance();
    final surahId = prefs.getInt(_keySurahId);
    final ayahNumber = prefs.getInt(_keyAyahNumber);
    final surahName = prefs.getString(_keySurahName);
    final surahNameArabic = prefs.getString(_keySurahNameArabic);

    if (surahId == null || ayahNumber == null) {
      _cachedLastRead = LastReadModel(
        surahId: 1,
        ayahNumber: 1,
        surahName: 'Al-Fatihah',
        surahNameArabic: 'سُورَةُ ٱلْفَاتِحَةِ',
        isDefault: true,
      );
    } else {
      _cachedLastRead = LastReadModel(
        surahId: surahId,
        ayahNumber: ayahNumber,
        surahName: surahName ?? 'Al-Fatihah',
        surahNameArabic: surahNameArabic ?? 'سُورَةُ ٱلْفَاتِحَةِ',
        isDefault: false,
      );
    }
    return _cachedLastRead!;
  }

  // ✅ مسح آخر قراءة
  static Future<void> clearLastRead() async {
    _cachedLastRead = null;
    lastReadUpdated.value = !lastReadUpdated.value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySurahId);
    await prefs.remove(_keyAyahNumber);
    await prefs.remove(_keySurahName);
    await prefs.remove(_keySurahNameArabic);
  }

  // ✅ التحقق من وجود آخر قراءة
  static Future<bool> hasLastRead() async {
    if (_cachedLastRead != null) {
      return !_cachedLastRead!.isDefault;
    }
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
