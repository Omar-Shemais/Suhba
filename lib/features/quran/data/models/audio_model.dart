class ReciterModel {
  final int id;
  final String name;
  final String arabicName;
  final String baseUrl;
  final String subfolder;
  final int bitrate;
  final List<String> availableSurahs;

  ReciterModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.baseUrl,
    required this.subfolder,
    required this.bitrate,
    required this.availableSurahs,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      arabicName: json['arabic_name'] as String,
      baseUrl: json['base_url'] as String,
      subfolder: json['subfolder'] as String,
      bitrate: json['bitrate'] as int? ?? 128,
      availableSurahs:
          (json['available_surahs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          List.generate(114, (index) => (index + 1).toString().padLeft(3, '0')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic_name': arabicName,
      'base_url': baseUrl,
      'subfolder': subfolder,
      'bitrate': bitrate,
      'available_surahs': availableSurahs,
    };
  }

  String getAudioUrl(int surahNumber) {
    final surahCode = surahNumber.toString().padLeft(3, '0');
    return '$baseUrl/$subfolder/$surahCode.mp3';
  }

  String getAyahAudioUrl(int surahNumber, int ayahNumber) {
    final reciterCode = _getReciterCode();
    final ayahGlobalNumber = _calculateGlobalAyahNumber(
      surahNumber,
      ayahNumber,
    );
    return 'https://cdn.islamic.network/quran/audio/128/$reciterCode/$ayahGlobalNumber.mp3';
  }

  int _calculateGlobalAyahNumber(int surahNumber, int ayahInSurah) {
    final ayahsBeforeSurah = _getAyahsBeforeSurah(surahNumber);
    return ayahsBeforeSurah + ayahInSurah;
  }

  int _getAyahsBeforeSurah(int surahNumber) {
    const List<int> ayahCounts = [
      7,
      286,
      200,
      176,
      120,
      165,
      206,
      75,
      129,
      109,
      123,
      111,
      43,
      52,
      99,
      128,
      111,
      110,
      98,
      135,
      112,
      78,
      118,
      64,
      77,
      227,
      93,
      88,
      69,
      60,
      34,
      30,
      73,
      54,
      45,
      83,
      182,
      88,
      75,
      85,
      54,
      53,
      89,
      59,
      37,
      35,
      38,
      29,
      18,
      45,
      60,
      49,
      62,
      55,
      78,
      96,
      29,
      22,
      24,
      13,
      14,
      11,
      11,
      18,
      12,
      12,
      30,
      52,
      52,
      44,
      28,
      28,
      20,
      56,
      40,
      31,
      50,
      40,
      46,
      42,
      29,
      19,
      36,
      25,
      22,
      17,
      19,
      26,
      30,
      20,
      15,
      21,
      11,
      8,
      8,
      19,
      5,
      8,
      8,
      11,
      11,
      8,
      3,
      9,
      5,
      4,
      7,
      3,
      6,
      3,
      5,
      4,
      5,
      6,
    ];

    int total = 0;
    for (int i = 0; i < surahNumber - 1; i++) {
      total += ayahCounts[i];
    }
    return total;
  }

  String _getReciterCode() {
    switch (id) {
      case 1:
        return 'ar.alafasy';
      case 2:
        return 'ar.alafasy';
      case 3:
        return 'ar.alafasy';
      case 4:
        return 'ar.mahermuaiqly';
      case 5:
        return 'ar.ahmedajamy';
      default:
        return 'ar.alafasy';
    }
  }
}

class RadioStationModel {
  final int id;
  final String name;
  final String arabicName;
  final String url;
  final String? recentDate;

  RadioStationModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.url,
    this.recentDate,
  });

  factory RadioStationModel.fromJson(Map<String, dynamic> json) {
    return RadioStationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      arabicName: json['arabic_name'] as String,
      url: json['url'] as String,
      recentDate: json['recent_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic_name': arabicName,
      'url': url,
      'recent_date': recentDate,
    };
  }
}
