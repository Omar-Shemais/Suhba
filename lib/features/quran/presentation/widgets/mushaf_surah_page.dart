// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_state.dart';
import '../../data/helpers/last_read_storage.dart';
import '../../data/models/quran_models.dart';
import 'ayah_rosette.dart';
import 'ayah_share_bottom_sheet.dart';
import 'mushaf_bottom_cartouche.dart';
import 'mushaf_surah_header.dart';
import '../pages/tafsir_screen.dart';
import 'surah_download_bottom_sheet.dart';
import '../../data/services/surah_audio_download_service.dart';

class MushafSurahPage extends StatelessWidget {
  static const double kMushafFontSize = 24;
  static const double kMushafLineHeight = 2.15;

  final int pageIndex;
  final int totalPages;
  final List<VerseModel> verses;
  final SurahModel surah;
  final bool showTranslation;

  const MushafSurahPage({
    super.key,
    required this.pageIndex,
    required this.totalPages,
    required this.verses,
    required this.surah,
    required this.showTranslation,
  });

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

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join('');
  }

  int _calculateWordCount(List<VerseModel> verses, int surahId) {
    int count = 0;
    for (final v in verses) {
      String text = _cleanVerseText(surahId, v.id, v.text);
      if (text.isNotEmpty) {
        count += text.split(RegExp(r'\s+')).length;
      }
    }
    return count;
  }

  void _showAyahOptions(BuildContext context, VerseModel verse) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioCubit = context.read<AudioCubit>();
    final actionItemColor = isDark ? Colors.white70 : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
            width: 1,
          ),
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
            // شريط السحب
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 14.h),

            // عنوان الآية
            Text(
              '${surah.name} • الآية ${_toArabicNumber(verse.id)}',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.goldenPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            // نص الآية
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

            // أزرار العمليات
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
                      audioCubit.playAyah(
                        surah.id,
                        verse.id,
                        surahVerses: surah.verses,
                        totalVerses: surah.totalVerses,
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
                            surahId: surah.id,
                            ayahNumber: verse.id,
                            surahName: surah.name,
                            initialArabicText: verse.text,
                            totalVerses: surah.totalVerses,
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: SurahAudioDownloadService().statusNotifier,
                    builder: (context, _, __) {
                      final isDownloaded = SurahAudioDownloadService()
                          .isSurahLocallyDownloaded(surah.id);
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
                            surahId: surah.id,
                            surahName: surah.name,
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
                        surahId: surah.id,
                        ayahNumber: verse.id,
                        surahName: surah.name,
                        surahNameArabic: surah.name,
                        totalVerses: surah.totalVerses,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حفظ سورة ${surah.name} الآية ${verse.id} كآخر موضع قراءة',
                          ),
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
                          surahNumber: surah.id,
                          ayahNumber: verse.id,
                          surahName: surah.name,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, audioState) {
        final currentPlayingAyah =
            audioState is AudioPlayingAyah &&
                audioState.currentSurahId == surah.id
            ? audioState.currentAyahNumber
            : (audioState is AudioPlaying &&
                      audioState.currentSurahId == surah.id
                  ? context.read<AudioCubit>().currentAyahNumber
                  : null);

        return Container(
          color: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. الإطار القرآني الزخرفي الفاخر (أخضر وذهبي) بدقة عالية مع 9-Patch
              Positioned.fill(
                child: Image.asset(
                  'assets/images/mushaf_page_frame.png',
                  fit: BoxFit.fill,
                  centerSlice: const Rect.fromLTRB(50, 80, 292, 510),
                ),
              ),

              // 2. محتوى الصفحة بداخل الإطار القرآني
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 18.h,
                    bottom: 12.h,
                    left: 22.w,
                    right: 22.w,
                  ),
                  child: Column(
                    children: [
                      // إذا كانت الصفحة الأولى، يظهر بانر السورة القرآني والبسملة
                      if (pageIndex == 0) ...[
                        MushafSurahHeader(
                          surahId: surah.id,
                          surahName: surah.name,
                          totalVerses: surah.totalVerses,
                        ),
                        if (surah.id != 9 && surah.id != 1) ...[
                          Padding(
                            padding: EdgeInsets.only(top: 4.h, bottom: 6.h),
                            child: Center(
                              child: Text(
                                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFE5C992)
                                      : const Color(0xFF261D16),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],

                      // 3. الآيات الكريمة متصلة في أسطر بخط واضح يملأ الصفحة دون ليست فيو أو فراغ
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final int wordCount = _calculateWordCount(
                                verses,
                                surah.id,
                              );
                              final double dynamicFontSize;
                              final double dynamicLineHeight;

                              if (wordCount <= 30) {
                                dynamicFontSize = 30;
                                dynamicLineHeight = 2.7;
                              } else if (wordCount <= 50) {
                                dynamicFontSize = 30;
                                dynamicLineHeight = 2;
                              } else if (wordCount <= 70) {
                                dynamicFontSize = 30;
                                dynamicLineHeight = 2.1;
                              } else {
                                dynamicFontSize = 30;
                                dynamicLineHeight = 2;
                              }

                              return Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: constraints.maxWidth,
                                    child: SingleChildScrollView(
                                      physics: showTranslation
                                          ? const BouncingScrollPhysics()
                                          : const NeverScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  for (final verse
                                                      in verses) ...[
                                                    () {
                                                      final isPlayingThis =
                                                          currentPlayingAyah ==
                                                          verse.id;
                                                      final isLastReadThis =
                                                          LastReadManager.isAyahLastRead(
                                                            surah.id,
                                                            verse.id,
                                                          );

                                                      return TextSpan(
                                                        text:
                                                            '${_cleanVerseText(surah.id, verse.id, verse.text)} ',
                                                        style: TextStyle(
                                                          fontFamily: 'Amiri',
                                                          fontSize:
                                                              dynamicFontSize
                                                                  .sp,
                                                          height:
                                                              dynamicLineHeight,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isPlayingThis
                                                              ? (isDark
                                                                  ? const Color(
                                                                      0xFF2E7D5E,
                                                                    )
                                                                  : const Color(
                                                                      0xFF143427,
                                                                    ))
                                                              : (isLastReadThis
                                                                    ? (isDark
                                                                        ? const Color(
                                                                            0xFF2E7D5E,
                                                                          )
                                                                        : const Color(
                                                                            0xFF143427,
                                                                          ))
                                                                    : (isDark
                                                                          ? const Color(
                                                                              0xFFFAF6EE,
                                                                            )
                                                                          : const Color(
                                                                              0xFF1B140E,
                                                                            ))),
                                                           backgroundColor:
                                                              isPlayingThis
                                                              ? (isDark
                                                                  ? const Color(
                                                                      0xFF2E7D5E,
                                                                    ).withValues(
                                                                      alpha: 0.25,
                                                                    )
                                                                  : const Color(
                                                                      0xFF143427,
                                                                    ).withValues(
                                                                      alpha: 0.18,
                                                                    ))
                                                              : (isLastReadThis
                                                                    ? (isDark
                                                                        ? const Color(
                                                                            0xFF2E7D5E,
                                                                          ).withValues(
                                                                            alpha: 0.20,
                                                                          )
                                                                        : const Color(
                                                                            0xFFC79E53,
                                                                          ).withValues(
                                                                            alpha:
                                                                                0.14,
                                                                          ))
                                                                    : Colors
                                                                          .transparent),
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () =>
                                                                  _showAyahOptions(
                                                                    context,
                                                                    verse,
                                                                  ),
                                                      );
                                                    }(),
                                                    WidgetSpan(
                                                      alignment:
                                                          PlaceholderAlignment
                                                              .middle,
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            _showAyahOptions(
                                                              context,
                                                              verse,
                                                            ),
                                                        child: AyahMedallion(
                                                          ayahNumber: verse.id,
                                                          fontSize:
                                                              dynamicFontSize,
                                                          isDark: isDark,
                                                          isPlaying:
                                                              currentPlayingAyah ==
                                                              verse.id,
                                                          isLastRead:
                                                              LastReadManager.isAyahLastRead(
                                                                surah.id,
                                                                verse.id,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    const TextSpan(text: ' '),
                                                  ],
                                                ],
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ),

                                          ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // 4. الشارة السفلية الفاخرة (مثل 1 / 286 في لقطة الشاشة تماماً)
                      MushafBottomCartouche(
                        text: '${verses.first.id} / ${surah.totalVerses}',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
