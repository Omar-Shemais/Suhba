import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/core/services/notification_settings_manager.dart';
import 'package:islamic_app/features/quran/data/services/surah_audio_download_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (methodCall) async => null,
    );
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('NotificationSettingsManager Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('turnOffAllNotifications turns off master and all sub-notifications', () async {
      // First turn everything on
      await NotificationSettingsManager.turnOnAllNotifications();
      expect(await NotificationSettingsManager.isMasterEnabled(), isTrue);
      expect(await NotificationSettingsManager.isPrayerMasterEnabled(), isTrue);
      expect(await NotificationSettingsManager.isFajrSpecificEnabled(), isTrue);
      expect(await NotificationSettingsManager.isPrayerIndividualEnabled('dhuhr'), isTrue);
      expect(await NotificationSettingsManager.isMondayThursdayFastingEnabled(), isTrue);
      expect(await NotificationSettingsManager.isFridayKahfEnabled(), isTrue);
      expect(await NotificationSettingsManager.isKhatmahReminderEnabled(), isTrue);

      // Now turn all off
      await NotificationSettingsManager.turnOffAllNotifications();
      expect(await NotificationSettingsManager.isMasterEnabled(), isFalse);
      expect(await NotificationSettingsManager.isPrayerMasterEnabled(), isFalse);
      expect(await NotificationSettingsManager.isFajrSpecificEnabled(), isFalse);
      expect(await NotificationSettingsManager.isPrayerIndividualEnabled('dhuhr'), isFalse);
      expect(await NotificationSettingsManager.isMondayThursdayFastingEnabled(), isFalse);
      expect(await NotificationSettingsManager.isFridayKahfEnabled(), isFalse);
      expect(await NotificationSettingsManager.isKhatmahReminderEnabled(), isFalse);
    });

    test('setMasterEnabled(false) calls turnOffAllNotifications', () async {
      await NotificationSettingsManager.turnOnAllNotifications();
      await NotificationSettingsManager.setMasterEnabled(false);

      expect(await NotificationSettingsManager.isMasterEnabled(), isFalse);
      expect(await NotificationSettingsManager.isPrayerMasterEnabled(), isFalse);
      expect(await NotificationSettingsManager.isPrayerIndividualEnabled('asr'), isFalse);
    });
  });

  group('SurahAudioDownloadService Status Notifier Tests', () {
    test('statusNotifier increments and isSurahLocallyDownloaded queries correctly', () {
      final service = SurahAudioDownloadService();
      expect(service.statusNotifier.value, isNotNull);
      expect(service.isSurahLocallyDownloaded(99999), isFalse);
    });
  });
}
