import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/services/notification_settings_manager.dart';
import 'package:islamic_app/features/quran/presentation/pages/surah_detail_screen.dart';
import 'package:islamic_app/features/fasting/data/helpers/prayer_tracker_helper.dart';

class FastingSunanScreen extends StatefulWidget {
  const FastingSunanScreen({super.key});

  @override
  State<FastingSunanScreen> createState() => _FastingSunanScreenState();
}

class _FastingSunanScreenState extends State<FastingSunanScreen> {
  bool _mondayThursdayEnabled = true;
  bool _whiteDaysEnabled = true;
  bool _majorFastingEnabled = true;
  bool _fridayKahfEnabled = true;
  bool _fridayHourResponseEnabled = true;
  bool _isLoading = true;
  final Set<String> _checkedSunan = {};
  Set<String> _checkedPrayers = {};
  int _consistencyStreak = 0;
  List<Map<String, dynamic>> _weeklyHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final monThu =
        await NotificationSettingsManager.isMondayThursdayFastingEnabled();
    final whiteDays =
        await NotificationSettingsManager.isWhiteDaysFastingEnabled();
    final major = await NotificationSettingsManager.isMajorFastingEnabled();
    final kahf = await NotificationSettingsManager.isFridayKahfEnabled();
    final hourResponse =
        await NotificationSettingsManager.isFridayHourResponseEnabled();
    final prayers = await PrayerTrackerHelper.getCompletedPrayers();
    final sunan = await PrayerTrackerHelper.getCompletedSunan();
    final streak = await PrayerTrackerHelper.getConsistencyStreak();
    final history = await PrayerTrackerHelper.getWeeklyHistory();

