import 'package:shared_preferences/shared_preferences.dart';

class MushafStorageHelper {
  static const String _lastPageKey = 'mushaf_last_page';
  static const String _textScaleKey = 'mushaf_text_scale';
  static const String _bookmarkKey = 'mushaf_bookmark'; // علامة واحدة فقط

  // ✅ حفظ آخر صفحة
  static Future<void> saveLastPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPageKey, pageNumber);
  }

  // ✅ استرجاع آخر صفحة
  static Future<int> getLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastPageKey) ?? 0; // الافتراضي: أول صفحة
  }

  // ✅ حفظ حجم النص
  static Future<void> saveTextScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, scale);
  }

  // ✅ استرجاع حجم النص
  static Future<double> getTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_textScaleKey) ?? 1.0; // الافتراضي: 1.0
  }

  // ✅ حفظ العلامة المرجعية (واحدة فقط)
  static Future<void> setBookmark(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bookmarkKey, pageNumber);
  }

  // ✅ استرجاع العلامة المرجعية
  static Future<int?> getBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bookmarkKey);
  }

  // ✅ حذف العلامة المرجعية
  static Future<void> removeBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarkKey);
  }

  // ✅ التحقق من وجود علامة مرجعية على صفحة معينة
  static Future<bool> isBookmarked(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmark = prefs.getInt(_bookmarkKey);
    return bookmark == pageNumber;
  }

  // ✅ مسح كل البيانات
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPageKey);
    await prefs.remove(_textScaleKey);
    await prefs.remove(_bookmarkKey);
  }
}
