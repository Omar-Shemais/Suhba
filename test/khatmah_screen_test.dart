import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/khatmah/data/helpers/khatmah_manager.dart';
import 'package:islamic_app/features/khatmah/data/models/khatmah_model.dart';
import 'package:islamic_app/features/khatmah/presentation/pages/khatmah_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('KhatmahScreen renders Create Khatmah view matching new UI in light mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: KhatmahScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('ختمة القرآن الكريم'), findsOneWidget);

    // Verify Hero Card
    expect(find.text('ابدأ خطتك'), findsOneWidget);
    expect(find.text('لختم كتاب الله'), findsOneWidget);

    // Verify Title Card
    expect(find.text('عنوان الختمة'), findsOneWidget);

    // Verify Target Days Question and Preset options
    expect(find.text('في كم يوماً تريد ختم القرآن؟'), findsOneWidget);
    expect(find.text('30 يوماً'), findsOneWidget);
    expect(find.text('15 يوماً'), findsOneWidget);
    expect(find.text('10 يوماً'), findsOneWidget);
    expect(find.text('7 يوماً'), findsOneWidget);
    expect(find.text('60 يوماً'), findsOneWidget);

    // Verify Calculation Card
    expect(find.text('خطة وردك اليومي المقترح:'), findsOneWidget);
    expect(find.text('المقدار بالأجزاء:'), findsOneWidget);
    expect(find.text('1.0 جزء يومياً'), findsOneWidget);
    expect(find.text('المقدار بالأحزاب:'), findsOneWidget);
    expect(find.text('2.0 حزب يومياً'), findsOneWidget);
    expect(find.text('المقدار بالصفحات:'), findsOneWidget);
    expect(find.text('21 صفحة في اليوم'), findsOneWidget);

    // Verify Start Button
    expect(find.text('بدء الختمة المباركة'), findsOneWidget);
  });

  testWidgets('KhatmahScreen updates calculation dynamically when day pill is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: KhatmahScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap 15 days after ensuring visible
    await tester.ensureVisible(find.text('15 يوماً'));
    await tester.tap(find.text('15 يوماً'));
    await tester.pumpAndSettle();

    // 30 / 15 = 2.0 parts
    expect(find.text('2.0 جزء يومياً'), findsOneWidget);
    // 60 / 15 = 4.0 ahzab
    expect(find.text('4.0 حزب يومياً'), findsOneWidget);
    // 604 / 15 ceil = 41 pages
    expect(find.text('41 صفحة في اليوم'), findsOneWidget);
  });

  testWidgets('KhatmahScreen renders without errors in dark mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          theme: ThemeData.dark(),
          home: const KhatmahScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ختمة القرآن الكريم'), findsOneWidget);
    expect(find.text('بدء الختمة المباركة'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF1E2125));
  });

  testWidgets(
      'Active Khatmah: selecting Juz updates Surah/Ayah range and toggle between أكملت الورد and تمت القراءة',
      (WidgetTester tester) async {
    final khatmah = KhatmahModel(
      id: 'test_khatmah_1',
      title: 'ختمة الاختبار',
      targetDays: 30,
      startDate: DateTime.now(),
      completedJuz: [],
      currentJuz: 1,
    );
    await KhatmahManager.saveKhatmah(khatmah);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: KhatmahScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial selection is Juz 1
    expect(
      find.textContaining('من سورة الفاتحة (آية 1) إلى سورة البقرة (آية 141)'),
      findsOneWidget,
    );
    expect(find.text('قيد القراءة 📖'), findsOneWidget);
    expect(find.text('أكملت الورد'), findsOneWidget);
    expect(find.text('اقرأ الورد الآن'), findsOneWidget);

    // 2. Tap "أكملت الورد" for Juz 1
    await tester.ensureVisible(find.text('أكملت الورد'));
    await tester.tap(find.text('أكملت الورد'));
    await tester.pumpAndSettle();

    expect(find.text('تمت القراءة'), findsOneWidget);
    expect(find.text('تمت القراءة ✅'), findsOneWidget);

    // 3. Switch to Juz 2 in grid
    await tester.ensureVisible(find.text('2'));
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    // Juz 2 details and resets button to "أكملت الورد"
    expect(
      find.textContaining('من سورة البقرة (آية 142) إلى سورة البقرة (آية 252)'),
      findsOneWidget,
    );
    expect(find.text('قيد القراءة 📖'), findsOneWidget);
    expect(find.text('أكملت الورد'), findsOneWidget);

    // 4. Mark Juz 2 done
    await tester.ensureVisible(find.text('أكملت الورد'));
    await tester.tap(find.text('أكملت الورد'));
    await tester.pumpAndSettle();

    expect(find.text('تمت القراءة'), findsOneWidget);
    expect(find.text('تمت القراءة ✅'), findsOneWidget);

    // 5. Switch back to Juz 1 -> should show "تمت القراءة"
    await tester.ensureVisible(find.text('1'));
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('من سورة الفاتحة (آية 1) إلى سورة البقرة (آية 141)'),
      findsOneWidget,
    );
    expect(find.text('تمت القراءة'), findsOneWidget);
    expect(find.text('تمت القراءة ✅'), findsOneWidget);
  });
}
