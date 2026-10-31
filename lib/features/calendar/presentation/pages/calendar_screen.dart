import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  static const List<String> _weekDaysAr = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  static const List<String> _gregorianMonthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static const List<String> _hijriMonthsAr = [
    'مُحَرَّم',
    'صَفَر',
    'رَبِيع الأَوَّل',
    'رَبِيع الآخِر',
    'جُمَادَى الأُولَى',
    'جُمَادَى الآخِرَة',
    'رَجَب',
    'شَعْبَان',
    'رَمَضَان',
    'شَوَّال',
    'ذُو القَعْدَة',
    'ذُو الحِجَّة',
  ];

  // خوارزمية التحويل من التاريخ الميلادي إلى الهجري بدقة وبدون إنترنت
  static int _gToJd(int year, int month, int day) {
    var y = year;
    var m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524;
  }

  static ({int year, int month, int day}) _getHijriDate(DateTime date) {
    final jd = _gToJd(date.year, date.month, date.day);
    var l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    final j =
        ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
        (l / 5670).floor() * ((43 * l) / 15238).floor();
    l =
        l -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final m = ((24 * l) / 709).floor();
    final d = l - ((709 * m) / 24).floor();
    final y = 30 * n + j - 30;
    return (year: y, month: m, day: d);
  }

  // قائمة المناسبات الإسلامية الكبرى
  static String? _getIslamicOccasion(int hijriMonth, int hijriDay) {
    if (hijriMonth == 1 && hijriDay == 1) return 'رأس السنة الهجرية الجديدة';
    if (hijriMonth == 1 && hijriDay == 10) return 'يوم عاشوراء';
    if (hijriMonth == 3 && hijriDay == 12) return 'ذكرى المولد النبوي الشريف';
    if (hijriMonth == 7 && hijriDay == 27) return 'ذكرى الإسراء والمعراج';
    if (hijriMonth == 8 && hijriDay == 15) return 'ليلة النصف من شعبان';
    if (hijriMonth == 9 && hijriDay == 1) return 'أول أيام شهر رمضان المبارك';
    if (hijriMonth == 9 && hijriDay == 17) return 'ذكرى غزوة بدر الكبرى';
    if (hijriMonth == 9 && hijriDay == 27)
      return 'ليلة القدر المباركة (المتحرى)';
    if (hijriMonth == 10 && hijriDay == 1) return 'عيد الفطر المبارك';
    if (hijriMonth == 10 && (hijriDay == 2 || hijriDay == 3))
      return 'أيام عيد الفطر';
    if (hijriMonth == 12 && hijriDay >= 1 && hijriDay <= 8)
      return 'العشر الأوائل من ذي الحجة';
    if (hijriMonth == 12 && hijriDay == 9) return 'يوم عرفة المبارك';
    if (hijriMonth == 12 && hijriDay == 10) return 'عيد الأضحى المبارك';
    if (hijriMonth == 12 && hijriDay >= 11 && hijriDay <= 13)
      return 'أيام التشريق';
    return null;
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.tryParse(d) ?? 0])
        .join('');
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _currentMonth = DateTime(now.year, now.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedHijri = _getHijriDate(_selectedDate);
    final selectedOccasion = _getIslamicOccasion(
      selectedHijri.month,
      selectedHijri.day,
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1E2125)
          : const Color(0xFFFAF5ED),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF38291D),
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'التقويم الهجري والميلادي',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF38291D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _goToToday,
            child: Text(
              'اليوم',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF38291D),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. بطاقة اليوم المميزة مع التاريخ الهجري والميلادي
              _buildTodayHeroCard(today, isDark),

              SizedBox(height: 16.h),

              // 2. مبدل الشهور والتنقل
              _buildMonthNavigator(isDark),

              SizedBox(height: 12.h),

              // 3. شبكة التقويم الكاملة للشهر
              _buildCalendarGrid(today, isDark),

              SizedBox(height: 16.h),

              // 4. بطاقة تفاصيل اليوم المحدد
              _buildSelectedDateCard(selectedHijri, selectedOccasion, isDark),

              SizedBox(height: 16.h),

              // 5. قسم المناسبات الإسلامية لهذا الشهر
              _buildMonthOccasionsSection(isDark),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // بطاقة اليوم الكبرى
  Widget _buildTodayHeroCard(DateTime today, bool isDark) {
    final hijri = _getHijriDate(today);
    final hijriMonthName = _hijriMonthsAr[hijri.month - 1];
    final gregMonthName = _gregorianMonthsAr[today.month - 1];
    final weekdayName = _weekDaysAr[(today.weekday + 1) % 7];
    final todayOccasion = _getIslamicOccasion(hijri.month, hijri.day);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF143427), Color(0xFF0D251B)],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0xFF2D6A4F).withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF081C15).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13.sp,
                      color: const Color(0xFFE5C992),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'تاريخ اليوم',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFAF6EE),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'يوم $weekdayName',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE5C992),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // التاريخ الهجري البارز
          Text(
            '${_toArabicDigits(hijri.day)} $hijriMonthName ${_toArabicDigits(hijri.year)} هـ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFAF6EE),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6.h),

          // التاريخ الميلادي
          Text(
            '${_toArabicDigits(today.day)} $gregMonthName ${_toArabicDigits(today.year)} م',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.white70),
          ),

          if (todayOccasion != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: const Color(0xFFE5C992),
                    size: 14.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    todayOccasion,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFAF6EE),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // شريط مبدل الشهور
  Widget _buildMonthNavigator(bool isDark) {
    final gregMonthName = _gregorianMonthsAr[_currentMonth.month - 1];
    final midMonthDate = DateTime(_currentMonth.year, _currentMonth.month, 15);
    final hijri = _getHijriDate(midMonthDate);
    final hijriMonthName = _hijriMonthsAr[hijri.month - 1];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              size: 26.sp,
              color: isDark ? Colors.white70 : const Color(0xFF38291D),
            ),
            onPressed: _previousMonth,
            tooltip: 'الشهر السابق',
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$gregMonthName ${_toArabicDigits(_currentMonth.year)} م',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF38291D),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$hijriMonthName ${_toArabicDigits(hijri.year)} هـ',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: isDark ? const Color(0xFF2E8555) : const Color(0xFF38291D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 26.sp,
              color: isDark ? Colors.white70 : const Color(0xFF38291D),
            ),
            onPressed: _nextMonth,
            tooltip: 'الشهر التالي',
          ),
        ],
      ),
    );
  }

  // شبكة أيام الشهر
  Widget _buildCalendarGrid(DateTime today, bool isDark) {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    // السبت = 0 في الترتيب
    final firstWeekdayOffset = (firstDayOfMonth.weekday + 1) % 7;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // شريط أسماء أيام الأسبوع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDaysAr.map((day) {
              final isFriday = day == 'الجمعة';
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isFriday
                          ? (isDark ? const Color(0xFF2E8555) : const Color(0xFF38291D))
                          : (isDark ? Colors.white54 : const Color(0xFF8C7A6B)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Divider(
            height: 18.h,
            color: isDark ? Colors.white12 : const Color(0xFFEFE8DA),
          ),

          // شبكة الأيام
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: firstWeekdayOffset + daysInMonth,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6.h,
              crossAxisSpacing: 4.w,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekdayOffset) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - firstWeekdayOffset + 1;
              final cellDate = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayNumber,
              );
              final isToday =
                  cellDate.year == today.year &&
                  cellDate.month == today.month &&
                  cellDate.day == today.day;
              final isSelected =
                  cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;
              final cellHijri = _getHijriDate(cellDate);
              final hasOccasion =
                  _getIslamicOccasion(cellHijri.month, cellHijri.day) != null;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = cellDate;
                    });
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? (isDark ? const Color(0xFF2E8555) : const Color(0xFF38291D))
                          : (isSelected
                                ? (isDark
                                      ? const Color(0xFF38291D)
                                      : const Color(0xFFFAF5ED))
                                : Colors.transparent),
                      borderRadius: BorderRadius.circular(12.r),
                      border: isSelected && !isToday
                          ? Border.all(
                              color: isDark ? const Color(0xFF2E8555) : const Color(0xFF38291D),
                              width: 1.5,
                            )
                          : null,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // الرقم الميلادي
                        Text(
                          _toArabicDigits(dayNumber),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? Colors.white
                                : (isDark
                                      ? Colors.white
                                      : const Color(0xFF2A1C12)),
                          ),
                        ),
                        // الرقم الهجري
                        Text(
                          _toArabicDigits(cellHijri.day),
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? const Color(0xFFE5C992)
                                : const Color(0xFF9E7C3B),
                          ),
                        ),
                        // مؤشر مناسبة ديني
                        if (hasOccasion)
                          Container(
                            margin: EdgeInsets.only(top: 1.h),
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? Colors.amber
                                  : const Color(0xFFD97724),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // بطاقة تفاصيل اليوم المحدد
  Widget _buildSelectedDateCard(
    ({int year, int month, int day}) hijri,
    String? occasion,
    bool isDark,
  ) {
    final weekdayName = _weekDaysAr[(_selectedDate.weekday + 1) % 7];
    final hijriMonthName = _hijriMonthsAr[hijri.month - 1];
    final gregMonthName = _gregorianMonthsAr[_selectedDate.month - 1];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 20.sp,
                color: isDark ? const Color(0xFF2E8555) : const Color(0xFF38291D),
              ),
              SizedBox(width: 8.w),
              Text(
                'اليوم المحدد: $weekdayName',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF38291D),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التاريخ الهجري',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF8C7A6B),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${_toArabicDigits(hijri.day)} $hijriMonthName ${_toArabicDigits(hijri.year)} هـ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF2E8555) : const Color(0xFF38291D),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التاريخ الميلادي',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF8C7A6B),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${_toArabicDigits(_selectedDate.day)} $gregMonthName ${_toArabicDigits(_selectedDate.year)} م',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF38291D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (occasion != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD97724).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFD97724).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.stars_rounded,
                    color: const Color(0xFFD97724),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'مناسبة إسلامية: $occasion',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFF2C078)
                            : const Color(0xFFB55D10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // قسم المناسبات الإسلامية
  Widget _buildMonthOccasionsSection(bool isDark) {
    final occasions = [
      {'day': '١ محرم', 'title': 'رأس السنة الهجرية'},
      {'day': '١٠ محرم', 'title': 'يوم عاشوراء'},
      {'day': '١٢ ربيع الأول', 'title': 'المولد النبوي الشريف'},
      {'day': '٢٧ رجب', 'title': 'ذكرى الإسراء والمعراج'},
      {'day': '١٥ شعبان', 'title': 'ليلة النصف من شعبان'},
      {'day': '١ رمضان', 'title': 'أول أيام شهر رمضان المبارك'},
      {'day': '٢٧ رمضان', 'title': 'ليلة القدر المباركة'},
      {'day': '١ شوال', 'title': 'عيد الفطر المبارك'},
      {'day': '٩ ذو الحجة', 'title': 'يوم عرفة المبارك'},
      {'day': '١٠ ذو الحجة', 'title': 'عيد الأضحى المبارك'},
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFECE4D6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mosque_rounded,
                size: 20.sp,
                color: const Color(0xFF9E7C3B),
              ),
              SizedBox(width: 8.w),
              Text(
                'أهم المناسبات الإسلامية المباركة',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF38291D),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...occasions.map(
            (o) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8555).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      o['day']!,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E8555),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      o['title']!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF4A3E36),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
