import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationSettingsManager {
  static const String _keyMaster = 'notif_master_enabled';
  static const String _keyPrayersMaster = 'notif_prayers_master_enabled';
  static const String _keyFajrSpecific = 'notif_fajr_specific_enabled';
  static const String _keyDhuhr = 'notif_dhuhr_enabled';
  static const String _keyAsr = 'notif_asr_enabled';
  static const String _keyMaghrib = 'notif_maghrib_enabled';
  static const String _keyIsha = 'notif_isha_enabled';

  // صيام السنن
  static const String _keyMondayThursday = 'notif_monday_thursday_fasting';
  static const String _keyWhiteDays = 'notif_white_days_fasting';
  static const String _keyMajorFasting = 'notif_major_fasting_events';

  // سنن الجمعة
  static const String _keyFridayKahf = 'notif_friday_kahf';
  static const String _keyFridayHourResponse = 'notif_friday_hour_response';

  // الختمة
  static const String _keyKhatmahReminder = 'notif_khatmah_reminder';

  // IDs للمنبهات الخاصة
  static const int idMondayFasting = 101;
  static const int idThursdayFasting = 102;
  static const int idFridayKahfMorning = 104;
  static const int idFridayHourResponse = 105;
  static const int idDailyKhatmah = 106;

  // ================== Getters ==================
  static Future<bool> isMasterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMaster) ?? true;
  }

  static Future<bool> isPrayerMasterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrayersMaster) ?? true;
  }

  static Future<bool> isFajrSpecificEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFajrSpecific) ?? true;
  }

  static Future<bool> isPrayerIndividualEnabled(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    switch (prayerKey) {
      case 'fajr':
        return prefs.getBool(_keyFajrSpecific) ?? true;
      case 'dhuhr':
        return prefs.getBool(_keyDhuhr) ?? true;
      case 'asr':
        return prefs.getBool(_keyAsr) ?? true;
      case 'maghrib':
        return prefs.getBool(_keyMaghrib) ?? true;
      case 'isha':
        return prefs.getBool(_keyIsha) ?? true;
      default:
        return true;
    }
  }

  static Future<bool> isMondayThursdayFastingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMondayThursday) ?? true;
  }

  static Future<bool> isWhiteDaysFastingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWhiteDays) ?? true;
  }

  static Future<bool> isMajorFastingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMajorFasting) ?? true;
  }

  static Future<bool> isFridayKahfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFridayKahf) ?? true;
  }

  static Future<bool> isFridayHourResponseEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFridayHourResponse) ?? true;
  }

  static Future<bool> isKhatmahReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyKhatmahReminder) ?? true;
  }

  // ================== Setters ==================
  static Future<void> setMasterEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMaster, value);
    if (!value) {
      await cancelAllSunanNotifications();
    } else {
      await scheduleAllSunanNotifications();
    }
  }

  static Future<void> setPrayerMasterEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrayersMaster, value);
  }

  static Future<void> setFajrSpecificEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFajrSpecific, value);
  }

  static Future<void> setPrayerIndividualEnabled(
    String prayerKey,
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    switch (prayerKey) {
      case 'fajr':
        await prefs.setBool(_keyFajrSpecific, value);
        break;
      case 'dhuhr':
        await prefs.setBool(_keyDhuhr, value);
        break;
      case 'asr':
        await prefs.setBool(_keyAsr, value);
        break;
      case 'maghrib':
        await prefs.setBool(_keyMaghrib, value);
        break;
      case 'isha':
        await prefs.setBool(_keyIsha, value);
        break;
    }
  }

  static Future<void> setMondayThursdayFastingEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMondayThursday, value);
    if (value) {
      await _scheduleMondayThursdayNotifications();
    } else {
      final notif = FlutterLocalNotificationsPlugin();
      await notif.cancel(idMondayFasting);
      await notif.cancel(idThursdayFasting);
    }
  }

  static Future<void> setWhiteDaysFastingEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWhiteDays, value);
  }

  static Future<void> setMajorFastingEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMajorFasting, value);
  }

  static Future<void> setFridayKahfEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFridayKahf, value);
    if (value) {
      await _scheduleFridayKahfNotification();
    } else {
      final notif = FlutterLocalNotificationsPlugin();
      await notif.cancel(idFridayKahfMorning);
    }
  }

  static Future<void> setFridayHourResponseEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFridayHourResponse, value);
    if (value) {
      await _scheduleFridayHourResponseNotification();
    } else {
      final notif = FlutterLocalNotificationsPlugin();
      await notif.cancel(idFridayHourResponse);
    }
  }

  static Future<void> setKhatmahReminderEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKhatmahReminder, value);
    if (value) {
      await _scheduleDailyKhatmahNotification();
    } else {
      final notif = FlutterLocalNotificationsPlugin();
      await notif.cancel(idDailyKhatmah);
    }
  }

  // ================== Scheduling Sunan Reminders ==================
  static Future<void> scheduleAllSunanNotifications() async {
    final master = await isMasterEnabled();
    if (!master) return;

    if (await isMondayThursdayFastingEnabled()) {
      await _scheduleMondayThursdayNotifications();
    }
    if (await isFridayKahfEnabled()) {
      await _scheduleFridayKahfNotification();
    }
    if (await isFridayHourResponseEnabled()) {
      await _scheduleFridayHourResponseNotification();
    }
    if (await isKhatmahReminderEnabled()) {
      await _scheduleDailyKhatmahNotification();
    }
  }

  static Future<void> cancelAllSunanNotifications() async {
    final notif = FlutterLocalNotificationsPlugin();
    await notif.cancel(idMondayFasting);
    await notif.cancel(idThursdayFasting);
    await notif.cancel(idFridayKahfMorning);
    await notif.cancel(idFridayHourResponse);
    await notif.cancel(idDailyKhatmah);
  }

  /// تذكير صيام الإثنين (يوم الأحد الساعة 8:30 مساءً) والخميس (يوم الأربعاء الساعة 8:30 مساءً)
  static Future<void> _scheduleMondayThursdayNotifications() async {
    final notif = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'sunan_fasting_channel',
      'صيام السنن والأيام المباركة',
      channelDescription: 'تنبيهات صيام الإثنين والخميس والأيام البيض',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // 1. تذكير صيام الإثنين (يوم الأحد 8:30 م - Sunday is weekday 7 in DateTime)
    final sundayNight = _nextInstanceOfWeekday(DateTime.sunday, 20, 30);
    await notif.zonedSchedule(
      idMondayFasting,
      '🌙 تذكير بصيام سنة غداً الإثنين',
      '«تُعرض الأعمال يومي الإثنين والخميس، فأحب أن يُعرض عملي وأنا صائم» - تقبل الله طاعتكم.',
      sundayNight,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    // 2. تذكير صيام الخميس (يوم الأربعاء 8:30 م - Wednesday is weekday 3 in DateTime)
    final wednesdayNight = _nextInstanceOfWeekday(DateTime.wednesday, 20, 30);
    await notif.zonedSchedule(
      idThursdayFasting,
      '🌙 تذكير بصيام سنة غداً الخميس',
      'غداً الخميس يوم تُرفع فيه الأعمال إلى الله، لا تنسَ نية الصيام وتذكير من تحب.',
      wednesdayNight,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// تذكير سورة الكهف صباح كل جمعة الساعة 8:00 صباحاً
  static Future<void> _scheduleFridayKahfNotification() async {
    final notif = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'friday_sunan_channel',
      'سنن يوم الجمعة وسورة الكهف',
      channelDescription: 'تذكير بقراءة سورة الكهف وسنن الجمعة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final fridayMorning = _nextInstanceOfWeekday(DateTime.friday, 8, 0);
    await notif.zonedSchedule(
      idFridayKahfMorning,
      '📖 جمعة مباركة | سورة الكهف نور ما بين الجمعتين',
      '«من قرأ سورة الكهف في يوم الجمعة أضاء له من النور ما بين الجمعتين» - اقرأها قبل غروب الشمس.',
      fridayMorning,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// تذكير ساعة الاستجابة يوم الجمعة (الساعة 4:00 عصراً قبل المغرب)
  static Future<void> _scheduleFridayHourResponseNotification() async {
    final notif = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'friday_sunan_channel',
      'سنن يوم الجمعة وسورة الكهف',
      channelDescription: 'تذكير بساعة الاستجابة يوم الجمعة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final fridayAfternoon = _nextInstanceOfWeekday(DateTime.friday, 16, 0);
    await notif.zonedSchedule(
      idFridayHourResponse,
      '🤲 ساعة الاستجابة يوم الجمعة',
      'في يوم الجمعة ساعة لا يوافقها عبد مسلم يسأل الله خيراً إلا أعطاه إياه، ادعُ بما تحب.',
      fridayAfternoon,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// تذكير الورد القرآني اليومي للختمة الساعة 5:00 عصراً
  static Future<void> _scheduleDailyKhatmahNotification() async {
    final notif = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'khatmah_channel',
      'تذكير ورد الختمة القرآني',
      channelDescription: 'تنبيه يومي لمتابعة ورد ختم القرآن',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 17, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await notif.zonedSchedule(
      idDailyKhatmah,
      '🌿 وردك القرآني اليومي',
      'لا تنسَ قراءة ورد الختمة اليومي لتنال بركة القرآن وتصل إلى هدفك المبارك.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfWeekday(int targetWeekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduled.weekday != targetWeekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
