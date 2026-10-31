// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../data/models/quran_models.dart';
import '../../data/repositories/audio_repo.dart';
import '../../data/repositories/quran_repo.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../widgets/audio_error_listener.dart';
import '../widgets/ayah_rosette.dart';
import '../widgets/ayah_share_bottom_sheet.dart';
import '../widgets/mushaf_bottom_cartouche.dart';
import '../widgets/mushaf_surah_header.dart';
import '../widgets/quran_auto_scroll_sidebar.dart';
import '../widgets/reciter_selector_dialog.dart';
import '../widgets/surah_loading_shimmer.dart';
import 'tafsir_screen.dart';
import '../widgets/surah_download_bottom_sheet.dart';
import '../../data/services/surah_audio_download_service.dart';
import '../../data/helpers/last_read_storage.dart';
import '../../../../../core/widgets/custom_error_widget.dart';

class QuranSectionDetailScreen extends StatefulWidget {
  final int? juzNumber;
  final int? hizbNumber;
  final String? customRangeDescription;

  const QuranSectionDetailScreen.juz({
    super.key,
    required this.juzNumber,
    this.customRangeDescription,
  }) : hizbNumber = null;

  const QuranSectionDetailScreen.hizb({
    super.key,
    required this.hizbNumber,
    this.customRangeDescription,
  }) : juzNumber = null;

  bool get isJuz => juzNumber != null;
  int get sectionNumber => isJuz ? juzNumber! : hizbNumber!;

  @override
  State<QuranSectionDetailScreen> createState() =>
      _QuranSectionDetailScreenState();
}

class _QuranSectionDetailScreenState extends State<QuranSectionDetailScreen> {
  @override
  void dispose() {
    getIt<AudioCubit>().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final cubit = QuranCubit(getIt<QuranRepository>());
              if (widget.isJuz) {
                cubit.loadJuzDetail(widget.juzNumber!);
              } else {
                cubit.loadHizbDetail(widget.hizbNumber!);
              }
              return cubit;
            },
          ),
          BlocProvider.value(value: getIt<AudioCubit>()),
        ],
        child: AudioErrorListener(
          child: _QuranSectionViewBody(
            isJuz: widget.isJuz,
            sectionNumber: widget.sectionNumber,
            customRangeDescription: widget.customRangeDescription,
          ),
        ),
      ),
    );
  }
}

class _QuranSectionViewBody extends StatefulWidget {
  final bool isJuz;
  final int sectionNumber;
  final String? customRangeDescription;

  const _QuranSectionViewBody({
    required this.isJuz,
    required this.sectionNumber,
    this.customRangeDescription,
  });

  @override
  State<_QuranSectionViewBody> createState() => _QuranSectionViewBodyState();
}

