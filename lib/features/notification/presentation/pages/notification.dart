import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationsHelper {
  // 1 تهيئة الـ Plugin وال Timezone
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Tapped payload: ${response.payload}');
      },
    );

    // طلب صلاحيات
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // 2 ميثود عشان نحساب أقرب وقت للإشعار
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      // scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // 3 ميثود لإرسال إشعار يومي
  static Future<void> scheduleDailyNotification(
    int id,
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Notifications',
          channelDescription: 'القناة بتاعة التنبيهات اليومية',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 4 ميثود لتشغيل كل الإشعارات اليومية (صبح ومساء)
  static Future<void> scheduleAllDailyNotifications() async {
    await scheduleDailyNotification(
      1,
      'أذكار الصباح',
      'افتح لقراءة أذكار الصباح 🌅',
      8,
      0,
    );
    await scheduleDailyNotification(
      2,
      'أذكار المساء',
      'افتح لقراءة أذكار المساء 🌙',
      8,
      0,
    );
  }
}
