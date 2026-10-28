class AzkarModel {
  String title;
  List<ZekrItem> azkar;

  AzkarModel({required this.title, required this.azkar});

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      title: json['title'] ?? '',
      azkar: (json['content'] as List<dynamic>).map((zekr) {
        return ZekrItem.fromJson(zekr);
      }).toList(),
    );
  }
}

class ZekrItem {
  String zekr;
  int repeat;
  String bless;

  ZekrItem({required this.zekr, required this.repeat, required this.bless});

  factory ZekrItem.fromJson(Map<String, dynamic> json) {
    return ZekrItem(
      zekr: json['zekr'] ?? '',
      repeat: json['repeat'] ?? 1,
      bless: json['bless'] ?? '',
    );
  }
}
