import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import '../../data/models/mushaf_models.dart';
import '../widgets/mushaf_header.dart';

class MushafTextBuilder {
  static Widget buildContinuousText({
    required List<MushafVerse> verses,
    required bool isDark,
    required bool isArabic,
    double textScale = 1.0, // إضافة معامل التكبير
  }) {
    // نجمع الآيات حسب السور
    final surahGroups = <String, List<MushafVerse>>{};

    for (var verse in verses) {
      final key = verse.surahNameArabic;
      if (!surahGroups.containsKey(key)) {
        surahGroups[key] = [];
      }
      surahGroups[key]!.add(verse);
    }

    // نبني widget لكل سورة مع البوردر
    return Column(
      children: surahGroups.entries.map((entry) {
        final surahVerses = entry.value;
        final firstVerse = surahVerses.first;

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // هيدر السورة
              MushafHeader(
                surahName: firstVerse.surahNameArabic,
                surahNameEnglish: firstVerse.surahName,
              ),
              SizedBox(height: 20.h),

              // آيات السورة
              RichText(
                textAlign: TextAlign.center,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                text: TextSpan(
                  children: _buildVersesSpans(
                    surahVerses,
                    isDark,
                    isArabic,
                    textScale, // تمرير معامل التكبير
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static List<InlineSpan> _buildVersesSpans(
    List<MushafVerse> verses,
    bool isDark,
    bool isArabic,
    double textScale,
  ) {
    List<InlineSpan> spans = [];

    for (var verse in verses) {
      if (isArabic) {
        spans.addAll(_buildArabicVerseSpans(verse, isDark, textScale));
      } else {
        spans.addAll(_buildEnglishVerseSpans(verse, isDark, textScale));
      }
    }

    return spans;
  }

  static List<TextSpan> _buildArabicVerseSpans(
    MushafVerse verse,
    bool isDark,
    double textScale,
  ) {
    return [
      TextSpan(
        text: verse.textArabic,
        style: AppTextStyles.quranText.copyWith(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: (AppTextStyles.quranText.fontSize ?? 24) * textScale,
        ),
      ),
      TextSpan(
        text: '﴿${verse.verseId}﴾ ',
        style: AppTextStyles.quranText.copyWith(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: (AppTextStyles.quranText.fontSize ?? 24) * textScale,
        ),
      ),
    ];
  }

  static List<TextSpan> _buildEnglishVerseSpans(
    MushafVerse verse,
    bool isDark,
    double textScale,
  ) {
    return [
      TextSpan(
        text: '[${verse.verseId}] ',
        style: AppTextStyles.surahTitle.copyWith(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: (AppTextStyles.surahTitle.fontSize ?? 16) * textScale,
        ),
      ),
      TextSpan(
        text: '${verse.textEnglish} ',
        style: AppTextStyles.surahTitle.copyWith(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: (AppTextStyles.surahTitle.fontSize ?? 16) * textScale,
        ),
      ),
    ];
  }
}
