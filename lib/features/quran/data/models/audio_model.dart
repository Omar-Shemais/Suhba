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
    if (baseUrl.isNotEmpty && subfolder.isNotEmpty) {
      return '$baseUrl/$subfolder/$surahCode.mp3';
    }
    return 'https://cdn.mp3quran.net/audio/mishary-alafasy/r1/$surahCode.mp3';
  }

  String getAyahAudioUrl(int surahNumber, int ayahNumber) {
    final sCode = surahNumber.toString().padLeft(3, '0');
    final aCode = ayahNumber.toString().padLeft(3, '0');
    final folder = _getEveryAyahFolder();
    return 'https://everyayah.com/data/$folder/$sCode$aCode.mp3';
  }

  String _getEveryAyahFolder() {
    switch (id) {
      case 1:
        return 'Alafasy_128kbps';
      case 2:
        return 'Abdul_Basit_Murattal_192kbps';
      case 3:
        return 'Ghamadi_40kbps';
      case 4:
        return 'MaherAlMuaiqly128kbps';
      case 5:
        return 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net';
      default:
        return 'Alafasy_128kbps';
    }
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
        return 'ar.abdulbasitmurattal';
      case 3:
        return 'ar.saadalghamidi';
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
  final String category; // 'quran', 'hadith', 'azkar'

  RadioStationModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.url,
    this.recentDate,
    this.category = 'quran',
  });

  factory RadioStationModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final arabicName = json['arabic_name'] as String? ?? name;
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final category = json['category'] as String? ?? _inferCategory(name, arabicName, id);

    return RadioStationModel(
      id: id,
      name: name,
      arabicName: arabicName,
      url: json['url'] as String? ?? '',
      recentDate: json['recent_date'] as String?,
      category: category,
    );
  }

  static String _inferCategory(String name, String arabicName, int id) {
    final text = '$name $arabicName'.toLowerCase();
    if (text.contains('سيد رمضان')) {
      return 'quran';
    }
    if (text.contains('الصباح') ||
        text.contains('المساء') ||
        text.contains('الرقية') ||
        text.contains('رقية')) {
      return 'azkar';
    }
    if (text.contains('بخاري') ||
        text.contains('مسلم') ||
        text.contains('حديث') ||
        text.contains('سنة') ||
        text.contains('سيرة') ||
        text.contains('رياض الصالحين') ||
        text.contains('الشمائل') ||
        text.contains('الصحابة') ||
        text.contains('أنبياء') ||
        text.contains('فقه') ||
        text.contains('فتاوى') ||
        text.contains('تفسير') ||
        text.contains('شهر رمضان') ||
        text.contains('فضائل رمضان')) {
      return 'hadith';
    }
    return 'quran';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic_name': arabicName,
      'url': url,
      'recent_date': recentDate,
      'category': category,
    };
  }
}
