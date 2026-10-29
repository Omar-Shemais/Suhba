class AyahTafsirModel {
  final int id;
  final int sura;
  final int aya;
  final String arabicText;
  final String tafsirText;
  final String? footnotes;

  const AyahTafsirModel({
    required this.id,
    required this.sura,
    required this.aya,
    required this.arabicText,
    required this.tafsirText,
    this.footnotes,
  });

  factory AyahTafsirModel.fromJson(Map<String, dynamic> json) {
    return AyahTafsirModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      sura: int.tryParse(json['sura']?.toString() ?? '0') ?? 0,
      aya: int.tryParse(json['aya']?.toString() ?? '0') ?? 0,
      arabicText: json['arabic_text']?.toString() ?? '',
      tafsirText: json['translation']?.toString() ?? '',
      footnotes: json['footnotes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sura': sura,
      'aya': aya,
      'arabic_text': arabicText,
      'translation': tafsirText,
      'footnotes': footnotes,
    };
  }
}

class TafsirEdition {
  final String key;
  final String name;
  final String description;

  const TafsirEdition({
    required this.key,
    required this.name,
    required this.description,
  });

  static const List<TafsirEdition> availableEditions = [
    TafsirEdition(
      key: 'arabic_moyassar',
      name: 'التفسير الميسر',
      description: 'مجمع الملك فهد لطباعة المصحف الشريف',
    ),
    TafsirEdition(
      key: 'arabic_mokhtasar',
      name: 'المختصر في التفسير',
      description: 'مركز تفسير للدراسات القرآنية',
    ),
  ];
}
