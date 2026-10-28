import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import 'package:islamic_app/features/hadith/data/models/hadith_model.dart';
import 'package:islamic_app/features/hadith/data/repositories/hadith_repository.dart';
import 'package:islamic_app/features/hadith/presentation/cubit/hadith_cubit.dart';
import 'package:islamic_app/features/hadith/presentation/widgets/hadith_card.dart';
import 'package:islamic_app/features/hadith/presentation/widgets/hadiths_view_body.dart';

class FakeHadithRepository implements HadithRepository {
  final List<HadithModel> fakeHadiths = [
    HadithModel(
      id: 1,
      hadithArabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      hadithEnglish: 'Actions are according to intentions',
      arabicNarrator: 'عمر بن الخطاب رضي الله عنه',
      englishNarrator: 'Narrated Umar',
      bookSlug: 'sahih-bukhari',
      volume: 1,
      hadithNumber: 1,
    ),
    HadithModel(
      id: 2,
      hadithArabic: 'الدِّينُ النَّصِيحَةُ',
      hadithEnglish: 'Religion is sincere counsel',
      arabicNarrator: 'تميم الداري رضي الله عنه',
      englishNarrator: 'Narrated Tamim',
      bookSlug: 'sahih-muslim',
      volume: 1,
      hadithNumber: 55,
    ),
  ];

  @override
  List<HadithModel> getCachedHadiths({String? book}) {
    if (book == null || book == 'all') return fakeHadiths;
    return fakeHadiths.where((h) => h.bookSlug == book).toList();
  }

  @override
  Future<HadithResponse> getHadiths({String? book, int page = 1, int limit = 20}) async {
    final list = getCachedHadiths(book: book);
    return HadithResponse(hadiths: list, total: list.length, page: page, limit: limit);
  }

  @override
  Future<List<HadithModel>> searchHadiths({String? arabicQuery, String? englishQuery}) async {
    return fakeHadiths;
  }
}

void main() {
  testWidgets('HadithViewBody renders cached hadiths immediately without hanging',
      (WidgetTester tester) async {
    final fakeRepo = FakeHadithRepository();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: BlocProvider(
                create: (_) => HadithCubit(fakeRepo)..loadHadiths(),
                child: const HadithsViewBody(),
              ),
            ),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify Hadiths are immediately visible
    expect(find.textContaining('إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ'), findsOneWidget);
    expect(find.textContaining('الدِّينُ النَّصِيحَةُ'), findsOneWidget);

    // English translation is hidden by default
    expect(find.text('Actions are according to intentions'), findsNothing);
    expect(find.text('عرض الترجمة بالإنجليزية'), findsWidgets);

    // Tap to show English translation
    await tester.tap(find.text('عرض الترجمة بالإنجليزية').first);
    await tester.pumpAndSettle();

    // Now English translation is visible
    expect(find.text('Actions are according to intentions'), findsOneWidget);
    expect(find.text('إخفاء الترجمة الإنجليزية'), findsOneWidget);
  });
}
