class SibhaModel {
  final String nameAr;
  final String nameEn;
  final String meaningEn;

  SibhaModel({
    required this.nameAr,
    required this.nameEn,
    required this.meaningEn,
  });

  factory SibhaModel.fromJson(Map<String, dynamic> json) {
    return SibhaModel(
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      meaningEn: json['meaning_en'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_ar': nameAr,
      'name_en': nameEn,
      'meaning_en': meaningEn,
    };
  }
}
