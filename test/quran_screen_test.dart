import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/quran/data/helpers/quran_reading_mode_helper.dart';
import 'package:islamic_app/features/quran/data/models/hizb_model.dart';
import 'package:islamic_app/features/quran/data/models/juz_model.dart';
import 'package:islamic_app/features/quran/data/models/quran_models.dart';
import 'package:islamic_app/features/quran/presentation/widgets/quran_filter_tabs.dart';
import 'package:islamic_app/features/quran/presentation/widgets/surah_list_item.dart';
import 'package:islamic_app/features/quran/presentation/widgets/surah_reader_top_bar.dart';
import 'package:islamic_app/features/quran/presentation/widgets/mushaf_surah_header.dart';
import 'package:islamic_app/features/quran/presentation/widgets/mushaf_bottom_cartouche.dart';
import 'package:islamic_app/features/quran/presentation/widgets/ayah_rosette.dart';

void main() {
  testWidgets('SurahListItem renders surah name, verse count and medallion',
      (WidgetTester tester) async {
    final surah = SurahModel(
      id: 1,
      name: 'سُورَةُ ٱلْفَاتِحَةِ',
      transliteration: 'Al-Faatiha',
      translation: 'The Opening',
      type: 'meccan',
      totalVerses: 7,
      verses: [],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: SurahListItem(
              surah: surah,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('سورة الفاتحة'), findsOneWidget);
    expect(find.text('٧ آيات'), findsOneWidget);
    expect(find.text('١'), findsOneWidget);
  });

  testWidgets('QuranFilterTabs renders all 4 filter tabs',
      (WidgetTester tester) async {
    QuranTabFilter selected = QuranTabFilter.all;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: QuranFilterTabs(
              selectedFilter: selected,
              onFilterChanged: (filter) => selected = filter,
            ),
          ),
        ),
      ),
    );

    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('مكية'), findsOneWidget);
    expect(find.text('مدنية'), findsOneWidget);
    expect(find.text('الجزء'), findsOneWidget);
    expect(find.text('الحزب'), findsOneWidget);
  });

  test('JuzItem and HizbItem have 30 ajza and 60 ahzab with authentic verses', () {
    expect(JuzItem.ajza.length, equals(30));
    expect(HizbItem.ahzab.length, equals(60));

    expect(JuzItem.ajza.first.name, equals('الجزء الأول'));
    expect(JuzItem.ajza[1].startAyahText, contains('سَيَقُولُ السُّفَهَاءُ'));

    expect(HizbItem.ahzab.first.name, equals('الحزب الأول'));
    expect(HizbItem.ahzab[1].startAyahText, contains('أَفَتَطْمَعُونَ أَن يُؤْمِنُوا'));
  });

  test('VerseModel and QuranSectionModel hold authentic section details', () {
    final v = VerseModel(
      id: 253,
      text: '۞ تِلْكَ الرُّسُلُ',
      translation: '',
      surahId: 2,
      surahName: 'Al-Baqarah',
      surahNameArabic: 'سورة البقرة',
      juz: 3,
      hizbQuarter: 17,
    );

    final section = QuranSectionModel(
      number: 3,
      title: 'الجزء الثالث',
      subtitle: 'سورة البقرة (٢٥٣)',
      verses: [v],
      surahsMap: {},
    );

    expect(section.number, equals(3));
    expect(section.title, equals('الجزء الثالث'));
    expect(section.verses.first.id, equals(253));
    expect(section.verses.first.surahId, equals(2));
    expect(section.verses.first.juz, equals(3));
  });

  test('QuranSectionModel serialization and deserialization roundtrip', () {
    final v = VerseModel(
      id: 1,
      text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      translation: 'In the name of Allah',
      surahId: 1,
      surahName: 'Al-Faatiha',
      surahNameArabic: 'الفاتحة',
      juz: 1,
      hizbQuarter: 1,
    );

    final surah = SurahModel(
      id: 1,
      name: 'سورة الفاتحة',
      transliteration: 'Al-Faatiha',
      translation: 'The Opening',
      type: 'meccan',
      totalVerses: 7,
      verses: [v],
    );

    final section = QuranSectionModel(
      number: 1,
      title: 'الجزء الأول',
      subtitle: 'يبدأ من سورة الفاتحة',
      verses: [v],
      surahsMap: {1: surah},
    );

    final json = section.toJson();
    final restored = QuranSectionModel.fromJson(json);

    expect(restored.number, equals(1));
    expect(restored.title, equals('الجزء الأول'));
    expect(restored.verses.length, equals(1));
    expect(restored.verses.first.surahNameArabic, equals('الفاتحة'));
    expect(restored.surahsMap[1]?.name, equals('سورة الفاتحة'));
  });

  testWidgets('SurahReaderTopBar has back button on right, no bookmark icon, and displays surah & juz info',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: SurahReaderTopBar(
              surahName: 'سُورَةُ البَقَرَةِ',
              surahId: 2,
              type: 'medinan',
              currentMode: QuranScrollMode.horizontal,
              onModeChanged: (_) {},
              onToggleAutoScroll: () {},
              isAutoScrolling: false,
              showTranslation: false,
              onToggleTranslation: (_) {},
            ),
          ),
        ),
      ),
    );

    // 1. زر الرجوع على اليمين مع السهم المتجه لليمين في الـ RTL
    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);

    // 2. التحقق من عدم وجود أي زر حفظ/سيف أو تكبير وتصغير خط
    expect(find.byIcon(Icons.bookmark), findsNothing);
    expect(find.byIcon(Icons.bookmark_border), findsNothing);
    expect(find.byIcon(Icons.bookmark_add), findsNothing);
    expect(find.byIcon(Icons.bookmark_outline_rounded), findsNothing);
    expect(find.byIcon(Icons.format_size_rounded), findsNothing);

    // 3. التحقق من عنوان السورة والجزء
    expect(find.text('سورة البَقَرَةِ'), findsOneWidget);
    expect(find.text('الجزء الأول • مدنية'), findsOneWidget);

    // 4. وجود زر الخيارات الثلاثية على اليسار
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });

  testWidgets('MushafSurahHeader renders order, surah title and verse count',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: MushafSurahHeader(
              surahId: 2,
              surahName: 'البَقَرَةِ',
              totalVerses: 286,
            ),
          ),
        ),
      ),
    );

    expect(find.text('سُورَةُ البَقَرَةِ'), findsOneWidget);
    expect(find.text('ترتيبها'), findsOneWidget);
    expect(find.text('آية'), findsOneWidget);
  });

  testWidgets('MushafBottomCartouche renders bottom badge text correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: MushafBottomCartouche(text: '1 / 286'),
          ),
        ),
      ),
    );

    expect(find.text('1 / 286'), findsOneWidget);
  });

  testWidgets('AyahMedallion renders with isLastRead true correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: AyahMedallion(
              ayahNumber: 25,
              fontSize: 24,
              isDark: false,
              isLastRead: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('٢٥'), findsOneWidget);
  });
}


