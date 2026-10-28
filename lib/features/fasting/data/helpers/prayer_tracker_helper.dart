import 'package:shared_preferences/shared_preferences.dart';

/// مساعدة إدارة وتخزين ومتابعة الانتظام في الصلوات الخمس والسنن الرواتب محلياً
class PrayerTrackerHelper {
  static const String _prayerPrefix = 'prayer_tracker_';
  static const String _sunanPrefix = 'sunan_tracker_';

  static const List<String> prayerIds = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  static String _dateKey(DateTime date, String prefix) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$prefix$y-$m-$d';
  }

  /// جلب الصلوات الخمس المؤداة في تاريخ محدد (الافتراضي: اليوم)
  static Future<Set<String>> getCompletedPrayers({DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(date ?? DateTime.now(), _prayerPrefix);
    final list = prefs.getStringList(key) ?? [];
    return list.toSet();
  }

  /// تبديل حالة صلاة فريضة (مؤداة / غير مؤداة)
  static Future<bool> togglePrayer(String prayerId, {DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(date ?? DateTime.now(), _prayerPrefix);
    final list = (prefs.getStringList(key) ?? []).toSet();

    final bool nowCompleted;
    if (list.contains(prayerId)) {
      list.remove(prayerId);
      nowCompleted = false;
    } else {
      list.add(prayerId);
      nowCompleted = true;
    }

    await prefs.setStringList(key, list.toList());
    return nowCompleted;
  }

  /// جلب السنن والنوافل المؤداة في تاريخ محدد
  static Future<Set<String>> getCompletedSunan({DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(date ?? DateTime.now(), _sunanPrefix);
    final list = prefs.getStringList(key) ?? [];
    return list.toSet();
  }

  /// تبديل حالة سنة راتبة
  static Future<bool> toggleSunan(String sunanId, {DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(date ?? DateTime.now(), _sunanPrefix);
    final list = (prefs.getStringList(key) ?? []).toSet();

    final bool nowCompleted;
    if (list.contains(sunanId)) {
      list.remove(sunanId);
      nowCompleted = false;
    } else {
      list.add(sunanId);
      nowCompleted = true;
    }

    await prefs.setStringList(key, list.toList());
    return nowCompleted;
  }

  /// حساب أيام الانتظام المتتالية (Streak)
  /// يحسب الأيام المتواصلة التي أتم فيها المسلم صلواته الخمس كاملة
  static Future<int> getConsistencyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    int streak = 0;

    // فحص اليوم الحالي
    final todayKey = _dateKey(now, _prayerPrefix);
    final todayCompleted = (prefs.getStringList(todayKey) ?? []).toSet();
    final isTodayFull = prayerIds.every((id) => todayCompleted.contains(id));

    DateTime checkDate;
    if (isTodayFull) {
      streak++;
      checkDate = now.subtract(const Duration(days: 1));
    } else {
      // إذا لم يكتمل اليوم بعد (لأنه لم ينته)، نبدأ فحص الأيام السابقة
      checkDate = now.subtract(const Duration(days: 1));
    }

    // فحص الأيام السابقة يوماً بيوم
    for (int i = 0; i < 365; i++) {
      final key = _dateKey(checkDate, _prayerPrefix);
      final completed = (prefs.getStringList(key) ?? []).toSet();
      final isFull = prayerIds.every((id) => completed.contains(id));

      if (isFull) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// جلب تقدم آخر 7 أيام لعرضها في شريط المواظبة الأسبوعي
  static Future<List<Map<String, dynamic>>> getWeeklyHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final List<Map<String, dynamic>> history = [];

    // الأيام من 6 أيام مضت حتى اليوم
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date, _prayerPrefix);
      final completed = (prefs.getStringList(key) ?? []).toSet();

      history.add({
        'date': date,
        'dayName': _getShortDayName(date.weekday),
        'completedCount': completed.length,
        'isFull': completed.length == 5,
        'isToday': i == 0,
      });
    }

    return history;
  }

  static String _getShortDayName(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      default:
        return '';
    }
  }
}