    if (mounted) {
      setState(() {
        _mondayThursdayEnabled = monThu;
        _whiteDaysEnabled = whiteDays;
        _majorFastingEnabled = major;
        _fridayKahfEnabled = kahf;
        _fridayHourResponseEnabled = hourResponse;
        _checkedPrayers = prayers;
        _checkedSunan.clear();
        _checkedSunan.addAll(sunan);
        _consistencyStreak = streak;
        _weeklyHistory = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final isFriday = now.weekday == DateTime.friday;
    final isMonday = now.weekday == DateTime.monday;
    final isThursday = now.weekday == DateTime.thursday;
    final isSunday = now.weekday == DateTime.sunday;
    final isWednesday = now.weekday == DateTime.wednesday;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
        body: Stack(
          children: [
            // خلفية المساجد الفنية في الجزء العلوي بتدرج ناعم
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 220.h,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
                      Colors.white.withValues(alpha: isDark ? 0.15 : 0.35),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  AssetsData.headerMosqueBg,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // المحتوى مع شريط العنوان العلوي
            SafeArea(
              child: Column(
                children: [
                  _buildTopAppBar(isDark),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 10.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 🌟 بانر التذكير العلوي بلون المينت الناعم المطابق للصورة
                                if (isFriday)
                                  _buildMotivationalBanner(
                                    isDark: isDark,
                                    title: 'اليوم يوم الجمعة المبارك ✨',
                                    subtitle:
                                        'لا تنسَ قراءة سورة الكهف، والإكثار من الصلاة على النبي ﷺ وتحري ساعة الإجابة.',
                                  )
                                else if (isMonday || isThursday)
                                  _buildMotivationalBanner(
                                    isDark: isDark,
                                    title:
                                        'اليوم يوم صيام سنة (${isMonday ? "الإثنين" : "الخميس"}) 🌙',
                                    subtitle:
                                        'هنيئاً للصائمين؛ تُعرض الأعمال على الله عز وجل، تقبل الله طاعتكم.',
                                  )
                                else if (isSunday || isWednesday)
                                  _buildMotivationalBanner(
                                    isDark: isDark,
                                    title:
                                        'تذكير: غداً يوم ${isSunday ? "الإثنين" : "الخميس"} 🌙',
                                    subtitle:
                                        'يُستحب صيام الغد احتساباً لسنة الحبيب ﷺ، لا تنسَ عقد النية الليلة.',
                                  )
                                else
                                  _buildMotivationalBanner(
                                    isDark: isDark,
                                    title: 'تذكير: صيام الإثنين والخميس 🌙',
                                    subtitle:
                                        'يُستحب صيام يومي الإثنين والخميس احتساباً لسنة الحبيب ﷺ.',
                                  ),

                                  SizedBox(height: 14.h),

                                // 0. قسم الصلوات الخمس المفروضة ومؤشر الانتظام
                                _buildFivePrayersSection(isDark),

                                SizedBox(height: 14.h),

                                // 1. قسم سنن كل صلاة (السنن الرواتب والنوافل)
                                _buildPrayerSunanSection(isDark),

                                SizedBox(height: 14.h),

                                // 1. قسم صيام الإثنين والخميس
                                _buildFastingCard(
                                  isDark: isDark,
                                  title: 'صيام الإثنين والخميس',
                                  icon: Icons.calendar_today_rounded,
                                  iconColor: isDark
                                      ? Colors.white70
                                      : const Color(0xFF143427),
                                  description:
                                      '«تُعرض الأعمال يوم الإثنين والخميس، فأحب أن يُعرض عملي وأنا صائم» (رواه الترمذي).',
                                  switchTitle: 'تذكير صيام الإثنين والخميس',
                                  switchSubtitle:
                                      'تنبيه مساء الأحد ومساء الأربعاء بالصيام',
                                  switchValue: _mondayThursdayEnabled,
                                  onChanged: (val) async {
                                    setState(
                                      () => _mondayThursdayEnabled = val,
                                    );
                                    await NotificationSettingsManager.setMondayThursdayFastingEnabled(
                                      val,
                                    );
                                  },
                                ),

                                SizedBox(height: 14.h),

                                // 2. قسم صيام الأيام البيض
                                _buildFastingCard(
                                  isDark: isDark,
                                  title: 'صيام الأيام البيض (١٣، ١٤، ١٥)',
                                  icon: Icons.nightlight_round,
                                  iconColor: isDark
                                      ? Colors.white70
                                      : const Color(0xFF7D5A38),
                                  description:
                                      '«صيام ثلاثة أيام من كل شهر صيام الدهر، وهي أيام البيض: صبيحة ثلاث عشرة وأربع عشرة وخمس عشرة».',
                                  switchTitle: 'تذكير الأيام البيض شهرياً',
                                  switchSubtitle:
                                      'تنبيه مساء يوم ١٢ هجرياً للاستعداد',
                                  switchValue: _whiteDaysEnabled,
                                  onChanged: (val) async {
                                    setState(() => _whiteDaysEnabled = val);
                                    await NotificationSettingsManager.setWhiteDaysFastingEnabled(
                                      val,
                                    );
                                  },
                                ),

                                SizedBox(height: 14.h),

                                // 3. قسم سنن يوم الجمعة وسورة الكهف
                                _buildFridayKahfCard(isDark),

                                SizedBox(height: 14.h),

                                // 4. قسم المناسبات الكبرى للصيام
                                _buildFastingCard(
                                  isDark: isDark,
                                  title: 'صيام المناسبات الإسلامية الكبرى',
                                  icon: Icons.stars_rounded,
                                  iconColor: isDark
                                      ? Colors.white70
                                      : const Color(0xFF8C7A6B),
                                  description:
                                      '• صيام يوم عرفة (٩ ذو الحجة): يكفر السنة الماضية والباقية.\n'
                                      '• صيام عاشوراء وتاسوعاء (٩ و١٠ محرم): يكفر السنة الماضية.\n'
                                      '• صيام الست من شوال: صيام الدهر مع رمضان.',
                                  switchTitle: 'تنبيهات المناسبات الإسلامية الكبرى',
                                  switchSubtitle: 'إشعار قبل يوم عرفة وعاشوراء',
                                  switchValue: _majorFastingEnabled,
                                  onChanged: (val) async {
                                    setState(() => _majorFastingEnabled = val);
                                    await NotificationSettingsManager.setMajorFastingEnabled(
                                      val,
                                    );
                                  },
                                ),

                                SizedBox(height: 10.h),

                                // الزخرفة السفلية
                                _buildBottomOrnament(isDark),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // شريط العنوان العلوي
  // ==============================================================
  Widget _buildTopAppBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع في أقصى اليمين (في الواجهة العربية)
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF38291D),
              size: 20.sp,
            ),
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
          ),

          // العنوان في المنتصف مع الزخرفة الإسلامية
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32.w,
                      height: 1.h,
                      color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 3.5.r,
                      height: 3.5.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.mosque_rounded,
                      size: 15.sp,
                      color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 3.5.r,
                      height: 3.5.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 32.w,
                      height: 1.h,
                      color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'الفروض والسنن',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
              ],
            ),
          ),

          // مساحة فارغة لضبط التوسيط
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  // ==============================================================
  // بانر التذكير العلوي بلون المينت الناعم (الأخضر الباستيلي)
  // ==============================================================
  Widget _buildMotivationalBanner({
    required bool isDark,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2620) : const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF26382E) : const Color(0xFFD2E3D8),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // النصوص على اليمين
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: isDark ? Colors.white70 : const Color(0xFF4A5D52),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // دائرة الجرس الخضراء الملكية
          Container(
            width: 42.w,
            height: 42.w,
            decoration: const BoxDecoration(
              color: Color(0xFF143427),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة قسم الصيام العامة
  // ==============================================================
  Widget _buildFastingCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required String switchTitle,
    required String switchSubtitle,
    required bool switchValue,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الكارت: العنوان والأيقونة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
              ),
              Icon(
                icon,
                color: iconColor,
                size: 22.sp,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // نص الحديث التوضيحي
          Text(
            description,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white60 : const Color(0xFF736152),
              height: 1.5,
            ),
          ),

          // خط فاصل
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(
              color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
              height: 1,
            ),
          ),

          // سطر التبديل والتنبيه
          Row(
            children: [
              // السويتش على اليسار بالتصميم البيج والأخضر المطابق
              _buildCustomSwitch(
                value: switchValue,
                isDark: isDark,
                onChanged: onChanged,
              ),
              SizedBox(width: 12.w),

              // نصوص التنبيه في المنتصف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      switchTitle,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF38291D),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      switchSubtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // أيقونة جرس خفيفة في دائرة
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF2ECE3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 18.sp,
                  color: isDark ? Colors.white70 : const Color(0xFF736152),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة سنن يوم الجمعة وسورة الكهف
  // ==============================================================
  Widget _buildFridayKahfCard(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الكارت
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'سنن يوم الجمعة وسورة الكهف',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
              ),
              Icon(
                Icons.menu_book_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF143427),
                size: 22.sp,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // الوصف
          Text(
            '«من قرأ سورة الكهف في يوم الجمعة أضاء له من النور ما بين الجمعتين».\nابدأ وقتها من غروب شمس الخميس حتى مغرب الجمعة.',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white60 : const Color(0xFF736152),
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h),

          // زر قراءة سورة الكهف الأخضر الفخم المطابق للصورة
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SurahDetailScreen(surahId: 18),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF143427),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '۞',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFFE5D5BA),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'اقرأ سورة الكهف الآن',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.menu_book_rounded,
                  size: 19.sp,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(
              color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
              height: 1,
            ),
          ),

          // تذكير سورة الكهف
          Row(
            children: [
              _buildCustomSwitch(
                value: _fridayKahfEnabled,
                isDark: isDark,
                onChanged: (val) async {
                  setState(() => _fridayKahfEnabled = val);
                  await NotificationSettingsManager.setFridayKahfEnabled(val);
                },
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تذكير سورة الكهف صباح الجمعة',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF38291D),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'تنبيه الساعة ٨:٠٠ صباح الجمعة',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // تذكير ساعة الإجابة
          Row(
            children: [
              _buildCustomSwitch(
                value: _fridayHourResponseEnabled,
                isDark: isDark,
                onChanged: (val) async {
                  setState(() => _fridayHourResponseEnabled = val);
                  await NotificationSettingsManager.setFridayHourResponseEnabled(
                    val,
                  );
                },
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تذكير ساعة الاستجابة عصراً',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF38291D),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'تنبيه قبل مغرب الجمعة بساعتين',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // مفتاح التبديل المخصص المطابق للصور
  // ==============================================================
  Widget _buildCustomSwitch({
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor:
          isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427),
      activeThumbColor: const Color(0xFFC7A87A),
      inactiveTrackColor: isDark ? Colors.white12 : const Color(0xFFE5DCD1),
      inactiveThumbColor: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFC7A87A); // ذهبي دافئ واضح وفخم (غير أبيض)
        }
        return isDark ? Colors.white54 : const Color(0xFF8C7A6B); // بني هادئ وواضح عن الخلفية
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return isDark
              ? const Color(0xFF2E7D5E)
              : const Color(0xFF143427); // أخضر إسلامي بارز عند التشغيل
        }
        return isDark ? Colors.white12 : const Color(0xFFE5DCD1);
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return isDark ? Colors.white24 : const Color(0xFFC7B9A9);
      }),
    );
  }

  Widget _buildBottomOrnament(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 1.h,
            color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.mosque_rounded,
            size: 18.sp,
            color: isDark ? Colors.white38 : const Color(0xFF8C7A6B),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 40.w,
            height: 1.h,
            color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // قسم سنن كل صلاة (السنن الرواتب والنوافل اليومية)
  // ==============================================================
  Widget _buildPrayerSunanSection(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القسم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF143427).withValues(alpha: isDark ? 0.3 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mosque_rounded,
                        size: 15.sp,
                        color: isDark ? const Color(0xFFEADBCE) : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'سنن الصلوات الخمس والرواتب',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF143427),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF143427),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${_toArabicDigits(_checkedSunan.length)} من ٧ سنن اليوم',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // الحديث الشريف عن الـ 12 ركعة
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F2EA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'قال رسول الله ﷺ: «مَا مِنْ عَبْدٍ مُسْلِمٍ يُصَلِّي لِلَّهِ كُلَّ يَوْمٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً تَطَوُّعًا غَيْرَ فَرِيضَةٍ، إِلَّا بَنَى اللَّهُ لَهُ بَيْتًا فِي الْجَنَّةِ».',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13.5.sp,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFF6E8DC) : const Color(0xFF38291D),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // قائمة سنن كل صلاة بالتفصيل
          _buildPrayerSunanItem(
            isDark: isDark,
            id: 'fajr',
            prayerName: 'صلاة الفجر',
            rakahs: 'ركعتان قبل الفريضة',
            badge: 'سنة مؤكدة',
            hadithText: '«رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا»',
            icon: Icons.wb_twilight_rounded,
          ),
          _buildPrayerSunanItem(
            isDark: isDark,
            id: 'dhuhr',
            prayerName: 'صلاة الظهر',
            rakahs: '٤ ركعات قبله + ركعتان بعده',
            badge: 'سنن رواتب مؤكدة',
            hadithText: 'تُصلى مثنى مثنى، وركعتان بعد الفريضة من الرواتب',
            icon: Icons.wb_sunny_rounded,
          ),
          _buildPrayerSunanItem(
            isDark: isDark,
            id: 'asr',
            prayerName: 'صلاة العصر',
            rakahs: '٤ ركعات قبل الفريضة',
            badge: 'سنة مستحبة',
            hadithText: '«رَحِمَ اللَّهُ امْرَأً صَلَّى قَبْلَ الْعَصْرِ أَرْبَعًا»',
            icon: Icons.cloud_outlined,
          ),
          _buildPrayerSunanItem(
            isDark: isDark,
            id: 'maghrib',
            prayerName: 'صلاة المغرب',
            rakahs: 'ركعتان بعد الفريضة',
            badge: 'سنة مؤكدة',
            hadithText: 'سنة راتبة مؤكدة تُصلى مباشرة بعد الفريضة',
            icon: Icons.nights_stay_rounded,
          ),
          _buildPrayerSunanItem(
            isDark: isDark,
            id: 'isha',
            prayerName: 'صلاة العشاء',
            rakahs: 'ركعتان بعد الفريضة + الشفع والوتر',
            badge: 'سنة مؤكدة',
            hadithText: 'ركعتان راتبة بعد الفريضة، وسنة الوتر من أوكد السنن',
            icon: Icons.nightlight_round,
          ),
          _buildPrayerSunanItem(
            isDark: isDark,
            id: 'duha',
            prayerName: 'صلاة الضحى',
            rakahs: 'ركعتان إلى ٨ ركعات',
            badge: 'صلاة الأوابين',
            hadithText: 'تُجزئ عن ٣٦٠ صدقة في مفاصل البدن بعد الشروق بثلث ساعة',
            icon: Icons.wb_sunny_outlined,
          ),
          _buildPrayerSunanItem(
            isDark: isDark,
            id: 'qiyam',
            prayerName: 'قيام الليل والوتر',
            rakahs: 'ركعتان ركعتان مع الوتر',
            badge: 'شرف المؤمن',
            hadithText: '«أفضل الصلاة بعد الفريضة صلاة الليل»',
            icon: Icons.stars_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSunanItem({
    required bool isDark,
    required String id,
    required String prayerName,
    required String rakahs,
    required String badge,
    required String hadithText,
    required IconData icon,
  }) {
    final isChecked = _checkedSunan.contains(id);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isChecked
            ? const Color(0xFF143427).withValues(alpha: isDark ? 0.2 : 0.08)
            : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isChecked
              ? const Color(0xFF143427).withValues(alpha: isDark ? 0.6 : 0.3)
              : (isDark ? Colors.white10 : const Color(0xFFEADBCE)),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // أيقونة الصلاة
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: isChecked
                  ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 16.sp,
              color: isChecked
                  ? Colors.white
                  : (isDark ? const Color(0xFFB0B3B8) : const Color(0xFF6B7280)),
            ),
          ),
          SizedBox(width: 10.w),

          // التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        prayerName,
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
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFB0B3B8)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  rakahs,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  hadithText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // زر التحديد التفاعلي (صلّيتها اليوم)
          InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: () async {
              HapticFeedback.lightImpact();
              await PrayerTrackerHelper.toggleSunan(id);
              final sunan = await PrayerTrackerHelper.getCompletedSunan();
              if (mounted) {
                setState(() {
                  _checkedSunan.clear();
                  _checkedSunan.addAll(sunan);
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isChecked
                    ? const Color(0xFF143427)
                    : (isDark ? Colors.white10 : const Color(0xFFFAF5ED)),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFF143427)
                      : (isDark ? Colors.white24 : const Color(0xFFC7B9A9)),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    size: 15.sp,
                    color: isChecked ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF736152)),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    isChecked ? 'تم أداؤها' : 'صلّيتها',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: isChecked
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF736152)),
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

  // ==============================================================
  // قسم متابعة والانتظام في الصلوات الخمس المفروضة
  // ==============================================================
  Widget _buildFivePrayersSection(bool isDark) {
    final completedCount = _checkedPrayers.length;
    final progress = (completedCount / 5.0).clamp(0.0, 1.0);
    final isAllCompleted = completedCount == 5;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القسم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF143427).withValues(alpha: isDark ? 0.35 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.checklist_rtl_rounded,
                        size: 18.sp,
                        color: isDark ? const Color(0xFFEADBCE) : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'متابعة الصلوات الخمس المفروضة',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF143427),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
                decoration: BoxDecoration(
                  color: isAllCompleted
                      ? const Color(0xFF143427)
                      : (isDark ? Colors.white12 : const Color(0xFFE8F1EC)),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isAllCompleted
                        ? const Color(0xFF143427)
                        : (isDark ? Colors.white24 : const Color(0xFFC4D9CD)),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${_toArabicDigits(completedCount)} من ٥ اليوم',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isAllCompleted
                        ? Colors.white
                        : (isDark ? const Color(0xFFEADBCE) : const Color(0xFF143427)),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // شريط الإنجاز ومؤشر الانتظام اليومي
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF7F2EA),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'نسبة إنجاز فرائض اليوم:',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF736152),
                        ),
                      ),
                    ),
                    Text(
                      '${_toArabicDigits((progress * 100).toInt())}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF143427),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.5.h,
                    backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2D6C6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF143427)),
                  ),
                ),

                // رسالة الإتمام
                if (isAllCompleted) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Color(0xFFD4941C),
                        size: 16,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'هنيئاً لك! أتممت صلواتك الخمس اليوم، تقبل الله طاعتكم 🌿',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF6E8DC) : const Color(0xFF143427),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // شريط سلسلة الانتظام والمواظبة الأسبوعية (Streak)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [
                        const Color(0xFF1F4838).withValues(alpha: 0.4),
                        const Color(0xFF143427).withValues(alpha: 0.2),
                      ]
                    : [
                        const Color(0xFFEBF3EE),
                        const Color(0xFFF8FAF9),
                      ],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFF143427).withValues(alpha: isDark ? 0.35 : 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFE07A2A),
                            size: 18,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              'سلسلة الانتظام في الصلاة:',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF143427),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF143427),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${_toArabicDigits(_consistencyStreak)} ${_streakDaysText(_consistencyStreak)}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // فقاعات الأيام السبعة الأخيرة
                if (_weeklyHistory.isNotEmpty)
                  Row(
                    children: _weeklyHistory.map((day) {
                      final isToday = day['isToday'] as bool? ?? false;
                      final isFull = day['isFull'] as bool? ?? false;
                      final count = day['completedCount'] as int? ?? 0;
                      final dayName = day['dayName'] as String? ?? '';

                      return Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday
                                    ? const Color(0xFF143427)
                                    : (isDark ? Colors.white60 : const Color(0xFF8C7A6B)),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              width: 25.w,
                              height: 25.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFull
                                    ? const Color(0xFF143427)
                                    : (count > 0
                                        ? const Color(0xFFEADBCE)
                                        : (isDark ? Colors.white10 : Colors.white)),
                                border: Border.all(
                                  color: isToday
                                      ? const Color(0xFF143427)
                                      : (isDark ? Colors.white24 : const Color(0xFFEADBCE)),
                                  width: isToday ? 1.5 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: isFull
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 14.sp,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        count > 0 ? _toArabicDigits(count) : '-',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white70 : const Color(0xFF38291D),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // الحديث الشريف عن الصلوات الخمس
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F2EA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'قال رسول الله ﷺ: «خَمْسُ صَلَوَاتٍ كَتَبَهُنَّ اللَّهُ عَلَى الْعِبَادِ، فَمَنْ جَاءَ بِهِنَّ لَمْ يُضَيِّعْ مِنْهُنَّ شَيْئًا اسْتِخْفَافًا بِحَقِّهِنَّ، كَانَ لَهُ عِنْدَ اللَّهِ عَهْدٌ أَنْ يُدْخِلَهُ الْجَنَّةَ».',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13.sp,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFF6E8DC) : const Color(0xFF38291D),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // قائمة الصلوات الخمس
          _buildPrayerItem(
            isDark: isDark,
            id: 'fajr',
            prayerName: 'صلاة الفجر',
            rakahs: 'ركعتان فريضة',
            badge: 'فرض مؤكد',
            hadithText: '«مَنْ صَلَّى الْبَرْدَيْنِ دَخَلَ الْجَنَّةَ»',
            icon: Icons.wb_twilight_rounded,
          ),
          _buildPrayerItem(
            isDark: isDark,
            id: 'dhuhr',
            prayerName: 'صلاة الظهر',
            rakahs: '٤ ركعات فريضة',
            badge: 'أول فريضة في الإسلام',
            hadithText: '«إِنَّهَا سَاعَةٌ تُفْتَحُ فِيهَا أَبْوَابُ السَّمَاءِ»',
            icon: Icons.wb_sunny_rounded,
          ),
          _buildPrayerItem(
            isDark: isDark,
            id: 'asr',
            prayerName: 'صلاة العصر',
            rakahs: '٤ ركعات فريضة',
            badge: 'الصلاة الوسطى',
            hadithText: '«حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ»',
            icon: Icons.cloud_outlined,
          ),
          _buildPrayerItem(
            isDark: isDark,
            id: 'maghrib',
            prayerName: 'صلاة المغرب',
            rakahs: '٣ ركعات فريضة',
            badge: 'وتر النهار',
            hadithText: '«لا تَزَالُ أُمَّتِي بِخَيْرٍ مَا لَمْ يُؤَخِّرُوا الْمَغْرِبَ»',
            icon: Icons.nights_stay_rounded,
          ),
          _buildPrayerItem(
            isDark: isDark,
            id: 'isha',
            prayerName: 'صلاة العشاء',
            rakahs: '٤ ركعات فريضة',
            badge: 'ثواب قيام نصف الليل',
            hadithText: '«مَنْ صَلَّى الْعِشَاءَ فِي جَمَاعَةٍ فَكَأَنَّمَا قَامَ نِصْفَ اللَّيْلِ»',
            icon: Icons.nightlight_round,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem({
    required bool isDark,
    required String id,
    required String prayerName,
    required String rakahs,
    required String badge,
    required String hadithText,
    required IconData icon,
  }) {
    final isChecked = _checkedPrayers.contains(id);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isChecked
            ? const Color(0xFF143427).withValues(alpha: isDark ? 0.22 : 0.08)
            : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isChecked
              ? const Color(0xFF143427).withValues(alpha: isDark ? 0.6 : 0.3)
              : (isDark ? Colors.white10 : const Color(0xFFEADBCE)),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // أيقونة الصلاة
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: isChecked
                  ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: isChecked
                  ? Colors.white
                  : (isDark ? const Color(0xFFB0B3B8) : const Color(0xFF6B7280)),
            ),
          ),
          SizedBox(width: 10.w),

          // التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6.w,
                  runSpacing: 2.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      prayerName,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF38291D),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFB0B3B8)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  rakahs,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  hadithText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // زر التحديد التفاعلي (أديتها)
          InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: () async {
              HapticFeedback.lightImpact();
              await PrayerTrackerHelper.togglePrayer(id);
              final prayers = await PrayerTrackerHelper.getCompletedPrayers();
              final streak = await PrayerTrackerHelper.getConsistencyStreak();
              final history = await PrayerTrackerHelper.getWeeklyHistory();
              if (mounted) {
                setState(() {
                  _checkedPrayers = prayers;
                  _consistencyStreak = streak;
                  _weeklyHistory = history;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isChecked
                    ? const Color(0xFF143427)
                    : (isDark ? Colors.white10 : const Color(0xFFFAF5ED)),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFF143427)
                      : (isDark ? Colors.white24 : const Color(0xFFC7B9A9)),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    size: 15.sp,
                    color: isChecked ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF736152)),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    isChecked ? 'أُدِّيَتْ' : 'صلّيتها',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: isChecked
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF736152)),
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

  String _streakDaysText(int streak) {
    if (streak == 1) return 'يوم';
    if (streak == 2) return 'يومان';
    if (streak >= 3 && streak <= 10) return 'أيام';
    return 'يوماً';
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => int.tryParse(d) != null ? arabicDigits[int.parse(d)] : d)
        .join('');
  }
}


