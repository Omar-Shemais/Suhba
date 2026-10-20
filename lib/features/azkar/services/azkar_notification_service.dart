import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/routes/app_router.dart';
import '../../prayer_times/data/models/prayer_times_model.dart';
import '../presentation/pages/morning_azkar.dart';
import '../presentation/pages/evening_azkar_screen.dart';

class AzkarNotificationService {
  static final AzkarNotificationService _instance =
      AzkarNotificationService._internal();
  factory AzkarNotificationService() => _instance;
  AzkarNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _autoModeKey = 'azkar_auto_solar_mode';
  static const String _morningEnabledKey = 'azkar_morning_enabled';
  static const String _morningHourKey = 'azkar_morning_hour';
  static const String _morningMinuteKey = 'azkar_morning_minute';

  static const String _eveningEnabledKey = 'azkar_evening_enabled';
  static const String _eveningHourKey = 'azkar_evening_hour';
  static const String _eveningMinuteKey = 'azkar_evening_minute';

  static const int morningNotificationId = 1001;
  static const int eveningNotificationId = 1002;
  static const int testNotificationId = 1099;

  static const String channelId = 'azkar_reminders';
  static const String channelName = 'تذكير أذكار الصباح والمساء';
  static const String channelDescription =
      'إشعارات وتنبيهات يومية لأذكار الصباح وأذكار المساء مرتبطة بالشروق والغروب';

  // Default fallback times if no prayer times cached yet
  static const int defaultMorningHour = 6;
  static const int defaultMorningMinute = 30;
  static const int defaultEveningHour = 17;
  static const int defaultEveningMinute = 0;

  bool _isInitialized = false;

  /// تهيئة خدمة إشعارات الأذكار
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🌙 [AzkarNotificationService] بدء تهيئة خدمة الإشعارات...');

      // 1. تهيئة المناطق الزمنية
      tz.initializeTimeZones();
      try {
        final currentTimeZone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
      } catch (_) {
        try {
          tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
        } catch (_) {}
      }

      // 2. إعداد قناة الأندرويد المخصصة للأذكار
      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      // 3. تهيئة الـ plugin
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;

      // 4. فحص مواقيت الصلاة والشروق والغروب المحفوظة ومزامنتها تلقائياً
      await _syncWithCachedPrayerTimesIfAvailable();

