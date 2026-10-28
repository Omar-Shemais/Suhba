import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/khatmah_model.dart';

class JuzMetaInfo {
  final int number;
  final String startSurah;
  final int startAyah;
  final String endSurah;
  final int endAyah;
  final int startPage;
  final int endPage;

  const JuzMetaInfo({
    required this.number,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.startPage,
    required this.endPage,
  });

  /// نص دقيق يحدد البداية والنهاية بالسورة والآية
  String get rangeDescription =>
      'من سورة $startSurah (آية $startAyah) إلى سورة $endSurah (آية $endAyah)';
}

class KhatmahManager {
  static const String _keyActiveKhatmah = 'active_quran_khatmah_v1';

  static Future<KhatmahModel?> getActiveKhatmah() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyActiveKhatmah);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return KhatmahModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveKhatmah(KhatmahModel khatmah) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(khatmah.toJson());
    await prefs.setString(_keyActiveKhatmah, jsonStr);
  }

  static Future<void> deleteKhatmah() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveKhatmah);
  }

  static Future<KhatmahModel?> toggleJuz(int juzNumber) async {
    final active = await getActiveKhatmah();
    if (active == null) return null;

    final completed = List<int>.from(active.completedJuz);
    if (completed.contains(juzNumber)) {
      completed.remove(juzNumber);
    } else {
      completed.add(juzNumber);
    }
    completed.sort();

    final isAllDone = completed.length >= 30;
    final updated = active.copyWith(
      completedJuz: completed,
      currentJuz: completed.isEmpty ? 1 : (completed.last < 30 ? completed.last + 1 : 30),
      isCompleted: isAllDone,
    );

    await saveKhatmah(updated);
    return updated;
  }

  static Future<KhatmahModel?> markJuzDone(int juzNumber) async {
    final active = await getActiveKhatmah();
    if (active == null) return null;

    final completed = List<int>.from(active.completedJuz);
    if (!completed.contains(juzNumber)) {
      completed.add(juzNumber);
      completed.sort();
    }

    final isAllDone = completed.length >= 30;
    final updated = active.copyWith(
      completedJuz: completed,
      isCompleted: isAllDone,
    );

    await saveKhatmah(updated);
    return updated;
  }

  static Future<KhatmahModel?> unmarkJuzDone(int juzNumber) async {
    final active = await getActiveKhatmah();
    if (active == null) return null;

    final completed = List<int>.from(active.completedJuz);
    completed.remove(juzNumber);
    completed.sort();

    final updated = active.copyWith(
      completedJuz: completed,
      isCompleted: false,
    );

    await saveKhatmah(updated);
    return updated;
  }

  static Future<KhatmahModel?> markTodayPortionDone() async {
    final active = await getActiveKhatmah();
    if (active == null) return null;

    final targetJuz = active.targetJuzForToday;
    return markJuzDone(targetJuz);
  }

  /// معلومات الأجزاء الـ 30 مع أسماء السور وأرقام الآيات والصفحات بدقة
  static final List<JuzMetaInfo> juzList = [
    const JuzMetaInfo(number: 1, startSurah: 'الفاتحة', startAyah: 1, endSurah: 'البقرة', endAyah: 141, startPage: 1, endPage: 21),
    const JuzMetaInfo(number: 2, startSurah: 'البقرة', startAyah: 142, endSurah: 'البقرة', endAyah: 252, startPage: 22, endPage: 41),
    const JuzMetaInfo(number: 3, startSurah: 'البقرة', startAyah: 253, endSurah: 'آل عمران', endAyah: 92, startPage: 42, endPage: 61),
    const JuzMetaInfo(number: 4, startSurah: 'آل عمران', startAyah: 93, endSurah: 'النساء', endAyah: 23, startPage: 62, endPage: 81),
    const JuzMetaInfo(number: 5, startSurah: 'النساء', startAyah: 24, endSurah: 'النساء', endAyah: 147, startPage: 82, endPage: 101),
    const JuzMetaInfo(number: 6, startSurah: 'النساء', startAyah: 148, endSurah: 'المائدة', endAyah: 81, startPage: 102, endPage: 121),
    const JuzMetaInfo(number: 7, startSurah: 'المائدة', startAyah: 82, endSurah: 'الأنعام', endAyah: 110, startPage: 122, endPage: 141),
    const JuzMetaInfo(number: 8, startSurah: 'الأنعام', startAyah: 111, endSurah: 'الأعراف', endAyah: 87, startPage: 142, endPage: 161),
    const JuzMetaInfo(number: 9, startSurah: 'الأعراف', startAyah: 88, endSurah: 'الأنفال', endAyah: 40, startPage: 162, endPage: 181),
    const JuzMetaInfo(number: 10, startSurah: 'الأنفال', startAyah: 41, endSurah: 'التوبة', endAyah: 92, startPage: 182, endPage: 201),
    const JuzMetaInfo(number: 11, startSurah: 'التوبة', startAyah: 93, endSurah: 'هود', endAyah: 5, startPage: 202, endPage: 221),
    const JuzMetaInfo(number: 12, startSurah: 'هود', startAyah: 6, endSurah: 'يوسف', endAyah: 52, startPage: 222, endPage: 241),
    const JuzMetaInfo(number: 13, startSurah: 'يوسف', startAyah: 53, endSurah: 'إبراهيم', endAyah: 52, startPage: 242, endPage: 261),
    const JuzMetaInfo(number: 14, startSurah: 'الحجر', startAyah: 1, endSurah: 'النحل', endAyah: 128, startPage: 262, endPage: 281),
    const JuzMetaInfo(number: 15, startSurah: 'الإسراء', startAyah: 1, endSurah: 'الكهف', endAyah: 74, startPage: 282, endPage: 301),
    const JuzMetaInfo(number: 16, startSurah: 'الكهف', startAyah: 75, endSurah: 'طه', endAyah: 135, startPage: 302, endPage: 321),
    const JuzMetaInfo(number: 17, startSurah: 'الأنبياء', startAyah: 1, endSurah: 'الحج', endAyah: 78, startPage: 322, endPage: 341),
    const JuzMetaInfo(number: 18, startSurah: 'المؤمنون', startAyah: 1, endSurah: 'الفرقان', endAyah: 20, startPage: 342, endPage: 361),
    const JuzMetaInfo(number: 19, startSurah: 'الفرقان', startAyah: 21, endSurah: 'النمل', endAyah: 55, startPage: 362, endPage: 381),
    const JuzMetaInfo(number: 20, startSurah: 'النمل', startAyah: 56, endSurah: 'العنكبوت', endAyah: 45, startPage: 382, endPage: 401),
    const JuzMetaInfo(number: 21, startSurah: 'العنكبوت', startAyah: 46, endSurah: 'الأحزاب', endAyah: 30, startPage: 402, endPage: 421),
    const JuzMetaInfo(number: 22, startSurah: 'الأحزاب', startAyah: 31, endSurah: 'يس', endAyah: 27, startPage: 422, endPage: 441),
    const JuzMetaInfo(number: 23, startSurah: 'يس', startAyah: 28, endSurah: 'الزمر', endAyah: 31, startPage: 442, endPage: 461),
    const JuzMetaInfo(number: 24, startSurah: 'الزمر', startAyah: 32, endSurah: 'فصلت', endAyah: 46, startPage: 462, endPage: 481),
    const JuzMetaInfo(number: 25, startSurah: 'فصلت', startAyah: 47, endSurah: 'الجاثية', endAyah: 37, startPage: 482, endPage: 501),
    const JuzMetaInfo(number: 26, startSurah: 'الأحقاف', startAyah: 1, endSurah: 'الذاريات', endAyah: 30, startPage: 502, endPage: 521),
    const JuzMetaInfo(number: 27, startSurah: 'الذاريات', startAyah: 31, endSurah: 'الحديد', endAyah: 29, startPage: 522, endPage: 541),
    const JuzMetaInfo(number: 28, startSurah: 'المجادلة', startAyah: 1, endSurah: 'التحريم', endAyah: 12, startPage: 542, endPage: 561),
    const JuzMetaInfo(number: 29, startSurah: 'الملك', startAyah: 1, endSurah: 'المرسلات', endAyah: 50, startPage: 562, endPage: 581),
    const JuzMetaInfo(number: 30, startSurah: 'النبأ', startAyah: 1, endSurah: 'الناس', endAyah: 6, startPage: 582, endPage: 604),
  ];

  static JuzMetaInfo getJuz(int number) {
    if (number < 1 || number > 30) return juzList[0];
    return juzList[number - 1];
  }
}
