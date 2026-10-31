// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import 'package:islamic_app/core/widgets/custom_error_widget.dart';
import '../../data/helpers/last_read_storage.dart';
import '../../data/models/quran_models.dart';
import '../../data/repositories/audio_repo.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import 'ayah_rosette.dart';
import 'ayah_share_bottom_sheet.dart';
import 'mushaf_bottom_cartouche.dart';
import 'mushaf_surah_header.dart';
import 'quran_auto_scroll_sidebar.dart';
import 'reciter_selector_dialog.dart';
import 'surah_loading_shimmer.dart';
import 'surah_download_bottom_sheet.dart';
import '../../data/services/surah_audio_download_service.dart';
import '../pages/tafsir_screen.dart';

class SurahDetailViewBody extends StatefulWidget {
  final int surahId;
  final int? initialAyahNumber;

  const SurahDetailViewBody({
    super.key,
    required this.surahId,
    this.initialAyahNumber,
  });

  @override
  State<SurahDetailViewBody> createState() => _SurahDetailViewBodyState();
}

class _SurahDetailViewBodyState extends State<SurahDetailViewBody> {
  static const double kSurahFontSize = 22.5;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  bool _hasScrolledToTarget = false;
  int? _resolvedTargetAyah;

  @override
  void initState() {
    super.initState();
    _resolveInitialTarget();
  }

  Future<void> _resolveInitialTarget() async {
    if (widget.initialAyahNumber != null && widget.initialAyahNumber! > 0) {
      _resolvedTargetAyah = widget.initialAyahNumber;
      return;
    }

    // إذا لم يتم تحديد آية في المعطيات، نفحص إن كان للمستخدم موضع قراءة سابق في هذه السورة
    final lastRead = await LastReadManager.getLastRead();
    if (lastRead.surahId == widget.surahId &&
        !lastRead.isDefault &&
        lastRead.ayahNumber > 1) {
      if (mounted) {
        setState(() {
          _resolvedTargetAyah = lastRead.ayahNumber;
        });
      }
    }
  }

  void _scrollToTargetAyah() {
    if (_hasScrolledToTarget) return;
    final target = _resolvedTargetAyah;
    if (target == null || target <= 1) {
      _hasScrolledToTarget = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _ayahKeys[target];
      if (key?.currentContext != null) {
        _hasScrolledToTarget = true;
        Scrollable.ensureVisible(
          key!.currentContext!,
          alignment: 0.15,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      } else {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted || _hasScrolledToTarget) return;
          final key = _ayahKeys[target];
          if (key?.currentContext != null) {
            _hasScrolledToTarget = true;
            Scrollable.ensureVisible(
              key!.currentContext!,
              alignment: 0.15,
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeInOutCubic,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    getIt<AudioCubit>().stop();
    _scrollController.dispose();
    super.dispose();
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join('');
  }

  static int getJuzForSurah(int id) {
    const juzMap = [
      1, 1, 3, 4, 6, 7, 8, 9, 10, 11, 11, 12, 13, 13, 14, 14, 15, 15, 16, 16,
      17, 17, 18, 18, 18, 19, 19, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23,
      23, 24, 24, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27,
      27, 28, 28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29,
      29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
      30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
      30, 30, 30, 30,
    ];
    if (id >= 1 && id <= juzMap.length) {
      return juzMap[id - 1];
    }
    return 30;
  }

  static String getJuzName(int juzNum) {
    const names = [
      'الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس', 'السابع', 'الثامن',
      'التاسع', 'العاشر', 'الحادي عشر', 'الثاني عشر', 'الثالث عشر', 'الرابع عشر',
      'الخامس عشر', 'السادس عشر', 'السابع عشر', 'الثامن عشر', 'التاسع عشر', 'العشرون',
      'الحادي والعشرون', 'الثاني والعشرون', 'الثالث والعشرون', 'الرابع والعشرون',
      'الخامس والعشرون', 'السادس والعشرون', 'السابع والعشرون', 'الثامن والعشرون',
      'التاسع والعشرون', 'الثلاثون',
    ];
    if (juzNum >= 1 && juzNum <= names.length) {
      return names[juzNum - 1];
    }
    return '$juzNum';
  }

  String _cleanVerseText(int surahId, int verseId, String rawText) {
    if (surahId != 1 && verseId == 1) {
      const basmalahPrefixes = [
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      ];
      String text = rawText.trim();
      for (final b in basmalahPrefixes) {
        if (text.startsWith(b)) {
          text = text.substring(b.length).trim();
          break;
        }
      }
      return text;
    }
    return rawText.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        if (state is QuranLoading || state is QuranInitial) {
          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF1E2125)
                : const Color(0xFFFAF5ED),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeaderSkeleton(context, isDark),
                  const Expanded(child: SurahsloadingShimmer()),
                ],
              ),
            ),
          );
        }