      // 5. جدولة التنبيهات
      await rescheduleAll();
      debugPrint('✅ [AzkarNotificationService] تم تهيئة الإشعارات بنجاح');
    } catch (e) {
      debugPrint('❌ [AzkarNotificationService] خطأ في التهيئة: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('🔔 [AzkarNotification] الضغط على الإشعار: $payload');

    final navState = AppRouter.navigatorKey.currentState;
    if (navState == null) return;

    if (payload == 'morning_azkar') {
      navState.push(
        MaterialPageRoute(builder: (_) => const MorningAzkar()),
      );
    } else if (payload == 'evening_azkar') {
      navState.push(
        MaterialPageRoute(builder: (_) => const EveningAzkarScreen()),
      );
    }
  }

  /// مزامنة أوقات الأذكار تلقائياً مع مواقيت الصلاة والشروق والغروب
  Future<void> syncWithPrayerTimes(PrayerTimesModel prayerTimes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuto = prefs.getBool(_autoModeKey) ?? true;

      if (!isAuto) {
        debugPrint('ℹ️ [AzkarNotificationService] الوضع اليدوي مفعل، لن يتم تغيير التوقيت');
        return;
      }

      debugPrint('☀️ [AzkarNotificationService] مزامنة الأذكار مع الشروق (${prayerTimes.sunrise}) والفجر (${prayerTimes.fajr}) والعصر (${prayerTimes.asr})...');

      // 1. أذكار الصباح: بعد أذان الفجر بـ 20 دقيقة (ليكون المستخدم انتهى من الصلاة وقبل الشروق)
      final morningTime = _parseTimeWithOffset(prayerTimes.fajr, 20);

      // 2. أذكار المساء: بعد أذان العصر بـ 20 دقيقة (لبدء وقت أذكار المساء المأثورة قبل الغروب)
      final eveningTime = _parseTimeWithOffset(prayerTimes.asr, 20);

      await prefs.setInt(_morningHourKey, morningTime.hour);
      await prefs.setInt(_morningMinuteKey, morningTime.minute);
      await prefs.setInt(_eveningHourKey, eveningTime.hour);
      await prefs.setInt(_eveningMinuteKey, eveningTime.minute);

      final morningEnabled = prefs.getBool(_morningEnabledKey) ?? true;
      final eveningEnabled = prefs.getBool(_eveningEnabledKey) ?? true;

      await scheduleMorningAzkar(
        hour: morningTime.hour,
        minute: morningTime.minute,
        enabled: morningEnabled,
      );

      await scheduleEveningAzkar(
        hour: eveningTime.hour,
        minute: eveningTime.minute,
        enabled: eveningEnabled,
      );

      debugPrint(
        '✅ [AzkarNotificationService] تم ضبط التوقيت التلقائي بنجاح: الصباح (${morningTime.hour}:${morningTime.minute})، المساء (${eveningTime.hour}:${eveningTime.minute})',
      );
    } catch (e) {
      debugPrint('❌ [AzkarNotificationService] خطأ في المزامنة الفلكية: $e');
    }
  }

  /// قراءة مواقيت الصلاة المخزنة مؤقتاً ومزامنتها
  Future<void> _syncWithCachedPrayerTimesIfAvailable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('prayer_times_cache');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final Map<String, dynamic> map = json.decode(cachedStr);
        final model = PrayerTimesModel.fromMap(map);
        await syncWithPrayerTimes(model);
      }
    } catch (e) {
      debugPrint('⚠️ [AzkarNotificationService] تعذر قراءة كاش مواقيت الصلاة: $e');
    }
  }

  /// تحويل وقت الصلاة من نص (مثل "04:47 AM") وإضافة فارق بالدقائق
  TimeOfDay _parseTimeWithOffset(String timeStr, int offsetMinutes) {
    final split = PrayerTimesModel.splitTime(timeStr);
    int hour = int.tryParse(split['hours'] ?? '') ?? 0;
    int minute = int.tryParse(split['minutes'] ?? '') ?? 0;
    final period = split['period']?.toUpperCase() ?? '';

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    minute += offsetMinutes;
    while (minute >= 60) {
      minute -= 60;
      hour = (hour + 1) % 24;
    }
    while (minute < 0) {
      minute += 60;
      hour = (hour - 1 + 24) % 24;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// حساب الوقت القادم للجدولة
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// تفاصيل الإشعار
  NotificationDetails _buildNotificationDetails({
    required String title,
    required String body,
    required Color color,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: color,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// جدولة أذكار الصباح
  Future<void> scheduleMorningAzkar({
    required int hour,
    required int minute,
    required bool enabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_morningEnabledKey, enabled);
    await prefs.setInt(_morningHourKey, hour);
    await prefs.setInt(_morningMinuteKey, minute);

    await _notifications.cancel(morningNotificationId);

    if (!enabled) {
      debugPrint('🔕 تم إيقاف تنبيه أذكار الصباح');
      return;
    }

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    const title = '🌅 أذكار الصباح';
    const body =
        'أصبحنا وأصبح الملك لله.. حان وقت أذكار الصباح، حصّن يومك بالبركة والسكينة 🤍';

    await _notifications.zonedSchedule(
      morningNotificationId,
      title,
      body,
      scheduledTime,
      _buildNotificationDetails(
        title: title,
        body: body,
        color: const Color(0xFFC69C6D),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'morning_azkar',
    );

    debugPrint('✅ تم جدولة أذكار الصباح في: $hour:$minute (القادم: $scheduledTime)');
  }

  /// جدولة أذكار المساء
  Future<void> scheduleEveningAzkar({
    required int hour,
    required int minute,
    required bool enabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eveningEnabledKey, enabled);
    await prefs.setInt(_eveningHourKey, hour);
    await prefs.setInt(_eveningMinuteKey, minute);

    await _notifications.cancel(eveningNotificationId);

    if (!enabled) {
      debugPrint('🔕 تم إيقاف تنبيه أذكار المساء');
      return;
    }

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    const title = '🌙 أذكار المساء';
    const body =
        'أمسينا وأمسى الملك لله.. حان وقت أذكار المساء، حصّن نفسك وسكينة ليلك بذكر الله 🤍';

    await _notifications.zonedSchedule(
      eveningNotificationId,
      title,
      body,
      scheduledTime,
      _buildNotificationDetails(
        title: title,
        body: body,
        color: const Color(0xFF704214),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'evening_azkar',
    );

    debugPrint('✅ تم جدولة أذكار المساء في: $hour:$minute (القادم: $scheduledTime)');
  }

  /// تفعيل أو تعطيل الوضع التلقائي المرتبط بالشروق والغروب
  Future<void> setAutoSolarMode(bool enableAuto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoModeKey, enableAuto);

    if (enableAuto) {
      await _syncWithCachedPrayerTimesIfAvailable();
    }
  }

  /// إعادة جدولة كل التنبيهات حسب الإعدادات المحفوظة
  Future<void> rescheduleAll() async {
    final settings = await getSettings();

    await scheduleMorningAzkar(
      hour: settings.morningHour,
      minute: settings.morningMinute,
      enabled: settings.morningEnabled,
    );

    await scheduleEveningAzkar(
      hour: settings.eveningHour,
      minute: settings.eveningMinute,
      enabled: settings.eveningEnabled,
    );
  }

  /// إرسال إشعار فوري تجريبي للمستخدم
  Future<void> sendTestNotification({required bool isMorning}) async {
    final title = isMorning ? '🌅 تجربة: أذكار الصباح' : '🌙 تجربة: أذكار المساء';
    final body = isMorning
        ? 'أصبحنا وأصبح الملك لله.. هذا إشعار تجريبي لتأكيد وصول تنبيه أذكار الصباح بنجاح ✨'
        : 'أمسينا وأمسى الملك لله.. هذا إشعار تجريبي لتأكيد وصول تنبيه أذكار المساء بنجاح ✨';

    final details = _buildNotificationDetails(
      title: title,
      body: body,
      color: isMorning ? const Color(0xFFC69C6D) : const Color(0xFF704214),
    );

    await _notifications.show(
      testNotificationId,
      title,
      body,
      details,
      payload: isMorning ? 'morning_azkar' : 'evening_azkar',
    );
  }

  /// قراءة الإعدادات المحفوظة
  Future<AzkarNotificationSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String? fajr;
    String? sunrise;
    String? asr;
    String? maghrib;

    try {
      final cachedStr = prefs.getString('prayer_times_cache');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final map = json.decode(cachedStr);
        fajr = map['fajr'];
        sunrise = map['sunrise'];
        asr = map['asr'];
        maghrib = map['maghrib'];
      }
    } catch (_) {}

    return AzkarNotificationSettings(
      isAutoSolarMode: prefs.getBool(_autoModeKey) ?? true,
      morningEnabled: prefs.getBool(_morningEnabledKey) ?? true,
      morningHour: prefs.getInt(_morningHourKey) ?? defaultMorningHour,
      morningMinute: prefs.getInt(_morningMinuteKey) ?? defaultMorningMinute,
      eveningEnabled: prefs.getBool(_eveningEnabledKey) ?? true,
      eveningHour: prefs.getInt(_eveningHourKey) ?? defaultEveningHour,
      eveningMinute: prefs.getInt(_eveningMinuteKey) ?? defaultEveningMinute,
      fajrTime: fajr,
      sunriseTime: sunrise,
      asrTime: asr,
      maghribTime: maghrib,
    );
  }
}

class AzkarNotificationSettings {
  final bool isAutoSolarMode;
  final bool morningEnabled;
  final int morningHour;
  final int morningMinute;
  final bool eveningEnabled;
  final int eveningHour;
  final int eveningMinute;
  final String? fajrTime;
  final String? sunriseTime;
  final String? asrTime;
  final String? maghribTime;

  const AzkarNotificationSettings({
    required this.isAutoSolarMode,
    required this.morningEnabled,
    required this.morningHour,
    required this.morningMinute,
    required this.eveningEnabled,
    required this.eveningHour,
    required this.eveningMinute,
    this.fajrTime,
    this.sunriseTime,
    this.asrTime,
    this.maghribTime,
  });

  String get morningTimeString {
    final h = morningHour > 12
        ? morningHour - 12
        : (morningHour == 0 ? 12 : morningHour);
    final m = morningMinute.toString().padLeft(2, '0');
    final period = morningHour >= 12 ? 'م' : 'ص';
    return '$h:$m $period';
  }

  String get eveningTimeString {
    final h = eveningHour > 12
        ? eveningHour - 12
        : (eveningHour == 0 ? 12 : eveningHour);
    final m = eveningMinute.toString().padLeft(2, '0');
    final period = eveningHour >= 12 ? 'م' : 'ص';
    return '$h:$m $period';
  }
}
