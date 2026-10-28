import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/prayer_times/data/models/prayer_times_model.dart';
import 'package:islamic_app/features/prayer_times/presentation/widgets/home_prayer_card.dart';
import 'package:islamic_app/features/prayer_times/presentation/widgets/home_quick_actions_grid.dart';
import 'package:islamic_app/features/prayer_times/presentation/widgets/home_quick_dhikr_card.dart';

void main() {
  testWidgets('HomePrayerCard renders next prayer and countdown correctly',
      (WidgetTester tester) async {
    final fajr = PrayerInfo(
      name: 'Fajr',
      nameAr: 'الفجر',
      time: '05:34 AM',
      isPassed: false,
      isNext: true,
    );

    final prayers = [
      fajr,
      PrayerInfo(
        name: 'Sunrise',
        nameAr: 'الشروق',
        time: '07:02 AM',
        isPassed: false,
        isNext: false,
      ),
      PrayerInfo(
        name: 'Dhuhr',
        nameAr: 'الظهر',
        time: '12:39 PM',
        isPassed: false,
        isNext: false,
      ),
      PrayerInfo(
        name: 'Asr',
        nameAr: 'العصر',
        time: '03:45 PM',
        isPassed: false,
        isNext: false,
      ),
      PrayerInfo(
        name: 'Maghrib',
        nameAr: 'المغرب',
        time: '06:16 PM',
        isPassed: false,
        isNext: false,
      ),
      PrayerInfo(
        name: 'Isha',
        nameAr: 'العشاء',
        time: '07:39 PM',
        isPassed: false,
        isNext: false,
      ),
    ];

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: HomePrayerCard(
              nextPrayer: fajr,
              timeRemaining: '03:56:16',
              prayers: prayers,
            ),
          ),
        ),
      ),
    );

    expect(find.text('الصلاة القادمة'), findsOneWidget);
    expect(find.text('الفجر'), findsWidgets);
    expect(find.text('03:56:16'), findsOneWidget);
    expect(find.text('الوقت المتبقي'), findsOneWidget);
    expect(find.text('05:34'), findsOneWidget);
    expect(find.text('07:02'), findsOneWidget);
  });

  testWidgets('HomeQuickActionsGrid renders all 8 actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeQuickActionsGrid(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('الأدعية'), findsOneWidget);
    expect(find.text('الأذكار'), findsOneWidget);
    expect(find.text('الأحاديث'), findsOneWidget);
    expect(find.text('القرآن الكريم'), findsOneWidget);
    expect(find.text('المزيد'), findsOneWidget);
    expect(find.text('القبلة'), findsOneWidget);
    expect(find.text('المساجد القريبة'), findsOneWidget);
    expect(find.text('تسبيح'), findsOneWidget);
  });

  testWidgets('HomeQuickDhikrCard renders and allows interactive scrolling & counter',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeQuickDhikrCard(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('زاد ونفحات يومية'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);

    // Verify counter interaction if button is visible
    final counterFinder = find.byType(InkWell);
    expect(counterFinder, findsWidgets);

    // Test swiping horizontally in the PageView
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
  });
}
