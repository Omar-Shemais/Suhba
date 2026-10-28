class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String hijriDateAr; // التاريخ الهجري بالعربي
  final String hijriDateEn; // التاريخ الهجري بالإنجليزي
  final String hijriDay; // اليوم فقط
  final String hijriMonthAr; // الشهر الهجري بالعربي
  final String hijriMonthEn; // الشهر الهجري بالإنجليزي
  final String hijriYear; // السنة الهجرية
  final String weekdayAr; // اسم اليوم بالعربي
  final String weekdayEn; // اسم اليوم بالإنجليزي
  final DateTime cachedDate;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDateAr,
    required this.hijriDateEn,
    required this.hijriDay,
    required this.hijriMonthAr,
    required this.hijriMonthEn,
    required this.hijriYear,
    required this.weekdayAr,
    required this.weekdayEn,
    required this.cachedDate,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'] as Map<String, dynamic>;
    final date = json['data']['date'];
    final hijri = date['hijri'];
    final gregorian = date['gregorian'];

    return PrayerTimesModel(
      fajr: _convertTo12Hour(timings['Fajr']),
      sunrise: _convertTo12Hour(timings['Sunrise']),
      dhuhr: _convertTo12Hour(timings['Dhuhr']),
      asr: _convertTo12Hour(timings['Asr']),
      maghrib: _convertTo12Hour(timings['Maghrib']),
      isha: _convertTo12Hour(timings['Isha']),
      date: date['readable'] ?? '',

      // التاريخ الهجري الكامل
      hijriDateAr:
          '${hijri['day']} ${hijri['month']['ar']} ${hijri['year']} هـ',
      hijriDateEn:
          '${hijri['day']} ${hijri['month']['en']} ${hijri['year']} AH',

      // المكونات المنفصلة
      hijriDay: hijri['day'] ?? '',
      hijriMonthAr: hijri['month']['ar'] ?? '',
      hijriMonthEn: hijri['month']['en'] ?? '',
      hijriYear: hijri['year'] ?? '',

      // أسماء الأيام
      weekdayAr: hijri['weekday']['ar'] ?? '',
      weekdayEn: gregorian['weekday']['en'] ?? '',

      cachedDate: DateTime.now(),
    );
  }

  /// تحويل الوقت من 24 ساعة إلى 12 ساعة
  /// مثال: "16:59 (EET)" → "04:59 PM"
  /// مثال: "04:47" → "04:47 AM"
  static String _convertTo12Hour(String time24) {
    try {
      // تنظيف الوقت من أي نصوص إضافية (EET, +02, إلخ)
      String cleanTime = time24.trim();

      // إزالة أي نص بين أقواس مثل (EET) أو (+02)
      if (cleanTime.contains('(')) {
        cleanTime = cleanTime.split('(')[0].trim();
      }

      // إزالة أي مسافات إضافية
      cleanTime = cleanTime.split(' ').first.trim();

      // فصل الساعات والدقائق
      final parts = cleanTime.split(':');
      if (parts.length < 2) return time24; // إرجاع القيمة الأصلية لو فيه مشكلة

      int hour = int.parse(parts[0]);
      final minutes = parts[1];

      // تحديد AM أو PM
      final period = hour >= 12 ? 'PM' : 'AM';

      // تحويل الساعة من 24 لـ 12
      if (hour == 0) {
        hour = 12; // منتصف الليل 00:00 → 12:00 AM
      } else if (hour > 12) {
        hour = hour - 12; // مثال: 13:00 → 01:00 PM
      }
      // hour == 12 تبقى زي ما هي (12:00 PM)

      // إرجاع الوقت بصيغة 12 ساعة
      return '${hour.toString().padLeft(2, '0')}:$minutes $period';
    } catch (e) {
      // في حالة حدوث أي خطأ، نرجع القيمة الأصلية
      return time24;
    }
  }

  /// تقسيم الوقت إلى ساعات ودقائق (بدون AM/PM)
  /// مثال: "04:47 AM" → {hours: "04", minutes: "47", period: "AM"}
  static Map<String, String> splitTime(String time) {
    try {
      final parts = time.split(' ');
      final timeParts = parts[0].split(':');

      return {
        'hours': timeParts[0],
        'minutes': timeParts[1],
        'period': parts.length > 1 ? parts[1] : '',
      };
    } catch (e) {
      return {'hours': '00', 'minutes': '00', 'period': 'AM'};
    }
  }

  /// الحصول على التاريخ الهجري حسب اللغة
  String getHijriDate(bool isArabic) {
    return isArabic ? hijriDateAr : hijriDateEn;
  }

  /// الحصول على اسم اليوم حسب اللغة
  String getWeekday(bool isArabic) {
    return isArabic ? weekdayAr : weekdayEn;
  }

  /// الحصول على اسم الشهر الهجري حسب اللغة
  String getHijriMonth(bool isArabic) {
    return isArabic ? hijriMonthAr : hijriMonthEn;
  }

  /// الحصول على تاريخ مختصر (يوم + شهر فقط)
  String getShortHijriDate(bool isArabic) {
    return isArabic ? '$hijriDay $hijriMonthAr' : '$hijriDay $hijriMonthEn';
  }

  Map<String, dynamic> toMap() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'date': date,
      'hijriDateAr': hijriDateAr,
      'hijriDateEn': hijriDateEn,
      'hijriDay': hijriDay,
      'hijriMonthAr': hijriMonthAr,
      'hijriMonthEn': hijriMonthEn,
      'hijriYear': hijriYear,
      'weekdayAr': weekdayAr,
      'weekdayEn': weekdayEn,
      'cachedDate': cachedDate.toIso8601String(),
    };
  }

  factory PrayerTimesModel.fromMap(Map<String, dynamic> map) {
    return PrayerTimesModel(
      fajr: map['fajr'] ?? '',
      sunrise: map['sunrise'] ?? '',
      dhuhr: map['dhuhr'] ?? '',
      asr: map['asr'] ?? '',
      maghrib: map['maghrib'] ?? '',
      isha: map['isha'] ?? '',
      date: map['date'] ?? '',
      hijriDateAr: map['hijriDateAr'] ?? '',
      hijriDateEn: map['hijriDateEn'] ?? '',
      hijriDay: map['hijriDay'] ?? '',
      hijriMonthAr: map['hijriMonthAr'] ?? '',
      hijriMonthEn: map['hijriMonthEn'] ?? '',
      hijriYear: map['hijriYear'] ?? '',
      weekdayAr: map['weekdayAr'] ?? '',
      weekdayEn: map['weekdayEn'] ?? '',
      cachedDate: DateTime.parse(
        map['cachedDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  bool isValidForToday() {
    final now = DateTime.now();
    return cachedDate.year == now.year &&
        cachedDate.month == now.month &&
        cachedDate.day == now.day;
  }
}

class PrayerInfo {
  final String name;
  final String nameAr;
  final String time;
  final bool isPassed;
  final bool isNext;

  PrayerInfo({
    required this.name,
    required this.nameAr,
    required this.time,
    required this.isPassed,
    required this.isNext,
  });

  /// الحصول على الساعات فقط من الوقت
  String get hours => PrayerTimesModel.splitTime(time)['hours']!;

  /// الحصول على الدقائق فقط من الوقت
  String get minutes => PrayerTimesModel.splitTime(time)['minutes']!;

  /// الحصول على AM/PM
  String get period => PrayerTimesModel.splitTime(time)['period']!;
}