        if (state is QuranError) {
          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF1E2125)
                : const Color(0xFFFAF5ED),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  context.read<AudioCubit>().stop();
                  Navigator.pop(context);
                },
              ),
            ),
            body: CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<QuranCubit>().loadSurahById(widget.surahId);
              },
            ),
          );
        }

        if (state is SurahDetailLoaded) {
          final surah = state.surah;
          final cleanName = surah.name
              .replaceAll('سُورَةُ ', '')
              .replaceAll('سورة ', '')
              .trim();

          // التمرير الفوري لآخر موضع قراءة
          _scrollToTargetAyah();

          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF1E2125)
                : const Color(0xFFFAF5ED),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // شريط الرأس الموحد
                      _buildHeader(context, surah, cleanName, isDark),

                      // شريط بيانات السورة ونطاق الآيات
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF143427).withValues(
                            alpha: isDark ? 0.25 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(
                              0xFF143427,
                            ).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 16.sp,
                              color: isDark
                                  ? Colors.amberAccent
                                  : const Color(0xFF143427),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'سورة $cleanName (آية ١ إلى ${_toArabicNumber(surah.totalVerses)}) • الجزء ${getJuzName(getJuzForSurah(surah.id))}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF143427),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // بطاقة المصحف الشريف للآيات المتصلة
                      Expanded(
                        child: _buildVersesList(surah, cleanName, isDark),
                      ),
                    ],
                  ),

                  // الشريط الجانبي للتمرير التلقائي
                  QuranAutoScrollSidebar(
                    scrollController: _scrollController,
                    onPlayStateChanged: (_) {},
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildAudioFloatingButton(
              context,
              surah,
              cleanName,
              isDark,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                context.read<AudioCubit>().stop();
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Text(
                'سورة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.brownPrimary,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SurahModel surah,
    String cleanName,
    bool isDark,
  ) {
    final juzNum = getJuzForSurah(surah.id);
    final juzText = getJuzName(juzNum);
    final revelationText = surah.type.toLowerCase() == 'meccan'
        ? 'مكية'
        : 'مدنية';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCF9F3),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF383E46) : const Color(0xFFEFE8DA),
            width: 1,
          ),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. زر الرجوع على اليمين دائماً وبسهم لليسار طبقاً لقواعد التصميم
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark
                    ? const Color(0xFFF7ECE1)
                    : const Color(0xFF38291B),
                size: 20.sp,
              ),
              onPressed: () {
                context.read<AudioCubit>().stop();
                Navigator.pop(context);
              },
            ),

            // 2. العنوان والتفاصيل في المنتصف
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'سورة $cleanName',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFF7ECE1)
                          : const Color(0xFF38291B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'الجزء $juzText • $revelationText • ${_toArabicNumber(surah.totalVerses)} آية',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF143427),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // 3. على اليسار: زر تحميل السورة وزر اختيار القارئ
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر تحميل السورة للاستماع بدون إنترنت ومؤشر التنزيل
                ValueListenableBuilder<int>(
                  valueListenable: SurahAudioDownloadService().statusNotifier,
                  builder: (context, _, __) {
                    final isDownloaded = SurahAudioDownloadService()
                        .isSurahLocallyDownloaded(surah.id);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          SurahDownloadBottomSheet.show(
                            context,
                            surahId: surah.id,
                            surahName: 'سورة $cleanName',
                          );
                        },
                        borderRadius: BorderRadius.circular(50.r),
                        child: Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: isDownloaded
                                ? (isDark
                                    ? const Color(0xFF1E382B)
                                    : const Color(0xFFE8F1EC))
                                : (isDark
                                    ? const Color(0xFF21252A)
                                    : const Color(0xFFF7EFE4)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDownloaded
                                  ? const Color(0xFF2E7D5E)
                                  : (isDark
                                      ? const Color(0xFF383E46)
                                      : const Color(0xFFEADBCE)),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.04,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isDownloaded
                                ? Icons.check_circle_rounded
                                : Icons.download_for_offline_rounded,
                            color: isDownloaded
                                ? const Color(0xFF2E7D5E)
                                : (isDark
                                    ? const Color(0xFFF7ECE1)
                                    : const Color(0xFF143427)),
                            size: 20.sp,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8.w),
                // زر اختيار القارئ المتناسق مع الثيمات
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      showReciterSelector(context, getIt<AudioRepository>());
                    },
                    borderRadius: BorderRadius.circular(50.r),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF21252A)
                            : const Color(0xFFF7EFE4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF383E46)
                              : const Color(0xFFEADBCE),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.04,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.record_voice_over_rounded,
                        color: isDark
                            ? const Color(0xFFF7ECE1)
                            : const Color(0xFF143427),
                        size: 19.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersesList(SurahModel surah, String cleanName, bool isDark) {
    final bool startsAtFirstAyah = true;
    final int sId = surah.id;

    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, audioState) {
        final audioCubit = context.read<AudioCubit>();

        return ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: 90.h,
            top: 8.h,
            left: 12.w,
            right: 12.w,
          ),
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 18.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF282C32)
                    : const Color(0xFFFCFAF4),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF383E46)
                      : const Color(0xFFC79E53).withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  MushafSurahHeader(
                    surahId: sId,
                    surahName: 'سورة $cleanName',
                    totalVerses: surah.totalVerses,
                  ),
                  if (startsAtFirstAyah && sId != 9 && sId != 1) ...[
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 10.h),
                      child: Center(
                        child: Text(
                          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFE5C992)
                                : const Color(0xFF261D16),
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          for (final verse in surah.verses) ...[
                            () {
                              final bool isTargetAyah =
                                  (_resolvedTargetAyah != null &&
                                      _resolvedTargetAyah != 1 &&
                                      verse.id == _resolvedTargetAyah);

                              final isPlayingThis =
                                  (audioState is AudioPlayingAyah &&
                                      audioState.currentSurahId == sId &&
                                      audioState.currentAyahNumber ==
                                          verse.id) ||
                                  (audioCubit.currentAyahNumber == verse.id &&
                                      audioCubit.isPlaying);

                              return TextSpan(
                                children: [
                                  if (isTargetAyah)
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 6.w,
                                          right: 4.w,
                                          bottom: 3.h,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 9.w,
                                          vertical: 3.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF143427),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF143427,
                                              ).withValues(alpha: 0.3),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.bookmark_added_rounded,
                                              size: 13.sp,
                                              color: Colors.amberAccent,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'آخر موضع قراءة (آية ${verse.id})',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'Amiri',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  TextSpan(
                                    text:
                                        '${_cleanVerseText(sId, verse.id, verse.text)} ',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: kSurahFontSize.sp,
                                      height: 2.15,
                                      fontWeight: FontWeight.bold,
                                      color: isPlayingThis
                                          ? const Color(0xFF143427)
                                          : (isTargetAyah)
                                          ? (isDark
                                              ? const Color(0xFF81C784)
                                              : const Color(0xFF143427))
                                          : (isDark
                                              ? Colors.white
                                              : const Color(0xFF1E1711)),
                                      backgroundColor: isPlayingThis
                                          ? const Color(
                                              0xFF143427,
                                            ).withValues(alpha: 0.18)
                                          : (isTargetAyah)
                                          ? const Color(
                                              0xFF143427,
                                            ).withValues(alpha: 0.14)
                                          : Colors.transparent,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _showAyahOptions(
                                        context,
                                        verse,
                                        'سورة $cleanName',
                                        sId,
                                        surah.totalVerses,
                                      ),
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: KeyedSubtree(
                                      key: _ayahKeys.putIfAbsent(
                                        verse.id,
                                        () => GlobalKey(),
                                      ),
                                      child: GestureDetector(
                                        onTap: () => _showAyahOptions(
                                          context,
                                          verse,
                                          'سورة $cleanName',
                                          sId,
                                          surah.totalVerses,
                                        ),
                                        child: AyahMedallion(
                                          ayahNumber: verse.id,
                                          fontSize: kSurahFontSize,
                                          isDark: isDark,
                                          isPlaying:
                                              isPlayingThis || isTargetAyah,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' '),
                                ],
                              );
                            }(),
                          ],
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),

                  SizedBox(height: 12.h),
                  MushafBottomCartouche(
                    text:
                        '١ - ${_toArabicNumber(surah.totalVerses)} / ${_toArabicNumber(surah.totalVerses)}',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAyahOptions(
    BuildContext context,
    VerseModel verse,
    String surahName,
    int surahId,
    int totalVerses,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioCubit = context.read<AudioCubit>();
    final actionItemColor = isDark ? Colors.white70 : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF282C32) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              '$surahName • الآية ${_toArabicNumber(verse.id)}',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.goldenPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${verse.text} ﴿${_toArabicNumber(verse.id)}﴾',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16.sp,
                height: 1.8,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const Divider(height: 24, thickness: 0.6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionItem(
                    icon: Icons.play_circle_fill_rounded,
                    label: 'استماع',
                    color: actionItemColor,
                    onTap: () {
                      Navigator.pop(bottomContext);
                      LastReadManager.saveLastRead(
                        surahId: surahId,
                        ayahNumber: verse.id,
                        surahName: surahName,
                        surahNameArabic: surahName,
                        totalVerses: totalVerses,
                      );
                      audioCubit.playAyah(
                        surahId,
                        verse.id,
                        totalVerses: totalVerses,
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.menu_book_rounded,
                    label: 'تفسير',
                    color: actionItemColor,
                    onTap: () {
                      Navigator.pop(bottomContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TafsirScreen(
                            surahId: surahId,
                            ayahNumber: verse.id,
                            surahName: surahName,
                            initialArabicText: verse.text,
                            totalVerses: totalVerses,
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: SurahAudioDownloadService().statusNotifier,
                    builder: (context, _, __) {
                      final isDownloaded = SurahAudioDownloadService()
                          .isSurahLocallyDownloaded(surahId);
                      return _buildActionItem(
                        icon: isDownloaded
                            ? Icons.check_circle_rounded
                            : Icons.download_for_offline_rounded,
                        label: isDownloaded ? 'السورة محملة' : 'تحميل السورة',
                        color: isDownloaded
                            ? const Color(0xFF2E7D5E)
                            : actionItemColor,
                        onTap: () {
                          Navigator.pop(bottomContext);
                          SurahDownloadBottomSheet.show(
                            context,
                            surahId: surahId,
                            surahName: surahName,
                          );
                        },
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.bookmark_add_rounded,
                    label: 'حفظ علامة',
                    color: actionItemColor,
                    onTap: () async {
                      Navigator.pop(bottomContext);
                      await LastReadManager.saveLastRead(
                        surahId: surahId,
                        ayahNumber: verse.id,
                        surahName: surahName,
                        surahNameArabic: surahName,
                        totalVerses: totalVerses,
                      );
                      setState(() {
                        _resolvedTargetAyah = verse.id;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.bookmark_added_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'تم حفظ $surahName (الآية ${verse.id}) في متابعة القراءة',
                                  style: TextStyle(fontSize: 13.5.sp),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF143427),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.copy_rounded,
                    label: 'نسخ',
                    color: actionItemColor,
                    onTap: () {
                      Navigator.pop(bottomContext);
                      Clipboard.setData(
                        ClipboardData(text: '${verse.text} ﴿${verse.id}﴾'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('تم نسخ الآية الكريمة'),
                          backgroundColor: AppColors.goldenPrimary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.share_rounded,
                    label: 'مشاركة',
                    color: actionItemColor,
                    onTap: () {
                      Navigator.pop(bottomContext);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => AyahShareBottomSheet(
                          arabicText: verse.text,
                          translation: verse.translation,
                          surahNumber: surahId,
                          ayahNumber: verse.id,
                          surahName: surahName,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioFloatingButton(
    BuildContext context,
    SurahModel surah,
    String cleanName,
    bool isDark,
  ) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final audioCubit = context.read<AudioCubit>();
        final bool isThisSurahActive =
            (audioCubit.currentSurahId == surah.id);
        final bool isPlaying = isThisSurahActive && audioCubit.isPlaying;
        final bool isPaused = isThisSurahActive && audioCubit.isPaused;
        final bool isCompletedWithNextAyah = isThisSurahActive &&
            state is AudioCompleted &&
            audioCubit.currentAyahNumber != null &&
            audioCubit.currentAyahNumber! < surah.totalVerses;

        IconData icon;
        String label;

        if (isPlaying) {
          icon = Icons.pause_circle_filled_rounded;
          label = audioCubit.currentAyahNumber != null
              ? 'إيقاف مؤقت (الآية ${_toArabicNumber(audioCubit.currentAyahNumber!)} من سورة $cleanName)'
              : 'إيقاف مؤقت (سورة $cleanName)';
        } else if (isPaused) {
          icon = Icons.play_circle_fill_rounded;
          label = audioCubit.currentAyahNumber != null
              ? 'استئناف الاستماع (الآية ${_toArabicNumber(audioCubit.currentAyahNumber!)} من سورة $cleanName)'
              : 'استئناف الاستماع (سورة $cleanName)';
        } else if (isCompletedWithNextAyah) {
          final nextAyah = audioCubit.currentAyahNumber! + 1;
          icon = Icons.play_circle_fill_rounded;
          label =
              'استئناف الاستماع (الآية ${_toArabicNumber(nextAyah)} من سورة $cleanName)';
        } else {
          icon = Icons.play_arrow_rounded;
          label = 'تشغيل سورة $cleanName';
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                onTap: () {
                  if (isPlaying) {
                    audioCubit.pause();
                  } else if (isPaused || isCompletedWithNextAyah) {
                    audioCubit.resume();
                  } else {
                    audioCubit.playSurah(
                      surah.id,
                      title: 'سورة $cleanName',
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF143427),
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ValueListenableBuilder<int>(
                valueListenable: SurahAudioDownloadService().statusNotifier,
                builder: (context, _, __) {
                  final isDownloaded = SurahAudioDownloadService()
                      .isSurahLocallyDownloaded(surah.id);
                  return GestureDetector(
                    onTap: () {
                      SurahDownloadBottomSheet.show(
                        context,
                        surahId: surah.id,
                        surahName: 'سورة $cleanName',
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(11.h),
                      decoration: BoxDecoration(
                        color: isDownloaded
                            ? (isDark
                                ? const Color(0xFF1E382B)
                                : const Color(0xFFE8F1EC))
                            : (isDark
                                ? const Color(0xFF282C32)
                                : Colors.white),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isDownloaded
                              ? const Color(0xFF2E7D5E)
                              : const Color(0xFF143427),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isDownloaded
                            ? Icons.check_circle_rounded
                            : Icons.download_for_offline_rounded,
                        color: isDownloaded
                            ? const Color(0xFF2E7D5E)
                            : const Color(0xFF143427),
                        size: 22.sp,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}
