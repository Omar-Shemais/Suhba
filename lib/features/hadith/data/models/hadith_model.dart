class HadithModel {
  final int id;
  final String hadithArabic;
  final String hadithEnglish;
  final String? englishNarrator;
  final String? arabicNarrator;
  final String bookSlug;
  final int volume;
  final int hadithNumber;

  HadithModel({
    required this.id,
    required this.hadithArabic,
    required this.hadithEnglish,
    this.englishNarrator,
    this.arabicNarrator,
    required this.bookSlug,
    required this.volume,
    required this.hadithNumber,
  });

  // ⭐ دالة مساعدة لتحويل أي نوع لـ int
  static int _parseIntFromDynamic(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: _parseIntFromDynamic(json['id']),
      hadithArabic: json['hadithArabic'] ?? '',
      hadithEnglish: json['hadithEnglish'] ?? '',
      englishNarrator: json['englishNarrator'],
      arabicNarrator: json['arabicNarrator'],
      bookSlug: json['bookSlug'] ?? '',
      volume: _parseIntFromDynamic(json['volume']),
      hadithNumber: _parseIntFromDynamic(json['hadithNumber']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hadithArabic': hadithArabic,
      'hadithEnglish': hadithEnglish,
      'englishNarrator': englishNarrator,
      'arabicNarrator': arabicNarrator,
      'bookSlug': bookSlug,
      'volume': volume,
      'hadithNumber': hadithNumber,
    };
  }
}

class HadithResponse {
  final List<HadithModel> hadiths;
  final int total;
  final int page;
  final int limit;

  HadithResponse({
    required this.hadiths,
    required this.total,
    required this.page,
    required this.limit,
  });

  // ⭐ دالة مساعدة لتحويل أي نوع لـ int (نفس الدالة)
  static int _parseIntFromDynamic(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  factory HadithResponse.fromJson(Map<String, dynamic> json) {
    // التعامل مع الـ structure الجديد من API
    Map<String, dynamic> hadithsData;

    if (json.containsKey('hadiths') && json['hadiths'] is Map) {
      // الـ API بيرجع hadiths كـ Map فيه current_page و data
      hadithsData = json['hadiths'] as Map<String, dynamic>;
    } else {
      // fallback للـ structure القديم
      hadithsData = json;
    }

    // استخراج الـ data array
    List<dynamic> hadithList = [];
    if (hadithsData.containsKey('data') && hadithsData['data'] is List) {
      hadithList = hadithsData['data'] as List<dynamic>;
    } else if (json['hadiths'] is List) {
      hadithList = json['hadiths'] as List<dynamic>;
    }

    // استخراج الـ pagination info
    int currentPage = 1;
    int total = 0;
    int perPage = 20;

    if (hadithsData.containsKey('current_page')) {
      currentPage = _parseIntFromDynamic(hadithsData['current_page']);
    } else if (json.containsKey('page')) {
      currentPage = _parseIntFromDynamic(json['page']);
    }

    if (hadithsData.containsKey('total')) {
      total = _parseIntFromDynamic(hadithsData['total']);
    } else if (json.containsKey('total')) {
      total = _parseIntFromDynamic(json['total']);
    } else {
      // إذا مفيش total، استخدم عدد العناصر الحالية
      total = hadithList.length;
    }

    if (hadithsData.containsKey('per_page')) {
      perPage = _parseIntFromDynamic(hadithsData['per_page']);
    } else if (json.containsKey('limit')) {
      perPage = _parseIntFromDynamic(json['limit']);
    }

    return HadithResponse(
      hadiths: hadithList
          .map((h) => HadithModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      total: total,
      page: currentPage,
      limit: perPage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hadiths': hadiths.map((h) => h.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
    };
  }

  // دوال مساعدة للبحث
  List<HadithModel> searchByBook(String book) {
    return hadiths
        .where((h) => h.bookSlug.toLowerCase() == book.toLowerCase())
        .toList();
  }

  HadithModel? getByHadithNumber(int number) {
    try {
      return hadiths.firstWhere((h) => h.hadithNumber == number);
    } catch (e) {
      return null;
    }
  }
}
