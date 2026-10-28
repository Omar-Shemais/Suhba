import 'package:shared_preferences/shared_preferences.dart';

enum QuranScrollMode {
  vertical, // من تحت لفوق (تمرير رأسي مستمر مع أوتوسكرول)
  horizontal, // من اليمين للشمال / أفقي (تقليب صفحات)
}

class QuranReadingModeHelper {
  static const String _keyScrollMode = 'quran_scroll_mode';
  static const String _keyHasChosen = 'quran_has_chosen_mode';
  static const String _keyAutoScrollSpeed = 'quran_auto_scroll_speed';
  static const String _keyShowTranslation = 'quran_show_translation';
  static const String _keyFontSize = 'quran_font_size';

  /// استرجاع نمط التمرير المحفوظ (الافتراضي رأسي)
  static Future<QuranScrollMode> getScrollMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_keyScrollMode);
    if (modeStr == 'vertical') {
      return QuranScrollMode.vertical;
    }
    return QuranScrollMode.horizontal;
  }

  /// حفظ نمط التمرير
  static Future<void> saveScrollMode(QuranScrollMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyScrollMode,
      mode == QuranScrollMode.horizontal ? 'horizontal' : 'vertical',
    );
    await prefs.setBool(_keyHasChosen, true);
  }

  /// هل قام المستخدم باختيار النمط من قبل؟
  static Future<bool> hasUserChosenMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasChosen) ?? false;
  }

  /// استرجاع سرعة التمرير التلقائي (الافتراضي 1.0)
  static Future<double> getAutoScrollSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyAutoScrollSpeed) ?? 1.0;
  }

  /// حفظ سرعة التمرير التلقائي
  static Future<void> saveAutoScrollSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAutoScrollSpeed, speed);
  }

  /// إظهار الترجمة أم إخفاؤها
  static Future<bool> getShowTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowTranslation) ?? false;
  }

  static Future<void> saveShowTranslation(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowTranslation, show);
  }

  /// حجم خط القرآن
  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyFontSize) ?? 22.5;
  }

  static Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, size);
  }
}
