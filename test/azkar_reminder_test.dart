import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/features/azkar/presentation/widgets/azkar_reminder_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'azkar_auto_solar_mode': false,
      'azkar_morning_enabled': true,
      'azkar_morning_hour': 7,
      'azkar_morning_minute': 15,
      'azkar_evening_enabled': true,
      'azkar_evening_hour': 18,
      'azkar_evening_minute': 30,
    });
  });

  testWidgets('AzkarReminderCard renders morning and evening rows with manual time',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AzkarReminderCard(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تنبيهات الأذكار الذكية'), findsOneWidget);
    expect(find.text('أذكار الصباح'), findsOneWidget);
    expect(find.text('أذكار المساء'), findsOneWidget);
    expect(find.byTooltip('استعادة الموعد الافتراضي'), findsNWidgets(2));
  });

  testWidgets('Tapping reset button restores default time', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AzkarReminderCard(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final resetButtons = find.byTooltip('استعادة الموعد الافتراضي');
    await tester.tap(resetButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('6:30 ص'), findsOneWidget);
  });

  testWidgets(
      'When auto solar mode is enabled, morning and evening switches are disabled and locked',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'azkar_auto_solar_mode': true,
      'azkar_morning_enabled': true,
      'azkar_evening_enabled': true,
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AzkarReminderCard(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The auto mode switch is on
    expect(find.text('التحديث التلقائي مع الشروق والغروب'), findsOneWidget);
    expect(find.text('مُفعّل'), findsOneWidget);

    // Morning and Evening switches should have onChanged == null (disabled/locked)
    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    // 3 switches: [0] auto mode, [1] morning, [2] evening
    expect(switches.length, 3);
    expect(switches[0].onChanged, isNotNull); // auto mode can be toggled
    expect(switches[1].onChanged, isNull); // morning is locked
    expect(switches[2].onChanged, isNull); // evening is locked

    // Tapping the auto mode switch to disable it should unlock morning and evening switches
    await tester.tap(find.byWidget(switches[0]));
    await tester.pumpAndSettle();

    final updatedSwitches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(updatedSwitches[0].value, isFalse);
    expect(updatedSwitches[1].onChanged, isNotNull); // morning unlocked
    expect(updatedSwitches[2].onChanged, isNotNull); // evening unlocked
  });
}
