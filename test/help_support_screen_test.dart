import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/settings/presentation/pages/help_support_screen.dart';

void main() {
  testWidgets('HelpSupportScreen renders in light mode without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: HelpSupportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('المساعدة والإرشادات'), findsOneWidget);
    expect(find.text('الأسئلة الشائعة وإرشادات الاستخدام'), findsOneWidget);
    expect(find.text('كيف أستخدم التطبيق؟'), findsOneWidget);
  });

  testWidgets('HelpSupportScreen renders in dark mode without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          themeMode: ThemeMode.dark,
          home: HelpSupportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('المساعدة والإرشادات'), findsOneWidget);
    expect(find.text('الأسئلة الشائعة وإرشادات الاستخدام'), findsOneWidget);
  });
}
