import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/settings/presentation/pages/notification_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('NotificationSettingsScreen renders in light mode without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إعدادات الإشعارات والتنبيهات'), findsOneWidget);
    expect(find.text('تفعيل كافة الإشعارات'), findsOneWidget);
    expect(find.text('إشعارات الصلوات الخمس'), findsOneWidget);
    expect(find.text('صلاة الفجر'), findsOneWidget);
    expect(find.text('مخصوص'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('صيام الإثنين والخميس'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('صيام الإثنين والخميس'), findsOneWidget);
  });

  testWidgets('NotificationSettingsScreen renders in dark mode without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          themeMode: ThemeMode.dark,
          home: NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إعدادات الإشعارات والتنبيهات'), findsOneWidget);
    expect(find.text('تفعيل كافة الإشعارات'), findsOneWidget);
  });
}
