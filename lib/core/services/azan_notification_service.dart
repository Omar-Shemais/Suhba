import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';

class AzanNotificationService {
  static final AzanNotificationService _instance =
      AzanNotificationService._internal();
  factory AzanNotificationService() => _instance;
  AzanNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const String _notificationsEnabledKey = 'prayer_notifications_enabled';
  static const String _channelId = 'prayer_times_adhan';
  static const String _channelName = 'Prayer Times - أوقات الصلاة';

  bool _isInitialized = false;

  /// تهيئة الإشعارات
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ الخدمة مهيأة بالفعل');
      return;
    }

    try {
      debugPrint('🔧 بدء تهيئة خدمة الإشعارات...');

      // ✅ تهيئة المناطق الزمنية
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      debugPrint('✅ تم تهيئة المناطق الزمنية');

      // ✅ إعداد قناة Android
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'إشعارات أوقات الصلاة مع صوت الأذان',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        enableVibration: true,
        enableLights: true,
      );

      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        debugPrint('✅ تم إنشاء قناة Android');
      }

      // ✅ إعدادات التهيئة
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      debugPrint('✅ تم تهيئة الإشعارات');

      // ✅ طلب الأذونات
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
        debugPrint('✅ تم طلب الأذونات');
      }

      // ✅ الاستماع لانتهاء الأذان
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _hideAdhanControlNotification();
        }
      });

      _isInitialized = true;
      debugPrint('✅ تم تهيئة خدمة الإشعارات بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة الإشعارات: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) async {
    debugPrint('🔔 تم الضغط على الإشعار: ${response.payload}');

    if (response.actionId == 'stop_adhan' || response.payload == 'stop_adhan') {
      await stopAdhan();
    } else if (response.actionId == 'dismiss') {
      await _notifications.cancel(response.id ?? 0);
    } else if (response.payload?.startsWith('prayer_time_') == true) {
      // لو الأبب مفتوح، شغّل AudioPlayer
      await playAdhan();
    }
  }

  /// جدولة إشعارات الصلاة
  Future<void> schedulePrayerNotifications(
    Map<String, String> prayerTimes,
  ) async {
    try {
      final enabled = await isNotificationsEnabled();
      if (!enabled) {
        debugPrint('⚠️ الإشعارات معطلة');
        return;
      }

      debugPrint('🔔 بدء جدولة الإشعارات...');

      // ✅ إلغاء الإشعارات القديمة
      await _notifications.cancelAll();
      debugPrint('✅ تم إلغاء الإشعارات القديمة');

      final prayers = {
        'fajr': {'name_ar': 'الفجر', 'name_en': 'Fajr', 'id': 1, 'emoji': '🌅'},
        'dhuhr': {
          'name_ar': 'الظهر',
          'name_en': 'Dhuhr',
          'id': 2,
          'emoji': '☀️',
        },
        'asr': {'name_ar': 'العصر', 'name_en': 'Asr', 'id': 3, 'emoji': '🌤️'},
        'maghrib': {
          'name_ar': 'المغرب',
          'name_en': 'Maghrib',
          'id': 4,
          'emoji': '🌇',
        },
        'isha': {
          'name_ar': 'العشاء',
          'name_en': 'Isha',
          'id': 5,
          'emoji': '🌙',
        },
      };

      int scheduledCount = 0;

      for (var entry in prayers.entries) {
        final prayerKey = entry.key;
        final prayerTime = prayerTimes[prayerKey];

        if (prayerTime == null) {
          debugPrint('⚠️ وقت $prayerKey غير موجود');
          continue;
        }

        final scheduledTime = _parseTimeToSchedule(prayerTime);
        if (scheduledTime == null) {
          debugPrint('⚠️ فشل تحليل وقت $prayerKey: $prayerTime');
          continue;
        }

        await _scheduleNotification(
          id: entry.value['id'] as int,
          titleAr: 'حان وقت صلاة ${entry.value['name_ar']}',
          titleEn: '${entry.value['name_en']} Prayer Time',
          emoji: entry.value['emoji'] as String,
          scheduledTime: scheduledTime,
          prayerKey: prayerKey,
        );

        scheduledCount++;
        debugPrint('✅ تم جدولة ${entry.value['name_ar']} في $scheduledTime');
      }

      debugPrint('✅ تم جدولة $scheduledCount إشعارات بنجاح');

      // ✅ عرض الإشعارات المجدولة
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 عدد الإشعارات المجدولة: ${pending.length}');
      for (var notif in pending) {
        debugPrint('   - ID: ${notif.id}, Title: ${notif.title}');
      }
    } catch (e) {
      debugPrint('❌ خطأ في جدولة الإشعارات: $e');
    }
  }

  /// تحليل الوقت وتحويله لجدولة
  tz.TZDateTime? _parseTimeToSchedule(String timeStr) {
    try {
      final cleanTime = timeStr.trim();
      final parts = cleanTime.split(' ');
      if (parts.isEmpty) return null;

      final timePart = parts[0];
      final period = parts.length > 1 ? parts[1].toUpperCase() : '';

      final timeParts = timePart.split(':');
      if (timeParts.length < 2) return null;

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // تحويل 12 ساعة إلى 24 ساعة
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // لو الوقت فات، جدوله بكره
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      return scheduledDate;
    } catch (e) {
      debugPrint('❌ خطأ في تحليل الوقت: $e');
      return null;
    }
  }

  /// جدولة إشعار واحد
  Future<void> _scheduleNotification({
    required int id,
    required String titleAr,
    required String titleEn,
    required String emoji,
    required tz.TZDateTime scheduledTime,
    required String prayerKey,
  }) async {
    try {
      // ✅ Android Details
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'إشعارات أوقات الصلاة مع صوت الأذان',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('azan'),
        enableVibration: true,
        enableLights: true,
        color: _getPrayerColor(prayerKey),
        ledColor: _getPrayerColor(prayerKey),
        ledOnMs: 1000,
        ledOffMs: 500,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        timeoutAfter: 120000, // 2 دقيقة
        autoCancel: false,
        styleInformation: BigTextStyleInformation(
          '🕌 الله أكبر، الله أكبر\n🤲 حي على الصلاة، حي على الفلاح\n\nAllahu Akbar, Allahu Akbar\nCome to prayer, Come to success',
          contentTitle: '$emoji $titleAr | $titleEn',
          htmlFormatContent: true,
          htmlFormatContentTitle: true,
        ),
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'dismiss',
            '✅ تم | Dismiss',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      // ✅ iOS Details
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'azan.caf',
        subtitle: titleEn,
        threadIdentifier: 'prayer_times',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        '$emoji $titleAr',
        titleEn,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        payload: 'prayer_time_$prayerKey',
      );
    } catch (e) {
      debugPrint('❌ خطأ في جدولة إشعار $titleEn: $e');
    }
  }

  /// الحصول على لون الصلاة
  Color _getPrayerColor(String prayerKey) {
    switch (prayerKey) {
      case 'fajr':
        return Colors.lightBlue;
      case 'dhuhr':
        return Colors.orange;
      case 'asr':
        return Colors.amber;
      case 'maghrib':
        return Colors.redAccent;
      case 'isha':
        return Colors.deepPurple;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  /// عرض نوتفكيشن التحكم بالأذان
  Future<void> showAdhanControlNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'adhan_control',
        'Adhan Control',
        channelDescription: 'Control adhan playback',
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: false,
        ongoing: true,
        autoCancel: false,
        color: Color(0xFF2E7D32),
        styleInformation: BigTextStyleInformation(
          'يمكنك إيقاف الأذان من خلال الضغط على الزر أدناه\nYou can stop the Adhan by tapping the button below',
          contentTitle: '🕌 الأذان يُرفع الآن | Adhan is Playing',
          htmlFormatContent: true,
        ),
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'stop_adhan',
            '⏹️ إيقاف الأذان | Stop Adhan',
            showsUserInterface: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
        subtitle: 'Adhan is Playing',
        interruptionLevel: InterruptionLevel.active,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999,
        '🕌 الأذان يُرفع الآن',
        'Adhan is Playing',
        details,
        payload: 'stop_adhan',
      );
    } catch (e) {
      debugPrint('❌ خطأ في عرض نوتفكيشن التحكم: $e');
    }
  }

  Future<void> _hideAdhanControlNotification() async {
    await _notifications.cancel(999);
  }

  /// تشغيل الأذان من Assets
  Future<void> playAdhan() async {
    try {
      debugPrint('🎵 بدء تشغيل الأذان...');

      await _audioPlayer.stop();
      await _audioPlayer.setAsset('assets/audio/azan.mp3');
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
      await showAdhanControlNotification();

      debugPrint('✅ تم تشغيل الأذان بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل الأذان: $e');
    }
  }

  /// إيقاف الأذان
  Future<void> stopAdhan() async {
    try {
      debugPrint('⏹️ إيقاف الأذان...');
      await _audioPlayer.stop();
      await _hideAdhanControlNotification();
      debugPrint('✅ تم إيقاف الأذان');
    } catch (e) {
      debugPrint('❌ خطأ في إيقاف الأذان: $e');
    }
  }

  /// تفعيل/تعطيل الإشعارات
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);

      if (!enabled) {
        await _notifications.cancelAll();
        await stopAdhan();
        debugPrint('✅ تم تعطيل الإشعارات');
      } else {
        debugPrint('✅ تم تفعيل الإشعارات');
      }
    } catch (e) {
      debugPrint('❌ خطأ في تغيير حالة الإشعارات: $e');
    }
  }

  /// التحقق من حالة الإشعارات
  Future<bool> isNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      debugPrint('❌ خطأ في قراءة حالة الإشعارات: $e');
      return true;
    }
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      await stopAdhan();
      debugPrint('✅ تم إلغاء جميع الإشعارات');
    } catch (e) {
      debugPrint('❌ خطأ في إلغاء الإشعارات: $e');
    }
  }

  /// الحصول على الإشعارات المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('❌ خطأ في الحصول على الإشعارات المجدولة: $e');
      return [];
    }
  }

  /// Dispose
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
