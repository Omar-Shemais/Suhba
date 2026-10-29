// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../cubit/audio_cubit.dart';
import '../../data/helpers/quran_reading_mode_helper.dart';
import 'quran_reading_mode_sheet.dart';
import 'surah_download_bottom_sheet.dart';
import '../../data/services/surah_audio_download_service.dart';

class SurahReaderTopBar extends StatelessWidget {
  final String surahName;
  final int surahId;
  final String type; // 'meccan' or 'medinan'
  final QuranScrollMode currentMode;
  final ValueChanged<QuranScrollMode> onModeChanged;
  final VoidCallback onToggleAutoScroll;
  final bool isAutoScrolling;
  final bool showTranslation;
  final ValueChanged<bool> onToggleTranslation;

  const SurahReaderTopBar({
    super.key,
    required this.surahName,
    required this.surahId,
    this.type = 'meccan',
    required this.currentMode,
    required this.onModeChanged,
    required this.onToggleAutoScroll,
    required this.isAutoScrolling,
    required this.showTranslation,
    required this.onToggleTranslation,
  });

  static int getJuzForSurah(int id) {
    const juzMap = [
      1,
      1,
      3,
      4,
      6,
      7,
      8,
      9,
      10,
      11,
      11,
      12,
      13,
      13,
      14,
      14,
      15,
      15,
      16,
      16,
      17,
      17,
      18,
      18,
      18,
      19,
      19,
      20,
      20,
      21,
      21,
      21,
      21,
      22,
      22,
      22,
      23,
      23,
      23,
      24,
      24,
      25,
      25,
      25,
      25,
      26,
      26,
      26,
      26,
      26,
      26,
      27,
      27,
      27,
      27,
      27,
      27,
      28,
      28,
      28,
      28,
      28,
      28,
      28,
      28,
      28,
      29,
      29,
      29,
      29,
      29,
      29,
      29,
      29,
      29,
      29,
      29,
    ];
    if (id >= 1 && id <= juzMap.length) {
      return juzMap[id - 1];
    }
    return 30;
  }

  static String getJuzName(int juzNum) {
    const names = [
      'الأول',
      'الثاني',
      'الثالث',
      'الرابع',
      'الخامس',
      'السادس',
      'السابع',
      'الثامن',
      'التاسع',
      'العاشر',
      'الحادي عشر',
      'الثاني عشر',
      'الثالث عشر',
      'الرابع عشر',
      'الخامس عشر',
      'السادس عشر',
      'السابع عشر',
      'الثامن عشر',
      'التاسع عشر',
      'العشرون',
      'الحادي والعشرون',
      'الثاني والعشرون',
      'الثالث والعشرون',
      'الرابع والعشرون',
      'الخامس والعشرون',
      'السادس والعشرون',
      'السابع والعشرون',
      'الثامن والعشرون',
      'التاسع والعشرون',
      'الثلاثون',
    ];
    if (juzNum >= 1 && juzNum <= names.length) {
      return names[juzNum - 1];
    }
    return '$juzNum';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleanName = surahName
        .replaceAll('سُورَةُ ', '')
        .replaceAll('سورة ', '')
        .trim();
    final juzNumber = getJuzForSurah(surahId);
    final juzText = getJuzName(juzNumber);
    final revelationText = type.toLowerCase() == 'meccan' ? 'مكية' : 'مدنية';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF383E46) : const Color(0xFFEBE0CE),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              // 1. زر الرجوع على اليمين (يشير دائماً لليسار بحسب إرشادات AGENTS.md)
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20.sp,
                  color: isDark ? Colors.white : const Color(0xFF38291D),
                ),
                onPressed: () => Navigator.pop(context),
              ),

              // 2. اسم السورة وتفاصيل الجزء ومكان النزول في المنتصف
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'سورة $cleanName',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF231B15),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'الجزء $juzText • $revelationText',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFC9A050)
                            : const Color(0xFF7A6450),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. على اليسار: زر التحميل للعمل بدون نت وقائمة الخيارات
              ValueListenableBuilder<int>(
                valueListenable: SurahAudioDownloadService().statusNotifier,
                builder: (context, _, __) {
                  final isDownloaded = SurahAudioDownloadService()
                      .isSurahLocallyDownloaded(surahId);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isDownloaded
                              ? Icons.check_circle_rounded
                              : Icons.download_for_offline_outlined,
                          color: isDownloaded
                              ? const Color(0xFF2E7D5E)
                              : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF143427)),
                          size: 22.sp,
                        ),
                        tooltip: isDownloaded
                            ? 'السورة محملة (جاهزة للاستماع بدون نت)'
                            : 'تحميل السورة للعمل بدون نت',
                        onPressed: () {
                          SurahDownloadBottomSheet.show(
                            context,
                            surahId: surahId,
                            surahName: 'سورة $surahName',
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF38291D),
                          size: 22.sp,
                        ),
                        color: isDark ? const Color(0xFF282C32) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        onSelected: (value) {
                          if (value == 'audio') {
                            context
                                .read<AudioCubit>()
                                .playSurah(surahId, title: 'سورة $surahName');
                          } else if (value == 'download') {
                            SurahDownloadBottomSheet.show(
                              context,
                              surahId: surahId,
                              surahName: 'سورة $surahName',
                            );
                          } else if (value == 'mode') {
                            QuranReadingModeSheet.show(
                              context,
                              currentMode: currentMode,
                              onModeSelected: onModeChanged,
                            );
                          } else if (value == 'translation') {
                            onToggleTranslation(!showTranslation);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'download',
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Icon(
                                  isDownloaded
                                      ? Icons.check_circle_rounded
                                      : Icons.download_for_offline_rounded,
                                  color: isDownloaded
                                      ? const Color(0xFF2E7D5E)
                                      : const Color(0xFF143427),
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  isDownloaded
                                      ? 'السورة محملة (بدون نت)'
                                      : 'تحميل السورة (بدون نت)',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 14.sp,
                                    color: isDownloaded
                                        ? const Color(0xFF2E7D5E)
                                        : null,
                                    fontWeight: isDownloaded
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'audio',
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Icon(
                                  Icons.volume_up_rounded,
                                  color: AppColors.goldenPrimary,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'تشغيل السورة صوتياً',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'mode',
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Icon(
                                  currentMode == QuranScrollMode.vertical
                                      ? Icons.auto_stories_rounded
                                      : Icons.view_day_rounded,
                                  color: AppColors.goldenPrimary,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  currentMode == QuranScrollMode.vertical
                                      ? 'التبديل إلى تصفح أفقي (صفحات)'
                                      : 'التبديل إلى تمرير رأسي',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
