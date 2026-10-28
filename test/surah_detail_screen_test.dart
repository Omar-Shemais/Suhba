import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import 'package:islamic_app/features/quran/data/models/audio_model.dart';
import 'package:islamic_app/features/quran/data/models/quran_models.dart';
import 'package:islamic_app/features/quran/data/repositories/audio_repo.dart';
import 'package:islamic_app/features/quran/data/repositories/quran_repo.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';
import 'package:islamic_app/features/quran/presentation/pages/surah_detail_screen.dart';
import 'package:islamic_app/features/quran/presentation/widgets/mushaf_bottom_cartouche.dart';
import 'package:islamic_app/features/quran/presentation/widgets/mushaf_surah_header.dart';

class _FakeQuranRepository implements QuranRepository {
  @override
  Future<SurahModel> getSurahById(int id) async {
    return SurahModel(
      id: id,
      name: 'سُورَةُ ٱلْفَاتِحَةِ',
      transliteration: 'Al-Faatiha',
      translation: 'The Opening',
      type: 'meccan',
      totalVerses: 7,
      verses: [
        VerseModel(
          id: 1,
          text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          translation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          surahId: id,
          surahName: 'Al-Faatiha',
          surahNameArabic: 'الفاتحة',
        ),
        VerseModel(
          id: 2,
          text: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
          translation: '[All] praise is [due] to Allah, Lord of the worlds -',
          surahId: id,
          surahName: 'Al-Faatiha',
          surahNameArabic: 'الفاتحة',
        ),
      ],
    );
  }

  @override
  SurahModel? getCachedSurahById(int id) => null;

  @override
  Future<List<SurahModel>> getAllSurahs() async => [];

  @override
  List<SurahModel>? getCachedSurahs() => null;

  @override
  Future<List<SurahModel>> searchSurahs(String query) async => [];

  @override
  Future<QuranSectionModel> getJuzDetail(int juzNumber) async => throw UnimplementedError();

  @override
  QuranSectionModel? getCachedJuzDetail(int juzNumber) => null;

  @override
  Future<QuranSectionModel> getHizbDetail(int hizbNumber) async => throw UnimplementedError();

  @override
  QuranSectionModel? getCachedHizbDetail(int hizbNumber) => null;

  @override
  void prefetchAdjacentAjza(int juzNumber) {}

  @override
  void prefetchAllAjzaInBackground() {}

  @override
  void prefetchAdjacentSurahs(int currentSurahId) {}

  @override
  void prefetchCommonSurahsInBackground() {}
}

class _FakeAudioRepository implements AudioRepository {
  @override
  Future<String> getAudioUrl(int reciterId, int surahId) async => '';

  @override
  Future<String> getAyahAudioUrl(int reciterId, int surahId, int ayahNumber) async => '';

  @override
  Future<List<ReciterModel>> getAllReciters() async => [];

  @override
  Future<List<RadioStationModel>> getRadioStations() async => [];

  @override
  Future<ReciterModel> getReciterById(int reciterId) async => ReciterModel(
        id: reciterId,
        name: 'Alafasy',
        arabicName: 'مشاري العفاسي',
        baseUrl: '',
        subfolder: '',
        bitrate: 128,
        availableSurahs: [],
      );
}

void main() {
  setUp(() {
    getIt.reset();
    getIt.registerSingleton<QuranRepository>(_FakeQuranRepository());
    final audioRepo = _FakeAudioRepository();
    getIt.registerSingleton<AudioRepository>(audioRepo);
    getIt.registerSingleton<AudioCubit>(AudioCubit(audioRepo));
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('SurahDetailScreen renders with Khatmah style layout and floating audio button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: SurahDetailScreen(surahId: 1),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Back button with Icons.arrow_back_ios_new_rounded pointing LEFT
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    // 2. Mushaf header and cartouche (Khatmah style card)
    expect(find.byType(MushafSurahHeader), findsOneWidget);
    expect(find.byType(MushafBottomCartouche), findsOneWidget);

    // 3. Floating audio button with play icon and surah name
    expect(find.byIcon(Icons.play_arrow_rounded), findsAtLeastNWidgets(1));
    expect(find.text('تشغيل سورة ٱلْفَاتِحَةِ'), findsOneWidget);

    // 4. Reciter selector is present, translation toggle button is removed
    expect(find.byIcon(Icons.record_voice_over_rounded), findsOneWidget);
    expect(find.byIcon(Icons.g_translate_rounded), findsNothing);
    expect(find.byIcon(Icons.translate_rounded), findsNothing);
  });
}
