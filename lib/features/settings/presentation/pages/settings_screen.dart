import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/assets.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../../core/theme/cubit/theme_state.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../../../../core/widgets/modern_card.dart';
import '../../../../../core/widgets/section_title.dart';
import '../../../prayer_times/presentation/cubit/prayer_cubit.dart';
import '../../../quran/data/helpers/last_read_storage.dart';
import '../../../quran/data/helpers/reciter_storage_manager.dart';
import '../../../quran/data/repositories/audio_repo.dart';
import '../../../quran/presentation/pages/surah_detail_screen.dart';
import '../../../quran/presentation/widgets/reciter_selector_dialog.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentReciterName = 'عبد الباسط عبد الصمد';
  LastReadModel? _lastRead;
  String _prayerMethodName = 'الهيئة المصرية العامة للمساحة';
  int _prayerMethodId = 5;

  @override
  void initState() {
    super.initState();
    _loadAllPreferences();
    LastReadManager.lastReadUpdated.addListener(_loadLastRead);
  }

  @override
  void dispose() {
    LastReadManager.lastReadUpdated.removeListener(_loadLastRead);
    super.dispose();
  }

  Future<void> _loadAllPreferences() async {
    await Future.wait([
      _loadReciterName(),
      _loadLastRead(),
      _loadPrayerMethod(),
    ]);
  }

  Future<void> _loadReciterName() async {
    final name = await ReciterStorageManager.getSelectedReciterArabicName();
    if (mounted) {
      setState(() => _currentReciterName = name);
    }
  }

  Future<void> _loadLastRead() async {
    final lastRead = await LastReadManager.getLastRead(forceReload: true);
    if (mounted) {
      setState(() => _lastRead = lastRead);
    }
  }


  Future<void> _loadPrayerMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('prayer_calculation_method_name') ??
        'الهيئة المصرية العامة للمساحة';
    final id = prefs.getInt('prayer_calculation_method_id') ?? 5;
    if (mounted) {
      setState(() {
        _prayerMethodName = name;
        _prayerMethodId = id;
      });
    }
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.tryParse(d) ?? 0])
        .join('');
  }

  void _openReciterSelector() {
    showReciterSelector(context, getIt<AudioRepository>());
    // عند العودة نتأكد من تحديث اسم القارئ المختار
    Future.delayed(const Duration(milliseconds: 600), () {
      _loadReciterName();
    });
  }

  void _openResumeReading() {
    final surahId = _lastRead?.surahId ?? 1;
    final ayahNumber = _lastRead?.ayahNumber ?? 1;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(
          surahId: surahId,
          initialAyahNumber: ayahNumber,
        ),
      ),
    ).then((_) => _loadLastRead());
  }


  void _openPrayerMethodSelector(bool isDark) {
    final methods = [
      {'id': 5, 'name': 'الهيئة المصرية العامة للمساحة', 'country': 'مصر وإفريقيا'},
      {'id': 4, 'name': 'جامعة أم القرى (مكة المكرمة)', 'country': 'المملكة العربية السعودية والخليج'},
      {'id': 3, 'name': 'رابطة العالم الإسلامي', 'country': 'أوروبا والشرق الأقصى'},
      {'id': 2, 'name': 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)', 'country': 'أمريكا وكندا'},
      {'id': 1, 'name': 'جامعة العلوم الإسلامية بكراتشي', 'country': 'باكستان والهند'},
      {'id': 8, 'name': 'منطقة الخليج العربي', 'country': 'دول مجلس التعاون'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: 520.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(
              color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'طريقة حساب مواقيت الصلاة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF7ECE1) : const Color(0xFF38291D),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'اختر المعيار المعتمد في بلدك لحساب الفجر والعشاء',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.white54 : const Color(0xFF736152),
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: methods.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final item = methods[index];
                    final isSelected = item['id'] == _prayerMethodId;

                    return InkWell(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('prayer_calculation_method_id', item['id'] as int);
                        await prefs.setString('prayer_calculation_method_name', item['name'] as String);

                        if (mounted) {
                          setState(() {
                            _prayerMethodId = item['id'] as int;
                            _prayerMethodName = item['name'] as String;
                          });
                          // إعادة تحميل مواقيت الصلاة لتطبيق المعيار الجديد
                          try {
                            context.read<PrayerCubit>().loadPrayerTimes();
                          } catch (_) {}
                          Navigator.pop(ctx);
                        }
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF143427).withValues(alpha: isDark ? 0.35 : 0.08)
                              : (isDark ? const Color(0xFF21252A) : Colors.white),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF143427)
                                : (isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE)),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: item['id'] as int,
                              groupValue: _prayerMethodId,
                              activeColor: const Color(0xFF143427),
                              onChanged: (_) {},
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFF7ECE1) : const Color(0xFF38291D),
                                    ),
                                  ),
                                  Text(
                                    item['country'] as String,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: isDark ? Colors.white54 : const Color(0xFF736152),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  void _shareApp() {
    HapticFeedback.lightImpact();
    Share.share(
      'تطبيق صُحْبَة 🌿\n'
      'رفيقك اليومي للقرآن الكريم، الأذكار، مواقيت الصلاة وصيام السنن.\n'
      '«من دل على خير فله مثل أجر فاعله»\n'
      'حمل التطبيق الآن: https://play.google.com/store/apps/details?id=com.zbooma.suhbah',
    );
  }

  Future<void> _rateApp() async {
    final String urlString;
    if (Platform.isIOS) {
      urlString = 'https://apps.apple.com/app/id6740000000?action=write-review';
    } else {
      urlString = 'https://play.google.com/store/apps/details?id=com.zbooma.suhbah';
    }

    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (Platform.isAndroid) {
        final marketUri = Uri.parse('market://details?id=com.zbooma.suhbah');
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {}
  }

  void _openRatingDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
            side: BorderSide(
              color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF143427).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF143427),
                  size: 36,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'تقييم تطبيق صُحْبَة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF7ECE1) : const Color(0xFF38291D),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'جزاكم الله خيراً لدعمكم! تقييمكم يساعدنا في إيصال التطبيق للمزيد من المسلمين لوجه الله تعالى.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white60 : const Color(0xFF736152),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFD4941C),
                    size: 32,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF143427),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _rateApp();
                  },
                  child: const Text('تقييم في المتجر'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lastReadAyah = _lastRead?.ayahNumber ?? 1;
    final lastReadSurah = _lastRead?.surahNameArabic ?? 'سورة الفاتحة';
    final hasBookmark = _lastRead != null && !_lastRead!.isDefault;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
        body: Stack(
          children: [
            // الخلفية الفنية للمساجد والمآذن في الجزء العلوي
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

            SafeArea(
              child: Column(
                children: [
                  // شريط العنوان العلوي الصارم بموجب AGENTS.md
                  _buildTopAppBar(isDark),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      children: [
                        // بطاقة الهوية الخاصة بتطبيق صحبة (Brand Card)
                        _buildBrandHeaderCard(isDark),
                        SizedBox(height: 18.h),

                        // 1. قسم القرآن الكريم والتلاوة
                        const SectionTitle(title: 'القرآن الكريم والتلاوة'),
                        SizedBox(height: 10.h),
                        ModernCard(
                          child: Column(
                            children: [
                              SettingsTile(
                                icon: Icons.record_voice_over_rounded,
                                title: 'القارئ المفضل لتلاوة القرآن',
                                subtitle: _currentReciterName,
                                onTap: _openReciterSelector,
                              ),
                              _buildDivider(isDark),
                              SettingsTile(
                                icon: Icons.bookmark_added_rounded,
                                title: 'متابعة القراءة (آخر موضع)',
                                subtitle: hasBookmark
                                    ? '$lastReadSurah • آية ${_toArabicDigits(lastReadAyah)} (اضغط للمتابعة)'
                                    : 'اضغط للبدء من سورة الفاتحة',
                                onTap: _openResumeReading,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // 2. قسم مواقيت الصلاة والتنبيهات
                        const SectionTitle(title: 'مواقيت الصلاة والتنبيهات'),
                        SizedBox(height: 10.h),
                        ModernCard(
                          child: Column(
                            children: [
                              SettingsTile(
                                icon: Icons.notifications_active_outlined,
                                title: 'إعدادات الأذان والتنبيهات',
                                subtitle: 'الأذان، التنبيه المسبق، صيام السنن وختمة القرآن',
                                onTap: () => context.push(AppRoutes.notificationSettings),
                              ),
                              _buildDivider(isDark),
                              SettingsTile(
                                icon: Icons.calculate_outlined,
                                title: 'طريقة حساب مواقيت الصلاة',
                                subtitle: _prayerMethodName,
                                onTap: () => _openPrayerMethodSelector(isDark),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // 3. قسم المظهر
                        const SectionTitle(title: 'المظهر'),
                        SizedBox(height: 10.h),
                        ModernCard(
                          child: BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, themeState) {
                              final activeDark = themeState.themeMode == ThemeMode.dark;
                              return SettingsTile(
                                icon: activeDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                title: 'الوضع الليلي (المظهر الداكن)',
                                subtitle: activeDark
                                    ? 'المظهر الداكن مفعّل للقراءة الهادئة ليلاً'
                                    : 'المظهر الفاتح مفعّل',
                                trailing: Switch(
                                  value: activeDark,
                                  activeTrackColor: const Color(0xFF143427),
                                  activeThumbColor: const Color(0xFFC7A87A),
                                  inactiveTrackColor: isDark ? Colors.white12 : const Color(0xFFE5DCD1),
                                  inactiveThumbColor: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                                  onChanged: (value) {
                                    context.read<ThemeCubit>().toggleTheme();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // 4. قسم الدعم والمشاركة
                        const SectionTitle(title: 'المشاركة والدعم والمعلومات'),
                        SizedBox(height: 10.h),
                        ModernCard(
                          child: Column(
                            children: [
                              SettingsTile(
                                icon: Icons.share_rounded,
                                title: 'مشاركة التطبيق (صدقة جارية)',
                                subtitle: 'الدال على الخير كفاعله، انشر التطبيق لمن تحب',
                                onTap: _shareApp,
                              ),
                              _buildDivider(isDark),
                              SettingsTile(
                                icon: Icons.star_rate_rounded,
                                title: 'تقييم تطبيق صُحْبَة',
                                subtitle: 'دعمك لنا بالتقييم يسهم في نشر التطبيق لوجه الله',
                                onTap: () => _openRatingDialog(isDark),
                              ),
                              _buildDivider(isDark),
                              SettingsTile(
                                icon: Icons.info_outline_rounded,
                                title: 'عن تطبيق صُحْبَة',
                                subtitle: 'رسالة التطبيق ورؤيتنا ومميزاته',
                                onTap: () => context.push(AppRoutes.about),
                              ),
                              _buildDivider(isDark),
                              SettingsTile(
                                icon: Icons.privacy_tip_outlined,
                                title: 'سياسة الخصوصية',
                                subtitle: 'التزامنا الكامل بأمان بياناتك وخصوصيتك',
                                onTap: () => context.push(AppRoutes.privacyPolicy),
                              ),
                              _buildDivider(isDark),
                              SettingsTile(
                                icon: Icons.help_outline_rounded,
                                title: 'المساعدة والإرشادات',
                                subtitle: 'الأسئلة الشائعة وإرشادات الاستخدام',
                                onTap: () => context.push(AppRoutes.helpSupport),
                              ),
                            ],
                          ),
                        ),

                        // 5. دعاء ختامي وصدقة جارية
                        _buildFooterDuaa(isDark),
                        SizedBox(height: 20.h),
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
  // شريط العنوان العلوي المتوافق بدقة مع AGENTS.md
  // ==============================================================
  Widget _buildTopAppBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // سهم الرجوع في أقصى اليمين (في الواجهة العربية) ويشير حصراً إلى اليسار (<)
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF38291D),
              size: 20.sp,
            ),
            tooltip: 'رجوع',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),

          // العنوان في المنتصف
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الإعدادات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF38291D),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 36.w,
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF143427),
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
              ],
            ),
          ),

          // عنصر موازن يمين/يسار
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة الهوية الخاصة بتطبيق صحبة (Brand Banner)
  // ==============================================================
  Widget _buildBrandHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F4838),
            Color(0xFF143427),
            Color(0xFF0F2B1F),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0xFF2E5E4A).withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B1F).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFEADCC8).withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Color(0xFFEADCC8),
              size: 32,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: [
                    Text(
                      'تطبيق صُحْبَة',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFAF5ED),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEADCC8).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFFEADCC8).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'الإصدار 1.0.0',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: const Color(0xFFFAF5ED),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'رفيقك اليومي للقرآن الكريم، الأذكار ومواقيت الصلاة',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFEADBCE).withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // الفاصل بين العناصر في البطاقة
  // ==============================================================
  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        height: 1.h,
        thickness: 0.8,
        color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
      ),
    );
  }

  // ==============================================================
  // بطاقة الدعاء والصدقة الجارية
  // ==============================================================
  Widget _buildFooterDuaa(bool isDark) {
    return Container(
      margin: EdgeInsets.only(top: 14.h, bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
        ),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            children: [
              Icon(
                Icons.volunteer_activism_rounded,
                color: const Color(0xFF143427),
                size: 20.sp,
              ),
              Text(
                'صدقة جارية لوجه الله تعالى',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF7ECE1) : const Color(0xFF38291D),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'اللهم اجعل هذا العمل خالصاً لوجهك الكريم وصدقة جارية لنا ولكم ولوالدينا ولمن ساهم في نشره',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontFamily: 'Amiri',
              color: isDark ? const Color(0xFFC7B7A6) : const Color(0xFF736152),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
