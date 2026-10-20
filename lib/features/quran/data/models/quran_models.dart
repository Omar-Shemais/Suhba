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
      id: (json['id'] ?? json['number']) as int,
      name: json['name'] as String,
      transliteration: (json['transliteration'] ?? json['englishName'] ?? '') as String,
      translation: (json['translation'] ?? json['englishNameTranslation'] ?? '') as String,
      type: ((json['type'] ?? json['revelationType']) ?? 'meccan').toString().toLowerCase(),
      totalVerses: (json['total_verses'] ?? json['numberOfAyahs'] ?? 0) as int,
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
      id: json['number'] as int,
      name: json['name'] as String,
      transliteration: json['englishName'] as String,
      translation: json['englishNameTranslation'] as String,
      type: (json['revelationType'] ?? 'meccan').toString().toLowerCase(),
      totalVerses: json['numberOfAyahs'] as int,
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
          id: (a['numberInSurah'] ?? (i + 1)) as int,
          text: (a['text'] as String?)?.trim() ?? '',
          translation: enText.trim(),
        ),
      );
    }

    return SurahModel(
      id: arabicData['number'] as int,
      name: arabicData['name'] as String,
      transliteration: arabicData['englishName'] as String,
      translation: arabicData['englishNameTranslation'] as String,
      type: (arabicData['revelationType'] ?? 'meccan').toString().toLowerCase(),
      totalVerses: (arabicData['numberOfAyahs'] ?? verses.length) as int,
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

  VerseModel({required this.id, required this.text, required this.translation});

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      id: (json['id'] ?? json['numberInSurah']) as int,
      text: json['text'] as String,
      translation: (json['translation'] ?? '') as String,
    );
  }

  factory VerseModel.fromApiAyah(
    Map<String, dynamic> json, [
    String translation = '',
  ]) {
    return VerseModel(
      id: (json['numberInSurah'] ?? json['number']) as int,
      text: (json['text'] as String?)?.trim() ?? '',
      translation: translation.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'translation': translation};
  }
}