class _QuranSectionViewBodyState extends State<_QuranSectionViewBody> {
  static const double kSectionFontSize = 22.5;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
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
                final cubit = context.read<QuranCubit>();
                if (widget.isJuz) {
                  cubit.loadJuzDetail(widget.sectionNumber);
                } else {
                  cubit.loadHizbDetail(widget.sectionNumber);
                }
              },
            ),
          );
        }

        if (state is QuranSectionDetailLoaded) {
          final section = state.section;

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
                      _buildHeader(context, section, isDark),

                      // شريط تحديد نطاق الورد من سورة كذا إلى سورة كذا
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF143427).withValues(alpha: isDark ? 0.25 : 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF143427).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 16.sp,
                              color: isDark ? Colors.amberAccent : const Color(0xFF143427),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                widget.customRangeDescription ?? section.subtitle,
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

                      // قائمة آيات الجزء أو الحزب
                      Expanded(child: _buildVersesList(section, isDark)),
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
              section,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isJuz
                        ? 'الجزء ${_toArabicNumber(widget.sectionNumber)}'
                        : 'الحزب ${_toArabicNumber(widget.sectionNumber)}',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.brownPrimary,
                    ),
                  ),
                  if (widget.customRangeDescription != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      widget.customRangeDescription!,
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
                ],
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
    QuranSectionModel section,
    bool isDark,
  ) {
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
            // 1. زر الرجوع على اليمين دائماً
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
                    section.title,
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
                    '${widget.customRangeDescription ?? section.subtitle} • ${_toArabicNumber(section.verses.length)} آية',
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

            // 3. زر اختيار القارئ المتناسق مع الثيمات
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
      ),
    );
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

  void _showAyahOptions(
    BuildContext context,
    VerseModel verse,
    String surahName,
    int surahId, [
    int? totalVerses,
  ]) {
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
                      audioCubit.playAyah(surahId, verse.id);
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
                      final formattedSurahName = surahName.startsWith('سورة')
                          ? surahName
                          : 'سورة $surahName';
                      await LastReadManager.saveLastRead(
                        surahId: surahId,
                        ayahNumber: verse.id,
                        surahName: formattedSurahName,
                        surahNameArabic: formattedSurahName,
                        totalVerses: totalVerses,
                      );
                      if (context.mounted) {
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
                                    'تم حفظ $formattedSurahName (الآية ${verse.id}) في متابعة القراءة',
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
                      }
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.copy_rounded,
                    label: 'نسخ',
                    color: isDark ? Colors.white70 : Colors.black87,
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
                    color: isDark ? Colors.white70 : Colors.black87,
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

  Widget _buildVersesList(QuranSectionModel section, bool isDark) {
    final firstVerse = section.verses.isNotEmpty ? section.verses.first : null;
    final lastVerse = section.verses.isNotEmpty ? section.verses.last : null;

    // تجميع الآيات حسب السور لعرضها متصلة بأسلوب المصحف الشريف
    final Map<int, List<VerseModel>> groupedVerses = {};
    for (final v in section.verses) {
      final sId = v.surahId ?? 1;
      groupedVerses.putIfAbsent(sId, () => []).add(v);
    }

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
            for (final entry in groupedVerses.entries) ...[
              () {
                final sId = entry.key;
                final sVerses = entry.value;
                final surahInfo = section.surahsMap[sId];
                final surahName =
                    surahInfo?.name ?? sVerses.first.surahNameArabic ?? 'سورة';
                final totalVerses = surahInfo?.totalVerses ?? sVerses.length;
                final bool startsAtFirstAyah = sVerses.first.id == 1;

                return Container(
                  margin: EdgeInsets.only(bottom: 18.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
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
                        surahName: surahName,
                        totalVerses: totalVerses,
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
                              for (final verse in sVerses) ...[
                                () {
                                  final bool isFirstAyahOfSection =
                                      (firstVerse != null &&
                                          verse.surahId == firstVerse.surahId &&
                                          verse.id == firstVerse.id);
                                  final bool isLastAyahOfSection =
                                      (lastVerse != null &&
                                          verse.surahId == lastVerse.surahId &&
                                          verse.id == lastVerse.id);

                                  final isPlayingThis =
                                      (audioState is AudioPlayingAyah &&
                                          audioState.currentSurahId == sId &&
                                          audioState.currentAyahNumber ==
                                              verse.id) ||
                                      (audioCubit.currentAyahNumber ==
                                              verse.id &&
                                          audioCubit.isPlaying);

                                  return TextSpan(
                                    children: [
                                      if (isFirstAyahOfSection)
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              left: 6.w,
                                              right: 3.w,
                                              bottom: 2.h,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF143427),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF143427)
                                                      .withValues(alpha: 0.25),
                                                  blurRadius: 4,
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
                                                  'بداية الورد (آية ${verse.id})',
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
                                          fontSize: kSectionFontSize.sp,
                                          height: 2.15,
                                          fontWeight: FontWeight.bold,
                                          color: isPlayingThis
                                              ? const Color(0xFF143427)
                                              : (isFirstAyahOfSection ||
                                                      isLastAyahOfSection)
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
                                              : (isFirstAyahOfSection ||
                                                      isLastAyahOfSection)
                                                  ? const Color(0xFF143427)
                                                      .withValues(alpha: 0.12)
                                                  : Colors.transparent,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => _showAyahOptions(
                                            context,
                                            verse,
                                            surahName,
                                            sId,
                                            totalVerses,
                                          ),
                                      ),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          onTap: () => _showAyahOptions(
                                            context,
                                            verse,
                                            surahName,
                                            sId,
                                            totalVerses,
                                          ),
                                          child: AyahMedallion(
                                            ayahNumber: verse.id,
                                            fontSize: kSectionFontSize,
                                            isDark: isDark,
                                            isPlaying: isPlayingThis ||
                                                isFirstAyahOfSection ||
                                                isLastAyahOfSection,
                                          ),
                                        ),
                                      ),
                                      if (isLastAyahOfSection)
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              right: 6.w,
                                              left: 3.w,
                                              bottom: 2.h,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF143427),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF143427)
                                                      .withValues(alpha: 0.25),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.flag_rounded,
                                                  size: 13.sp,
                                                  color: Colors.amberAccent,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  'نهاية الورد (آية ${verse.id})',
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
                            '${sVerses.first.id} - ${sVerses.last.id} / $totalVerses',
                        isDark: isDark,
                      ),
                    ],
                  ),
                );
              }(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAudioFloatingButton(
    BuildContext context,
    QuranSectionModel section,
    bool isDark,
  ) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final audioCubit = context.read<AudioCubit>();
        final bool isSectionActive =
            audioCubit.activeQueueTitle == section.title;
        final bool isPlaying = isSectionActive && audioCubit.isPlaying;
        final bool isPaused = isSectionActive && audioCubit.isPaused;

        final firstV = section.verses.isNotEmpty ? section.verses.first : null;
        final lastV = section.verses.isNotEmpty ? section.verses.last : null;

        String currentSurahSuffix = '';
        if (isSectionActive &&
            audioCubit.currentSurahId != null &&
            section.surahsMap.containsKey(audioCubit.currentSurahId)) {
          final sName = section.surahsMap[audioCubit.currentSurahId]?.name;
          if (sName != null && sName.isNotEmpty) {
            currentSurahSuffix = ' ($sName)';
          }
        }

        IconData icon;
        String label;

        if (isPlaying) {
          icon = Icons.pause_circle_filled_rounded;
          label = 'إيقاف مؤقت$currentSurahSuffix';
        } else if (isPaused) {
          icon = Icons.play_circle_fill_rounded;
          label = 'استئناف الاستماع$currentSurahSuffix';
        } else {
          icon = Icons.play_arrow_rounded;
          if (firstV != null && lastV != null) {
            label = 'تشغيل ${section.title} (آية ${firstV.id} إلى ${lastV.id})';
          } else {
            label = 'تشغيل ${section.title}';
          }
        }

        return GestureDetector(
          onTap: () {
            if (isPlaying) {
              audioCubit.pause();
            } else if (isPaused) {
              audioCubit.resume();
            } else {
              // استخراج أرقام السور الموجودة في هذا الجزء لتشغيلها بتلاوة الشيخ مشاري العفاسي
              final List<int> surahIds = [];
              for (final v in section.verses) {
                final sId = v.surahId;
                if (sId != null && !surahIds.contains(sId)) {
                  surahIds.add(sId);
                }
              }
              if (surahIds.isEmpty) surahIds.add(1);

              final rangeDesc = (firstV != null && lastV != null)
                  ? 'من سورة ${firstV.surahNameArabic ?? ""} (آية ${firstV.id}) إلى سورة ${lastV.surahNameArabic ?? ""} (آية ${lastV.id})'
                  : section.subtitle;

              audioCubit.playSectionSurahAudio(
                surahIds: surahIds,
                title: section.title,
                rangeDescription: rangeDesc,
                firstAyah: firstV?.id,
                lastAyah: lastV?.id,
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 11.h),
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
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 22.sp),
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
