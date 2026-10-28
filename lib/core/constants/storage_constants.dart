class StorageConstants {
  // Hive Box Names
  static const String quranBoxName = 'quran_box';
  static const String hadithBoxName = 'hadith_box';
  static const String azkarBoxName = 'azkar_box';
  static const String prayerTimesBoxName = 'prayer_times_box';
  static const String userBoxName = 'user_box';
  static const String settingsBoxName = 'settings_box';
  static const String communityBoxName = 'community_box';
  static const String syncQueueBoxName = 'sync_queue_box';

  // Storage Keys
  static const String languageKey = 'language';
  static const String themeKey = 'theme_mode';
  static const String lastReadPositionKey = 'last_read_position';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String isFirstTimeKey = 'is_first_time';
  static const String lastSyncTimeKey = 'last_sync_time';

  // Prayer Times Keys
  static const String prayerTimeOffsetKey = 'prayer_time_offset';
  static const String adhanSoundKey = 'adhan_sound';
  static const String selectedCityKey = 'selected_city';
  static const String selectedCountryKey = 'selected_country';
  static const String latitudeKey = 'latitude';
  static const String longitudeKey = 'longitude';

  // Cache Settings
  static const int cacheDurationDays = 7;
  static const int communityCacheLimit = 50;

  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 10;

  // Private constructor to prevent instantiation
  StorageConstants._();
}
