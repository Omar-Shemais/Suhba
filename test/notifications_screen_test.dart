import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import 'package:islamic_app/features/notification/data/services/notifications_feed_service.dart';
import 'package:islamic_app/features/notification/presentation/pages/notifications_screen.dart';
import 'package:islamic_app/features/prayer_times/presentation/widgets/home_header_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('NotificationsFeedService returns list of notifications and alerts count',
      () async {
    final list = await NotificationsFeedService.getNotifications();
    final count = await NotificationsFeedService.getAlertsCount();

    expect(list.isNotEmpty, true);
    expect(count, greaterThan(0));
    // Verify some essential items exist
    expect(list.any((item) => item.id == 'fasting_mon_thu'), true);
    expect(list.any((item) => item.id == 'white_days'), true);
    expect(list.any((item) => item.id == 'prayer_time'), true);
    expect(list.any((item) => item.id == 'daily_wird'), true);
    expect(list.any((item) => item.id == 'salawat'), true);
    expect(list.any((item) => item.id == 'istighfar'), true);
    expect(list.firstWhere((item) => item.id == 'istighfar').route, AppRoutes.azkar);
    expect(list.any((item) => item.id == 'daily_suggestion'), true);
    expect(list.any((item) => item.id == 'kinship'), true);
    expect(list.any((item) => item.id == 'azkar_suggestion'), true);
  });

  testWidgets('NotificationsScreen renders in light mode without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الإشعارات المهمة'), findsOneWidget);
    expect(find.text('تنبيهاتك اليومية .. لرحلة أقرب إلى الله'), findsOneWidget);
    expect(find.text('لا تنس الصلاة في وقتها'), findsOneWidget);
    expect(find.text('لا تنس قراءة وردك اليومي'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('كل إشعار .. خطوة نحو حياة أطيب'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('كل إشعار .. خطوة نحو حياة أطيب'), findsOneWidget);
  });

  testWidgets('NotificationsScreen renders in dark mode without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          themeMode: ThemeMode.dark,
          home: NotificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الإشعارات المهمة'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('كل إشعار .. خطوة نحو حياة أطيب'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('كل إشعار .. خطوة نحو حياة أطيب'), findsOneWidget);
  });

  testWidgets('HomeHeaderWidget renders notification bell with alert count badge',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: HomeHeaderWidget(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify notifications icon and badge are present
    expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
    // Badge has the Arabic digit e.g. ٦
    expect(find.text('٦'), findsOneWidget);
  });

  testWidgets('Tapping Salawat notification opens bottom sheet with Salawat formulas and counter',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to and tap Salawat card
    await tester.scrollUntilVisible(
      find.text('هل صليت على النبي اليوم؟'),
      150.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('هل صليت على النبي اليوم؟'));
    await tester.pumpAndSettle();

    // Bottom sheet should be visible
    expect(find.text('الصَّلَاةُ عَلَى النَّبِيِّ ﷺ'), findsOneWidget);
    expect(find.text('الصيغة الإبراهيمية'), findsOneWidget);

    // Scroll bottom sheet to make counter button visible
    await tester.scrollUntilVisible(
      find.text('اضغط هنا للصلاة على النبي ﷺ'),
      150.0,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('اضغط هنا للصلاة على النبي ﷺ'), findsOneWidget);

    // Tap counter button
    await tester.tap(find.text('اضغط هنا للصلاة على النبي ﷺ'));
    await tester.pumpAndSettle();

    expect(find.text('صلّيت ﷺ (١) مرات'), findsOneWidget);
  });

  test('Marking notification as read decreases alerts count and markAllAsRead clears badge',
      () async {
    final initialCount = await NotificationsFeedService.getAlertsCount();
    expect(initialCount, 6);

    await NotificationsFeedService.markAsRead('prayer_time');
    final countAfterOne = await NotificationsFeedService.getAlertsCount();
    expect(countAfterOne, 5);

    await NotificationsFeedService.markAllAsRead();
    final countAfterAll = await NotificationsFeedService.getAlertsCount();
    expect(countAfterAll, 0);
  });
}
