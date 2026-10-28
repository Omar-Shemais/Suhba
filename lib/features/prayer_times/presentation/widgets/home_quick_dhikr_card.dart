import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import 'package:islamic_app/core/widgets/salawat_bottom_sheet.dart';

enum DhikrTimePeriod {
  sunrise,
  morning,
  midday,
  evening,
  night,
}

class HomeQuickDhikrCard extends StatefulWidget {
  const HomeQuickDhikrCard({super.key});

  @override
  State<HomeQuickDhikrCard> createState() => _HomeQuickDhikrCardState();
}

class _HomeQuickDhikrCardState extends State<HomeQuickDhikrCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  // عدادات سريعة تفاعلية داخل الكارد
  int _salawatCount = 0;
  int _istighfarCount = 0;
  int _hawqalahCount = 0;
  int _tasbehCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// تحديد الفترة الحالية لليوم بناء على الساعة
  DhikrTimePeriod _getCurrentPeriod() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 4 && hour < 7.5) {
      return DhikrTimePeriod.sunrise; // في الشروق: دعاء الاستيقاظ
    } else if (hour >= 7.5 && hour < 11.5) {
      return DhikrTimePeriod.morning; // الصباح: أذكار الصباح
    } else if (hour >= 11.5 && hour < 15.5) {
      return DhikrTimePeriod.midday; // الظهيرة: الصلاة على النبي ﷺ
    } else if (hour >= 15.5 && hour < 21) {
      return DhikrTimePeriod.evening; // المساء: أذكار المساء
    } else {
      return DhikrTimePeriod.night; // بليل بعد الساعة 9: دعاء قبل النوم
    }
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => int.tryParse(d) != null ? arabicDigits[int.parse(d)] : d)
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final period = _getCurrentPeriod();
    final cards = _buildDhikrItems(context, isDark, period);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. شريط العنوان والمؤشر الذكي في الأعلى
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // العنوان مع شارة التوقيت المناسبة
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF143427).withValues(alpha: isDark ? 0.25 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getPeriodIcon(period),
                        size: 13.sp,
                        color: isDark ? const Color(0xFFEADBCE) : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'زاد ونفحات يومية',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF38291D),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF143427),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _getPeriodBadgeText(period),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // مؤشر النقاط التفاعلي
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(cards.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    width: isActive ? 14.w : 5.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF143427)
                          : (isDark ? Colors.white24 : const Color(0xFFD6C8B8)),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 2. الكروت التفاعلية السريعة مع سكرول فائق السلاسة والسرعة
          SizedBox(
            height: 140.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: cards.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return cards[index];
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPeriodIcon(DhikrTimePeriod period) {
    switch (period) {
      case DhikrTimePeriod.sunrise:
        return Icons.wb_twilight_rounded;
      case DhikrTimePeriod.morning:
        return Icons.wb_sunny_rounded;
      case DhikrTimePeriod.midday:
        return Icons.spa_rounded;
      case DhikrTimePeriod.evening:
        return Icons.nights_stay_rounded;
      case DhikrTimePeriod.night:
        return Icons.bedtime_rounded;
    }
  }

  String _getPeriodBadgeText(DhikrTimePeriod period) {
    switch (period) {
      case DhikrTimePeriod.sunrise:
        return 'الشروق والاستيقاظ';
      case DhikrTimePeriod.morning:
        return 'الصباح';
      case DhikrTimePeriod.midday:
        return 'الصلاة ع النبي ﷺ';
      case DhikrTimePeriod.evening:
        return 'المساء';
      case DhikrTimePeriod.night:
        return 'بعد ٩ م (قبل النوم)';
    }
  }

  List<Widget> _buildDhikrItems(
    BuildContext context,
    bool isDark,
    DhikrTimePeriod period,
  ) {
    final List<Widget> list = [];

    // 1. بطاقة التوقيت التلقائية الذكية (الشروق: دعاء الاستيقاظ -> الصباح -> الظهيرة: الصلاة ع النبي -> المساء -> الليل بعد 9: دعاء قبل النوم)
    if (period == DhikrTimePeriod.sunrise) {
      // في الشروق: دعاء الاستيقاظ من النوم
      list.add(
        _buildActionCard(
          isDark: isDark,
          icon: Icons.wb_twilight_rounded,
          iconColor: const Color(0xFFB8782E),
          tag: 'دعاء الاستيقاظ عند الشروق',
          title: '«الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ»',
          subtitle: 'سنة الاستيقاظ: حمد الله على رد الروح وبداية يوم مبارك',
          primaryButtonText: 'أذكار الصباح كاملة',
          onPrimaryTap: () => context.push(AppRoutes.morningAzkar),
        ),
      );
    } else if (period == DhikrTimePeriod.morning) {
      // وقت الصباح: أذكار الصباح في الصدارة
      list.add(
        _buildActionCard(
          isDark: isDark,
          icon: Icons.wb_sunny_rounded,
          iconColor: const Color(0xFFB8782E),
          tag: 'وقت أذكار الصباح',
          title: '«أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ»',
          subtitle: 'ابدأ يومك بحفظ الله ورعايته وبركاته',
          primaryButtonText: 'قراءة أذكار الصباح',
          onPrimaryTap: () => context.push(AppRoutes.morningAzkar),
        ),
      );
    } else if (period == DhikrTimePeriod.midday) {
      // وقت الظهيرة: تختفي أذكار الصباح وتتصدر الصلاة على النبي ﷺ
      list.add(
        _buildSalawatCard(
          isDark: isDark,
          tag: 'الصلاة على الحبيب ﷺ',
          showTagNotice: true,
        ),
      );
    } else if (period == DhikrTimePeriod.evening) {
      // وقت المساء: أذكار المساء في الصدارة
      list.add(
        _buildActionCard(
          isDark: isDark,
          icon: Icons.nights_stay_rounded,
          iconColor: const Color(0xFF6B5E87),
          tag: 'وقت أذكار المساء',
          title: '«أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ»',
          subtitle: 'حصن نفسك وأهلك بسكينة المساء وطمأنينة الذكر',
          primaryButtonText: 'قراءة أذكار المساء',
          onPrimaryTap: () => context.push(AppRoutes.eveningAzkar),
        ),
      );
    } else {
      // بليل بعد الساعة 9: دعاء قبل النوم والسكينة
      list.add(
        _buildActionCard(
          isDark: isDark,
          icon: Icons.bedtime_rounded,
          iconColor: const Color(0xFF4A6B82),
          tag: 'دعاء قبل النوم والسكينة',
          title: '«بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ»',
          subtitle: '«فإن أمسكت نفسي فارحمها وإن أرسلتها فاحفظها»',
          primaryButtonText: 'أذكار النوم والأدعية',
          onPrimaryTap: () => context.push(AppRoutes.azkar),
        ),
      );
    }

    // 2. أذكار بعد كل صلاة (دائماً متاحة في السكرول لسرعة الوصول بعد الصلوات المفروضة)
    list.add(
      _buildActionCard(
        isDark: isDark,
        icon: Icons.mosque_rounded,
        iconColor: const Color(0xFF143427),
        tag: 'أذكار بعد كل صلاة',
        title: '«أَسْتَغْفِرُ اللهَ (٣) .. اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ»',
        subtitle: 'المداومة على أذكار ما بعد الفريضة سنة مؤكدة',
        primaryButtonText: 'أذكار بعد الصلاة',
        onPrimaryTap: () => context.push(AppRoutes.afterPrayerAzkar),
      ),
    );

    // 2. بطاقة الصلاة على النبي ﷺ (تظهر دائماً في القائمة إذا لم تكن هي الأولى)
    if (period != DhikrTimePeriod.midday) {
      list.add(
        _buildSalawatCard(
          isDark: isDark,
          tag: 'الصلاة على النبي ﷺ',
          showTagNotice: false,
        ),
      );
    }

    // 3. الاستغفار وذكر الله (سيد الاستغفار مع عداد مباشر وزر الأذكار)
    list.add(
      _buildCounterCard(
        isDark: isDark,
        icon: Icons.radio_button_checked_rounded,
        iconColor: const Color(0xFF143427),
        tag: 'استغفار اليوم',
        dhikrText: '«أَسْتَغْفِرُ اللهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ»',
        hintText: 'يفتح لك أبواب الرزق والفرج',
        count: _istighfarCount,
        buttonLabel: 'أستغفر الله',
        onTapCounter: () {
          HapticFeedback.lightImpact();
          setState(() {
            _istighfarCount++;
          });
        },
        onNavigate: () => context.push(AppRoutes.azkar),
      ),
    );

    // 4. كنز من كنوز الجنة (الحوقلة والباقيات الصالحات)
    list.add(
      _buildCounterCard(
        isDark: isDark,
        icon: Icons.stars_rounded,
        iconColor: const Color(0xFFB8782E),
        tag: 'كنز من كنوز الجنة',
        dhikrText: '«لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ»',
        hintText: 'دواء لتسعة وتسعين داء أيسرها الهم',
        count: _hawqalahCount,
        buttonLabel: 'لا حول ولا قوة إلا بالله',
        onTapCounter: () {
          HapticFeedback.lightImpact();
          setState(() {
            _hawqalahCount++;
          });
        },
        onNavigate: () => context.push(AppRoutes.azkar),
      ),
    );

    // 5. التسبيح والحمد (سبحان الله وبحمده سبحان الله العظيم)
    list.add(
      _buildCounterCard(
        isDark: isDark,
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFF143427),
        tag: 'حبيبتان إلى الرحمن',
        dhikrText: '«سُبْحَانَ اللهِ وَبِحَمْدِهِ ، سُبْحَانَ اللهِ الْعَظِيمِ»',
        hintText: 'ثقيلتان في الميزان خفيفتان على اللسان',
        count: _tasbehCount,
        buttonLabel: 'سبحان الله وبحمده',
        onTapCounter: () {
          HapticFeedback.lightImpact();
          setState(() {
            _tasbehCount++;
          });
        },
        onNavigate: () => context.push(AppRoutes.azkar),
      ),
    );

    return list;
  }

  /// كارد الصلاة على النبي ﷺ (يحتوي على عداد مباشر وزر فتح الشيت الشامل)
  Widget _buildSalawatCard({
    required bool isDark,
    required String tag,
    required bool showTagNotice,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21252A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF143427).withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.spa_rounded,
                  size: 13.sp,
                  color: const Color(0xFF143427),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF736152),
                  ),
                ),
              ),
              // زر لفتح الشيت الكامل للصلاة على النبي
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () => SalawatBottomSheet.show(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الصيغ والفضائل',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF143427),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 15.sp,
                        color: const Color(0xFF143427),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Center(
              child: Text(
                '«اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ ﷺ»',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF143427),
                ),
              ),
            ),
          ),

          // صف التفاعل: زر عداد فوري
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _salawatCount++;
                });
              },
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF143427),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF143427).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 14.sp,
                      color: const Color(0xFFC7A87A),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        _salawatCount == 0
                            ? 'اضغط للصلاة على النبي ﷺ'
                            : 'صلّيت ﷺ (${_toArabicDigits(_salawatCount)}) مرات',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// كارد تسبيح تفاعلي بالعداد الفوري وزر انتقال للأذكار
  Widget _buildCounterCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String tag,
    required String dhikrText,
    required String hintText,
    required int count,
    required String buttonLabel,
    required VoidCallback onTapCounter,
    required VoidCallback onNavigate,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21252A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  size: 13.sp,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF736152),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: onNavigate,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض الأذكار',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF143427),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 15.sp,
                        color: const Color(0xFF143427),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Center(
              child: Text(
                dhikrText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF143427),
                ),
              ),
            ),
          ),

          // زر التسبيح مع العداد
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: onTapCounter,
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF143427),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF143427).withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14.sp,
                      color: const Color(0xFFC7A87A),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        count == 0 ? buttonLabel : '$buttonLabel (${_toArabicDigits(count)})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// كارد نصي وتوجيهي (مثل أذكار الصباح والمساء وبعد الصلاة)
  Widget _buildActionCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String tag,
    required String title,
    required String subtitle,
    required String primaryButtonText,
    required VoidCallback onPrimaryTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21252A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  size: 13.sp,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF736152),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF143427),
                ),
              ),
            ),
          ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: onPrimaryTap,
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF143427),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF143427).withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        primaryButtonText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 17.sp,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
