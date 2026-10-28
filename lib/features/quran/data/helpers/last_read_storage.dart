import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LastReadManager {
  static const String _keySurahId = 'quran_last_read_surah_id';
  static const String _keyAyahNumber = 'quran_last_read_ayah_number';
  static const String _keySurahName = 'quran_last_read_surah_name';
  static const String _keySurahNameArabic = 'quran_last_read_surah_name_arabic';
  static const String _keyTotalVerses = 'quran_last_read_total_verses';

  // 🔥 إشعار فوري عند التحديث
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
    int? totalVerses,
  }) async {
    final tVerses = totalVerses ?? (_cachedLastRead?.surahId == surahId ? _cachedLastRead!.totalVerses : 286);
    
    // حفظ في القرص أولاً لضمان عدم حدوث سباق زمني عند قراءة المستمعين
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySurahId, surahId);
    await prefs.setInt(_keyAyahNumber, ayahNumber);
    await prefs.setString(_keySurahName, surahName);
    await prefs.setString(_keySurahNameArabic, surahNameArabic);
    await prefs.setInt(_keyTotalVerses, tVerses);

    // تحديث الكاش بالقيم الجديدة
    _cachedLastRead = LastReadModel(
      surahId: surahId,
      ayahNumber: ayahNumber,
      surahName: surahName,
      surahNameArabic: surahNameArabic,
      totalVerses: tVerses,
      isDefault: false,
    );

    // 🔔 نحدث المستمعين فوراً بعد اكتمال الحفظ لضمان اتساق البيانات
    lastReadUpdated.value = !lastReadUpdated.value;
  }

  // ✅ استرجاع آخر قراءة
  static Future<LastReadModel> getLastRead({bool forceReload = false}) async {
    if (!forceReload && _cachedLastRead != null) {
      return _cachedLastRead!;
    }

    final prefs = await SharedPreferences.getInstance();
    final surahId = prefs.getInt(_keySurahId);
    final ayahNumber = prefs.getInt(_keyAyahNumber);
    final surahName = prefs.getString(_keySurahName);
    final surahNameArabic = prefs.getString(_keySurahNameArabic);
    final totalVerses = prefs.getInt(_keyTotalVerses);

    if (surahId == null || ayahNumber == null) {
      _cachedLastRead = LastReadModel(
        surahId: 2,
        ayahNumber: 1,
        surahName: 'Al-Baqarah',
        surahNameArabic: 'سورة البقرة',
        totalVerses: 286,
        isDefault: true,
      );
    } else {
      _cachedLastRead = LastReadModel(
        surahId: surahId,
        ayahNumber: ayahNumber,
        surahName: surahName ?? 'Al-Baqarah',
        surahNameArabic: surahNameArabic ?? 'سورة البقرة',
        totalVerses: totalVerses ?? 286,
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
    await prefs.remove(_keyTotalVerses);
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
  final int totalVerses;
  final bool isDefault;

  LastReadModel({
    required this.surahId,
    required this.ayahNumber,
    required this.surahName,
    required this.surahNameArabic,
    this.totalVerses = 286,
    this.isDefault = false,
  });
}
