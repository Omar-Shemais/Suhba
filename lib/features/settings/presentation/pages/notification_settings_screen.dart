import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/services/notification_settings_manager.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _masterEnabled = true;
  bool _prayersMasterEnabled = true;
  bool _fajrSpecificEnabled = true;
  bool _dhuhrEnabled = true;
  bool _asrEnabled = true;
  bool _maghribEnabled = true;
  bool _ishaEnabled = true;

  // سنن
  bool _mondayThursdayEnabled = true;
  bool _whiteDaysEnabled = true;
  bool _majorFastingEnabled = true;
  bool _fridayKahfEnabled = true;
  bool _fridayHourResponseEnabled = true;
  bool _khatmahReminderEnabled = true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    final master = await NotificationSettingsManager.isMasterEnabled();
    final prayersMaster =
        await NotificationSettingsManager.isPrayerMasterEnabled();
    final fajrSpecific =
        await NotificationSettingsManager.isFajrSpecificEnabled();
    final dhuhr = await NotificationSettingsManager.isPrayerIndividualEnabled(
      'dhuhr',
    );
    final asr = await NotificationSettingsManager.isPrayerIndividualEnabled(
      'asr',
    );
    final maghrib = await NotificationSettingsManager.isPrayerIndividualEnabled(
      'maghrib',
    );
    final isha = await NotificationSettingsManager.isPrayerIndividualEnabled(
      'isha',
    );

    final monThu =
        await NotificationSettingsManager.isMondayThursdayFastingEnabled();
    final whiteDays =
        await NotificationSettingsManager.isWhiteDaysFastingEnabled();
    final majorFasting =
        await NotificationSettingsManager.isMajorFastingEnabled();
    final kahf = await NotificationSettingsManager.isFridayKahfEnabled();
    final hourResponse =
        await NotificationSettingsManager.isFridayHourResponseEnabled();
    final khatmah =
        await NotificationSettingsManager.isKhatmahReminderEnabled();

    if (mounted) {
      setState(() {
        _masterEnabled = master;
        _prayersMasterEnabled = prayersMaster;
        _fajrSpecificEnabled = fajrSpecific;
        _dhuhrEnabled = dhuhr;
        _asrEnabled = asr;
        _maghribEnabled = maghrib;
        _ishaEnabled = isha;

        _mondayThursdayEnabled = monThu;
        _whiteDaysEnabled = whiteDays;
        _majorFastingEnabled = majorFasting;
        _fridayKahfEnabled = kahf;
        _fridayHourResponseEnabled = hourResponse;
        _khatmahReminderEnabled = khatmah;

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 10.h,
                            ),
                            children: [
                              // 1. بطاقة تفعيل كافة الإشعارات (Master Switch Card)
                              _buildMasterSwitchCard(isDark),
                              SizedBox(height: 18.h),

                              // 2. فاصل عنوان قسم الصلاة والأذان
                              _buildSectionDivider(
                                icon: Icons.mosque_rounded,
                                title: 'إشعارات مواقيت الصلاة والأذان',
                                isDark: isDark,
                              ),
                              SizedBox(height: 12.h),

                              // بطاقة مواقيت الصلاة
                              _buildPrayersCard(isDark),
                              SizedBox(height: 18.h),

                              // 3. فاصل عنوان قسم صيام السنن
                              _buildSectionDivider(
                                icon: Icons.nightlight_round,
                                title: 'إشعارات صيام السنن والأيام المباركة',
                                isDark: isDark,
                              ),
                              SizedBox(height: 12.h),

                              // بطاقة صيام السنن
                              _buildFastingCard(isDark),
                              SizedBox(height: 18.h),

                              // 4. فاصل سنن الجمعة
                              _buildSectionDivider(
                                icon: Icons.menu_book_rounded,
                                title: 'سنن يوم الجمعة وسورة الكهف',
                                isDark: isDark,
                              ),
                              SizedBox(height: 12.h),

                              // بطاقة سنن الجمعة
                              _buildFridaySunanCard(isDark),
                              SizedBox(height: 18.h),

                              // 5. فاصل ورد الختمة
                              _buildSectionDivider(
                                icon: Icons.auto_stories_rounded,
                                title: 'ورد الختمة القرآني',
                                isDark: isDark,
                              ),
                              SizedBox(height: 12.h),

                              // بطاقة ورد الختمة
                              _buildKhatmahCard(isDark),
                              SizedBox(height: 14.h),

                              // الزخرفة السفلية
                              _buildBottomOrnament(isDark),
                              SizedBox(height: 14.h),
                            ],
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

          // العنوان في المنتصف
          Expanded(
            child: Text(
              'إعدادات الإشعارات والتنبيهات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.5.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF143427),
              ),
            ),
          ),

          // مساحة فارغة لضبط التوسيط
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة المفتاح الرئيسي العام
  // ==============================================================
  Widget _buildMasterSwitchCard(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
      child: Row(
        children: [
          _buildCustomSwitch(
            value: _masterEnabled,
            isDark: isDark,
            onChanged: (val) async {
              setState(() {
                _masterEnabled = val;
                _prayersMasterEnabled = val;
                _fajrSpecificEnabled = val;
                _dhuhrEnabled = val;
                _asrEnabled = val;
                _maghribEnabled = val;
                _ishaEnabled = val;
                _mondayThursdayEnabled = val;
                _whiteDaysEnabled = val;
                _majorFastingEnabled = val;
                _fridayKahfEnabled = val;
                _fridayHourResponseEnabled = val;
                _khatmahReminderEnabled = val;
              });
              await NotificationSettingsManager.setMasterEnabled(val);
            },
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفعيل كافة الإشعارات',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _masterEnabled
                      ? 'الإشعارات والتنبيهات قيد التفعيل'
                      : 'تم إيقاف جميع التنبيهات',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFE8F1EC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: const Color(0xFF143427),
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // فاصل الأقسام مع الأيقونة والخطوط
  // ==============================================================
  Widget _buildSectionDivider({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    final dividerColor = isDark ? Colors.white24 : const Color(0xFFC7B9A9);
    final iconColor = isDark ? Colors.white54 : const Color(0xFF8C7A6B);

    return Row(
      children: [
        // الخط الأيسر الممتد
        Expanded(
          child: Container(
            height: 1.h,
            color: dividerColor,
          ),
        ),
        SizedBox(width: 8.w),
        // نص القسم
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF143427),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Icon(
          icon,
          size: 16.sp,
          color: iconColor,
        ),
        SizedBox(width: 8.w),
        // خط أيمن قصير للتوازن الجمالي
        Container(
          width: 20.w,
          height: 1.h,
          color: dividerColor,
        ),
      ],
    );
  }

  // ==============================================================
  // بطاقة إعدادات الصلوات الخمس
  // ==============================================================
  Widget _buildPrayersCard(bool isDark) {
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
        children: [
          // سطر إشعارات الصلوات الخمس العام
          Row(
            children: [
              _buildCustomSwitch(
                value: _prayersMasterEnabled,
                isDark: isDark,
                enabled: _masterEnabled,
                onChanged: (val) async {
                  setState(() {
                    _prayersMasterEnabled = val;
                    if (!val) {
                      // تلقائياً يوقف صلاة الظهر والعصر والمغرب والعشاء بس صلاة الفجر استثناء
                      _dhuhrEnabled = false;
                      _asrEnabled = false;
                      _maghribEnabled = false;
                      _ishaEnabled = false;
                    } else {
                      _dhuhrEnabled = true;
                      _asrEnabled = true;
                      _maghribEnabled = true;
                      _ishaEnabled = true;
                    }
                  });
                  await NotificationSettingsManager.setPrayerMasterEnabled(val);
                  await NotificationSettingsManager.setPrayerIndividualEnabled('dhuhr', val);
                  await NotificationSettingsManager.setPrayerIndividualEnabled('asr', val);
                  await NotificationSettingsManager.setPrayerIndividualEnabled('maghrib', val);
                  await NotificationSettingsManager.setPrayerIndividualEnabled('isha', val);
                },
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إشعارات الصلوات الخمس',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'تشغيل إشعارات مواقيت الصلاة الخمس',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF2ECE3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.mosque_outlined,
                  color: isDark ? Colors.white70 : const Color(0xFF143427),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ⭐ كارت صلاة الفجر المخصوص المميز ذو الخلفية الباستيلية
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2620) : const Color(0xFFE8F1EC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark ? const Color(0xFF26382E) : const Color(0xFFD2E3D8),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                _buildCustomSwitch(
                  value: _fajrSpecificEnabled,
                  isDark: isDark,
                  enabled: _masterEnabled,
                  onChanged: (val) async {
                    setState(() => _fajrSpecificEnabled = val);
                    await NotificationSettingsManager.setFajrSpecificEnabled(
                      val,
                    );
                  },
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'صلاة الفجر',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF143427),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF143427),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'مخصوص',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'تشغيل أذان الفجر دائماً حتى لو تم إيقاف باقي الصلوات',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF4A5D52),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF143427),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wb_twilight_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),

          // بقية الصلوات الخمس
          _buildPrayerRow(
            title: 'صلاة الظهر',
            icon: Icons.wb_sunny_outlined,
            value: _dhuhrEnabled,
            isDark: isDark,
            onChanged: (val) async {
              setState(() => _dhuhrEnabled = val);
              await NotificationSettingsManager.setPrayerIndividualEnabled(
                'dhuhr',
                val,
              );
            },
          ),
          _buildPrayerRow(
            title: 'صلاة العصر',
            icon: Icons.brightness_6_outlined,
            value: _asrEnabled,
            isDark: isDark,
            onChanged: (val) async {
              setState(() => _asrEnabled = val);
              await NotificationSettingsManager.setPrayerIndividualEnabled(
                'asr',
                val,
              );
            },
          ),
          _buildPrayerRow(
            title: 'صلاة المغرب',
            icon: Icons.wb_twilight_rounded,
            value: _maghribEnabled,
            isDark: isDark,
            onChanged: (val) async {
              setState(() => _maghribEnabled = val);
              await NotificationSettingsManager.setPrayerIndividualEnabled(
                'maghrib',
                val,
              );
            },
          ),
          _buildPrayerRow(
            title: 'صلاة العشاء',
            icon: Icons.nightlight_round,
            value: _ishaEnabled,
            isDark: isDark,
            isLast: true,
            onChanged: (val) async {
              setState(() => _ishaEnabled = val);
              await NotificationSettingsManager.setPrayerIndividualEnabled(
                'isha',
                val,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow({
    required String title,
    required IconData icon,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    final enabled = _masterEnabled && _prayersMasterEnabled;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            children: [
              _buildCustomSwitch(
                value: value,
                isDark: isDark,
                enabled: enabled,
                onChanged: onChanged,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF38291D),
                  ),
                ),
              ),
              Icon(
                icon,
                color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                size: 20.sp,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
          ),
      ],
    );
  }

  // ==============================================================
  // بطاقة صيام السنن
  // ==============================================================
  Widget _buildFastingCard(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // صيام الإثنين والخميس
          Row(
            children: [
              _buildCustomSwitch(
                value: _mondayThursdayEnabled,
                isDark: isDark,
                enabled: _masterEnabled,
                onChanged: (val) async {
                  setState(() => _mondayThursdayEnabled = val);
                  await NotificationSettingsManager.setMondayThursdayFastingEnabled(
                    val,
                  );
                },
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صيام الإثنين والخميس',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'تنبيه مساء الأحد ومساء الأربعاء بالصيام',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF2ECE3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: isDark ? Colors.white70 : const Color(0xFF143427),
                  size: 20.sp,
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
            ),
          ),

          // صيام الأيام البيض
          Row(
            children: [
              _buildCustomSwitch(
                value: _whiteDaysEnabled,
                isDark: isDark,
                enabled: _masterEnabled,
                onChanged: (val) async {
                  setState(() => _whiteDaysEnabled = val);
                  await NotificationSettingsManager.setWhiteDaysFastingEnabled(
                    val,
                  );
                },
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  'صيام الأيام البيض (١٣، ١٤، ١٥)',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF2ECE3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: isDark ? Colors.white70 : const Color(0xFF143427),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
            ),
          ),

          // المناسبات الكبرى
          Row(
            children: [
              _buildCustomSwitch(
                value: _majorFastingEnabled,
                isDark: isDark,
                enabled: _masterEnabled,
                onChanged: (val) async {
                  setState(() => _majorFastingEnabled = val);
                  await NotificationSettingsManager.setMajorFastingEnabled(val);
                },
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المناسبات الكبرى (عرفة وعاشوراء)',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'تنبيه بصيام يوم عرفة وعاشوراء',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF2ECE3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.stars_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF143427),
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة سنن يوم الجمعة
  // ==============================================================
  Widget _buildFridaySunanCard(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildCustomSwitch(
                value: _fridayKahfEnabled,
                isDark: isDark,
                enabled: _masterEnabled,
                onChanged: (val) async {
                  setState(() => _fridayKahfEnabled = val);
                  await NotificationSettingsManager.setFridayKahfEnabled(val);
                },
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تذكير سورة الكهف صباح الجمعة',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'تنبيه الساعة ٨:٠٠ صباحاً لقراءة الكهف',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF2ECE3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF143427),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
            ),
          ),
          Row(
            children: [
              _buildCustomSwitch(
                value: _fridayHourResponseEnabled,
                isDark: isDark,
                enabled: _masterEnabled,
                onChanged: (val) async {
                  setState(() => _fridayHourResponseEnabled = val);
                  await NotificationSettingsManager.setFridayHourResponseEnabled(
                    val,
                  );
                },
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تذكير ساعة الاستجابة عصراً',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF143427),
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
              SizedBox(width: 10.w),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF2ECE3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.wb_twilight_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF143427),
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة ورد الختمة
  // ==============================================================
  Widget _buildKhatmahCard(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          _buildCustomSwitch(
            value: _khatmahReminderEnabled,
            isDark: isDark,
            enabled: _masterEnabled,
            onChanged: (val) async {
              setState(() => _khatmahReminderEnabled = val);
              await NotificationSettingsManager.setKhatmahReminderEnabled(val);
            },
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تذكير الورد القرآني اليومي',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'تنبيه يومي لمتابعة ورد ختم القرآن',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF2ECE3),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF143427),
              size: 20.sp,
            ),
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
    bool enabled = true,
  }) {
    return Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
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
}

