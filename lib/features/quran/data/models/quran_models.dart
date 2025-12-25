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
      id: json['id'] as int,
      name: json['name'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      type: json['type'] as String,
      totalVerses: json['total_verses'] as int,
      verses: (json['verses'] as List<dynamic>)
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
          .toList(),
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
      id: json['id'] as int,
      text: json['text'] as String,
      translation: json['translation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'translation': translation};
  }
}
