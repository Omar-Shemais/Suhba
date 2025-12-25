import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/mushaf_models.dart';
import '../models/quran_models.dart';

class MushafRepository {
  List<MushafVerse>? _cachedVerses;

  Future<List<MushafVerse>> loadFullQuran() async {
    if (_cachedVerses != null) return _cachedVerses!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/quran_en.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      final List<MushafVerse> allVerses = [];

      for (var surahJson in jsonData) {
        final surah = SurahModel.fromJson(surahJson);

        for (int i = 0; i < surah.verses.length; i++) {
          final verse = surah.verses[i];

          allVerses.add(
            MushafVerse(
              surahId: surah.id,
              surahName: surah.transliteration,
              surahNameArabic: surah.name,
              verseId: verse.id,
              textArabic: verse.text,
              textEnglish: verse.translation,
              isNewSurah: i == 0,
            ),
          );
        }
      }

      _cachedVerses = allVerses;
      return allVerses;
    } catch (e) {
      throw Exception('Failed to load Quran: $e');
    }
  }

  // ✅ محاكاة المصحف الحقيقي - 604 صفحة
  List<MushafPage> paginateVerses(List<MushafVerse> verses) {
    const int totalRealPages = 604; // عدد صفحات المصحف الحقيقي
    final int totalVerses = verses.length; // إجمالي الآيات (6236)

    // حساب متوسط الآيات لكل صفحة
    final double averageVersesPerPage = totalVerses / totalRealPages;

    final List<MushafPage> pages = [];
    List<MushafVerse> currentPageVerses = [];
    int currentPageLength = 0;
    int pageNumber = 1;

    // الحد المستهدف لكل صفحة (ديناميكي)
    int targetVersesForCurrentPage = averageVersesPerPage.round();

    for (int i = 0; i < verses.length; i++) {
      final verse = verses[i];
      final verseLength = verse.textArabic.length;

      // حساب الحد الأقصى للصفحة الحالية بناءً على طول النص
      final dynamicMaxLength = _calculatePageCapacity(
        currentPageVerses,
        targetVersesForCurrentPage,
      );

      // شروط إنهاء الصفحة
      final shouldEndPage =
          // الصفحة وصلت للحد الأقصى
          (currentPageLength + verseLength > dynamicMaxLength &&
              currentPageVerses.isNotEmpty) ||
          // أو وصلنا لعدد الآيات المستهدف
          (currentPageVerses.length >= targetVersesForCurrentPage * 1.2);

      if (shouldEndPage) {
        // حفظ الصفحة الحالية
        pages.add(
          MushafPage(
            pageNumber: pageNumber++,
            verses: List.from(currentPageVerses),
          ),
        );

        // بداية صفحة جديدة
        currentPageVerses = [verse];
        currentPageLength = verseLength;

        // إعادة حساب المستهدف للصفحة الجديدة
        final remainingVerses = totalVerses - i;
        final remainingPages = totalRealPages - pageNumber + 1;
        targetVersesForCurrentPage = remainingPages > 0
            ? (remainingVerses / remainingPages).round()
            : 10;
      } else {
        // إضافة الآية للصفحة الحالية
        currentPageVerses.add(verse);
        currentPageLength += verseLength;
      }
    }

    // إضافة آخر صفحة
    if (currentPageVerses.isNotEmpty) {
      pages.add(MushafPage(pageNumber: pageNumber, verses: currentPageVerses));
    }

    return pages;
  }

  // ✅ حساب سعة الصفحة بناءً على محتواها
  int _calculatePageCapacity(
    List<MushafVerse> currentVerses,
    int targetVerses,
  ) {
    if (currentVerses.isEmpty) return 2000;

    // حساب متوسط طول الآية في الصفحة الحالية
    final averageVerseLength =
        currentVerses.map((v) => v.textArabic.length).reduce((a, b) => a + b) ~/
        currentVerses.length;

    // الصفحات اللي فيها آيات طويلة تاخد آيات أقل
    if (averageVerseLength > 200) {
      return 1500; // آيات طويلة (البقرة مثلاً)
    } else if (averageVerseLength > 100) {
      return 2000; // آيات متوسطة
    } else {
      return 2500; // آيات قصيرة (السور القصيرة)
    }
  }

  // ✅ طريقة بديلة أبسط - تقسيم متساوي تقريباً
  List<MushafPage> paginateSimple(List<MushafVerse> verses) {
    const int targetPages = 604;
    final int totalVerses = verses.length;
    final int versesPerPage = (totalVerses / targetPages).ceil();

    final List<MushafPage> pages = [];

    for (int i = 0; i < verses.length; i += versesPerPage) {
      final end = (i + versesPerPage < verses.length)
          ? i + versesPerPage
          : verses.length;

      pages.add(
        MushafPage(
          pageNumber: (i ~/ versesPerPage) + 1,
          verses: verses.sublist(i, end),
        ),
      );
    }

    return pages;
  }

  // الطرق القديمة للمرجعية
  List<MushafPage> paginateByLength(List<MushafVerse> verses) {
    final List<MushafPage> pages = [];
    List<MushafVerse> currentPageVerses = [];
    int currentPageLength = 0;
    int pageNumber = 1;

    const int maxPageLength = 800;
    const int minVersesPerPage = 7;

    for (var verse in verses) {
      final verseLength = verse.textArabic.length;

      if (currentPageLength + verseLength > maxPageLength &&
          currentPageVerses.length >= minVersesPerPage) {
        pages.add(
          MushafPage(
            pageNumber: pageNumber++,
            verses: List.from(currentPageVerses),
          ),
        );

        currentPageVerses = [verse];
        currentPageLength = verseLength;
      } else {
        currentPageVerses.add(verse);
        currentPageLength += verseLength;
      }
    }

    if (currentPageVerses.isNotEmpty) {
      pages.add(MushafPage(pageNumber: pageNumber, verses: currentPageVerses));
    }

    return pages;
  }

  List<MushafPage> paginateByWords(List<MushafVerse> verses) {
    final List<MushafPage> pages = [];
    List<MushafVerse> currentPageVerses = [];
    int currentWordCount = 0;
    int pageNumber = 1;

    const int maxWordsPerPage = 200;

    for (var verse in verses) {
      final wordCount = verse.textArabic.split(' ').length;

      if (currentWordCount + wordCount > maxWordsPerPage &&
          currentPageVerses.isNotEmpty) {
        pages.add(
          MushafPage(
            pageNumber: pageNumber++,
            verses: List.from(currentPageVerses),
          ),
        );

        currentPageVerses = [verse];
        currentWordCount = wordCount;
      } else {
        currentPageVerses.add(verse);
        currentWordCount += wordCount;
      }
    }

    if (currentPageVerses.isNotEmpty) {
      pages.add(MushafPage(pageNumber: pageNumber, verses: currentPageVerses));
    }

    return pages;
  }
}
