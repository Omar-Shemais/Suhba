class SurahModel {
  final int id;
  final String name;
  final String transliteration;
  final String translation;
  final String type;
  final int totalVerses;
  final List<VerseModel> verses;

  SurahModel({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.translation,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: ((json['id'] ?? json['number']) as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      transliteration: (json['transliteration'] ?? json['englishName'] ?? '') as String,
      translation: (json['translation'] ?? json['englishNameTranslation'] ?? '') as String,
      type: ((json['type'] ?? json['revelationType']) ?? 'meccan').toString().toLowerCase(),
      totalVerses: ((json['total_verses'] ?? json['numberOfAyahs']) as num?)?.toInt() ?? 0,
      verses: json['verses'] != null
          ? (json['verses'] as List<dynamic>)
              .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  factory SurahModel.fromApiSurah(
    Map<String, dynamic> json, [
    List<VerseModel>? verses,
  ]) {
    return SurahModel(
      id: (json['number'] as num).toInt(),
      name: json['name'] as String,
      transliteration: (json['englishName'] ?? '') as String,
      translation: (json['englishNameTranslation'] ?? '') as String,
      type: (json['revelationType'] ?? 'meccan').toString().toLowerCase(),
      totalVerses: ((json['numberOfAyahs'] ?? 0) as num).toInt(),
      verses: verses ?? [],
    );
  }

  factory SurahModel.fromApiEditions(List<dynamic> editions) {
    if (editions.isEmpty) {
      throw Exception('No edition data available');
    }

    final arabicData = editions.firstWhere(
      (e) => (e['edition']?['language'] ?? 'ar') == 'ar',
      orElse: () => editions[0],
    ) as Map<String, dynamic>;

    final dynamic englishData = editions.length > 1
        ? editions.firstWhere(
            (e) => (e['edition']?['language'] ?? '') == 'en',
            orElse: () => editions[1],
          )
        : null;

    final List<dynamic> arabicAyahs =
        (arabicData['ayahs'] as List<dynamic>?) ?? [];
    final List<dynamic> englishAyahs = englishData != null
        ? ((englishData['ayahs'] as List<dynamic>?) ?? [])
        : [];

    final verses = <VerseModel>[];
    for (int i = 0; i < arabicAyahs.length; i++) {
      final a = arabicAyahs[i] as Map<String, dynamic>;
      final enText = i < englishAyahs.length
          ? (englishAyahs[i]['text'] as String? ?? '')
          : '';
      verses.add(
        VerseModel(
          id: ((a['numberInSurah'] ?? (i + 1)) as num).toInt(),
          text: (a['text'] as String?)?.trim() ?? '',
          translation: enText.trim(),
        ),
      );
    }

    return SurahModel(
      id: (arabicData['number'] as num).toInt(),
      name: arabicData['name'] as String,
      transliteration: (arabicData['englishName'] ?? '') as String,
      translation: (arabicData['englishNameTranslation'] ?? '') as String,
      type: (arabicData['revelationType'] ?? 'meccan').toString().toLowerCase(),
      totalVerses: ((arabicData['numberOfAyahs'] ?? verses.length) as num).toInt(),
      verses: verses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'transliteration': transliteration,
      'translation': translation,
      'type': type,
      'total_verses': totalVerses,
      'verses': verses.map((v) => v.toJson()).toList(),
    };
  }
}

class VerseModel {
  final int id;
  final String text;
  final String translation;
  final int? surahId;
  final String? surahName;
  final String? surahNameArabic;
  final int? juz;
  final int? hizbQuarter;

  VerseModel({
    required this.id,
    required this.text,
    required this.translation,
    this.surahId,
    this.surahName,
    this.surahNameArabic,
    this.juz,
    this.hizbQuarter,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      id: ((json['id'] ?? json['numberInSurah'] ?? json['number']) as num?)?.toInt() ?? 0,
      text: (json['text'] as String?)?.trim() ?? '',
      translation: (json['translation'] as String?)?.trim() ?? '',
      surahId: (json['surahId'] as num?)?.toInt(),
      surahName: json['surahName'] as String?,
      surahNameArabic: json['surahNameArabic'] as String?,
      juz: (json['juz'] as num?)?.toInt(),
      hizbQuarter: (json['hizbQuarter'] as num?)?.toInt(),
    );
  }

  factory VerseModel.fromApiAyah(
    Map<String, dynamic> json, [
    String translation = '',
  ]) {
    final surahObj = json['surah'] as Map<String, dynamic>?;
    return VerseModel(
      id: ((json['numberInSurah'] ?? json['number']) as num?)?.toInt() ?? 0,
      text: (json['text'] as String?)?.trim() ?? '',
      translation: translation.trim(),
      surahId: surahObj != null ? (surahObj['number'] as num?)?.toInt() : (json['surahId'] as num?)?.toInt(),
      surahName: surahObj != null ? (surahObj['englishName'] as String?) : json['surahName'] as String?,
      surahNameArabic: surahObj != null ? (surahObj['name'] as String?) : json['surahNameArabic'] as String?,
      juz: (json['juz'] as num?)?.toInt(),
      hizbQuarter: (json['hizbQuarter'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'translation': translation,
      if (surahId != null) 'surahId': surahId,
      if (surahName != null) 'surahName': surahName,
      if (surahNameArabic != null) 'surahNameArabic': surahNameArabic,
      if (juz != null) 'juz': juz,
      if (hizbQuarter != null) 'hizbQuarter': hizbQuarter,
    };
  }
}

class QuranSectionModel {
  final int number;
  final String title;
  final String subtitle;
  final List<VerseModel> verses;
  final Map<int, SurahModel> surahsMap;

  QuranSectionModel({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.verses,
    required this.surahsMap,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'subtitle': subtitle,
      'verses': verses.map((v) => v.toJson()).toList(),
      'surahsMap': surahsMap.map((key, value) => MapEntry(key.toString(), value.toJson())),
    };
  }

  factory QuranSectionModel.fromJson(Map<String, dynamic> json) {
    final rawSurahs = json['surahsMap'] as Map<String, dynamic>? ?? {};
    final surahs = <int, SurahModel>{};
    rawSurahs.forEach((k, v) {
      final keyInt = int.tryParse(k);
      if (keyInt != null && v is Map<String, dynamic>) {
        surahs[keyInt] = SurahModel.fromJson(v);
      }
    });

    return QuranSectionModel(
      number: (json['number'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      verses: (json['verses'] as List<dynamic>? ?? [])
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      surahsMap: surahs,
    );
  }
}

