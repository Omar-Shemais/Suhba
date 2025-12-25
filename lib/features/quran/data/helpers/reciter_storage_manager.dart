import 'package:shared_preferences/shared_preferences.dart';

class ReciterStorageManager {
  static const String _keyReciterId = 'selected_reciter_id';
  static const String _keyReciterName = 'selected_reciter_name';
  static const String _keyReciterArabicName = 'selected_reciter_arabic_name';

  // ✅ حفظ الشيخ المختار
  static Future<void> saveSelectedReciter({
    required int reciterId,
    required String reciterName,
    required String reciterArabicName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReciterId, reciterId);
    await prefs.setString(_keyReciterName, reciterName);
    await prefs.setString(_keyReciterArabicName, reciterArabicName);
  }

  // ✅ استرجاع الشيخ المختار (الافتراضي: عبد الباسط - ID 2)
  static Future<int> getSelectedReciterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyReciterId) ?? 2; // الافتراضي: عبد الباسط
  }

  // ✅ استرجاع اسم الشيخ
  static Future<String> getSelectedReciterName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReciterName) ?? 'Abdul Basit Abdul Samad';
  }

  // ✅ استرجاع الاسم العربي للشيخ
  static Future<String> getSelectedReciterArabicName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReciterArabicName) ?? 'عبد الباسط عبد الصمد';
  }

  // ✅ مسح الشيخ المحفوظ
  static Future<void> clearSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyReciterId);
    await prefs.remove(_keyReciterName);
    await prefs.remove(_keyReciterArabicName);
  }
}
