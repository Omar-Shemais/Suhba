import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/fasting/presentation/pages/fasting_sunan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FastingSunanScreen renders without error in light mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: FastingSunanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('الفروض والسنن'), findsOneWidget);
    expect(find.text('متابعة الصلوات الخمس المفروضة'), findsOneWidget);
    expect(find.text('سنن الصلوات الخمس والرواتب'), findsOneWidget);
    expect(find.text('صلاة الفجر'), findsWidgets);
  });

  testWidgets('FastingSunanScreen renders without error in dark mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          themeMode: ThemeMode.dark,
          home: FastingSunanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('الفروض والسنن'), findsOneWidget);
    expect(find.text('متابعة الصلوات الخمس المفروضة'), findsOneWidget);
    expect(find.text('سنن الصلوات الخمس والرواتب'), findsOneWidget);
  });

  testWidgets('Tapping prayer item toggles its state and updates completed count',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: FastingSunanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('٠ من ٥ اليوم'), findsOneWidget);

    final solaythaButtons = find.text('صلّيتها');
    expect(solaythaButtons, findsWidgets);
    await tester.ensureVisible(solaythaButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(solaythaButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('١ من ٥ اليوم'), findsOneWidget);
    expect(find.text('أُدِّيَتْ'), findsWidgets);
  });
}
