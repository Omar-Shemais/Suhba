import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import 'package:islamic_app/features/khatmah/data/helpers/khatmah_manager.dart';
import 'package:islamic_app/features/prayer_times/presentation/cubit/prayer_cubit.dart';
import '../models/notification_item_model.dart';

class NotificationsFeedService {
  static const String _readKey = 'read_notification_ids';
  static const String _readDateKey = 'read_notifications_date';

  /// منبه تفاعلي لإخطار واجهات التطبيق (شريط الرأس والصفحة) بأي تغير فوري في عدد الإشعارات غير المقروءة
  static final ValueNotifier<int> alertsCountNotifier = ValueNotifier<int>(0);

  static const List<String> _hijriMonthsAr = [
    'المحرّم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  // تحويل التاريخ الميلادي إلى التاريخ الهجري بدون إنترنت
  static ({int year, int month, int day}) _getHijriDate(DateTime date) {
    var y = date.year;
    var m = date.month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        date.day +
        b -
        1524;
    var l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    final j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
        (l / 5670).floor() * ((43 * l) / 15238).floor();
    l = l -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final monthH = ((24 * l) / 709).floor();
    final dayH = l - ((709 * monthH) / 24).floor();
    final yearH = 30 * n + j - 30;
    return (year: yearH, month: monthH, day: dayH);
  }

  /// جلب معرّفات الإشعارات التي قرأها المستخدم اليوم
  static Future<Set<String>> getReadNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final savedDate = prefs.getString(_readDateKey);

      if (savedDate != null && savedDate != todayStr) {
        // يوم جديد: إعادة تصفير الإشعارات المقروءة لتبدأ التنبيهات اليومية كجديدة
        await prefs.setString(_readDateKey, todayStr);
        await prefs.setStringList(_readKey, []);
        return {};
      }
      if (savedDate == null) {
        await prefs.setString(_readDateKey, todayStr);
      }

      final list = prefs.getStringList(_readKey) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  /// تحديد إشعار معين كمقروء عند الضغط عليه وتحديث العداد فورياً
  static Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await prefs.setString(_readDateKey, todayStr);

      final list = (prefs.getStringList(_readKey) ?? []).toSet();
      list.add(id);
      await prefs.setStringList(_readKey, list.toList());

      // تحديث العداد
      final count = await getAlertsCount();
      alertsCountNotifier.value = count;
    } catch (_) {}
  }

  /// تحديد كافة الإشعارات كمقروءة دفعة واحدة وتصفير العداد
  static Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await prefs.setString(_readDateKey, todayStr);

      final items = await getNotifications();
      final allIds = items.map((i) => i.id).toList();
      await prefs.setStringList(_readKey, allIds);

      alertsCountNotifier.value = 0;
    } catch (_) {}
  }

  /// جلب قائمة الإشعارات اليومية والتنبيهات المحدثة ديناميكياً بحسب اليوم والوقت وحالة القراءة
  static Future<List<NotificationItemModel>> getNotifications() async {
    final now = DateTime.now();
    final hijri = _getHijriDate(now);
    final khatmah = await KhatmahManager.getActiveKhatmah();
    final readIds = await getReadNotificationIds();

    final List<NotificationItemModel> list = [];

    // 1. تذكير صيام الإثنين والخميس (ديناميكي ودقيق لجميع أيام الأسبوع)
    String fastingTitle;
    String fastingSubtitle;
    String fastingTime;
    NotificationDotColor fastingDotColor;

    switch (now.weekday) {
      case DateTime.sunday:
        fastingTitle = 'غداً الاثنين يستحب صيام يوم الاثنين';
        fastingSubtitle =
            'قال ﷺ: «تُعرض الأعمال يوم الإثنين والخميس فأحب أن يعرض عملي وأنا صائم».';
        fastingTime = 'اليوم (تذكير بالصيام)';
        fastingDotColor = NotificationDotColor.red;
        break;

      case DateTime.monday:
        fastingTitle = 'اليوم صيام الإثنين المبارك';
        fastingSubtitle =
            'تقبل الله طاعتكم، قال ﷺ: «للصائم فرحتان: فرحة عند فطره، وفرحة عند لقاء ربه».';
        fastingTime = 'اليوم (يوم الصيام)';
        fastingDotColor = NotificationDotColor.green;
        break;

      case DateTime.tuesday:
        fastingTitle = 'صيام السنن: بعد غد صيام يوم الخميس';
        fastingSubtitle =
            'قال ﷺ: «تُعرض الأعمال يوم الإثنين والخميس» فاستعد لنيل الأجر والثواب.';
        fastingTime = 'اليوم';
        fastingDotColor = NotificationDotColor.amber;
        break;

      case DateTime.wednesday:
        fastingTitle = 'غداً الخميس يستحب صيام يوم الخميس';
        fastingSubtitle =
            'قال ﷺ: «تُعرض الأعمال يوم الإثنين والخميس فأحب أن يعرض عملي وأنا صائم».';
        fastingTime = 'اليوم (تذكير بالصيام)';
        fastingDotColor = NotificationDotColor.red;
        break;

      case DateTime.thursday:
        fastingTitle = 'اليوم صيام الخميس المبارك';
        fastingSubtitle =
            'تقبل الله طاعتكم، قال ﷺ: «للصائم فرحتان: فرحة عند فطره، وفرحة عند لقاء ربه».';
        fastingTime = 'اليوم (يوم الصيام)';
        fastingDotColor = NotificationDotColor.green;
        break;

      case DateTime.friday:
        fastingTitle = 'صيام السنن: الصيام القادم يوم الإثنين';
        fastingSubtitle =
            'من سنن المصطفى ﷺ صيام الإثنين والخميس فاحرص على أجرها.';
        fastingTime = 'اليوم';
        fastingDotColor = NotificationDotColor.green;
        break;

      case DateTime.saturday:
      default:
        fastingTitle = 'تذكير: بعد غد صيام يوم الإثنين';
        fastingSubtitle =
            'قال ﷺ: «تُعرض الأعمال يوم الإثنين والخميس» فاستعد لنيل الأجر والثواب.';
        fastingTime = 'اليوم';
        fastingDotColor = NotificationDotColor.amber;
        break;
    }

    list.add(
      NotificationItemModel(
        id: 'fasting_mon_thu',
        title: fastingTitle,
        subtitle: fastingSubtitle,
        time: fastingTime,
        dotColor: fastingDotColor,
        icon: Icons.event_note_rounded,
        iconStyle: NotificationIconStyle.green,
        route: AppRoutes.fastingSunan,
        isPriority: true,
        isRead: readIds.contains('fasting_mon_thu'),
      ),
    );

    // 2. تذكير صيام الأيام البيض (حقيقي ومحسوب بدقة وفق التقويم الهجري)
    final currentMonthName = (hijri.month >= 1 && hijri.month <= 12)
        ? _hijriMonthsAr[hijri.month - 1]
        : 'الشهر الهجري';

    String whiteDaysTitle;
    String whiteDaysSubtitle;
    NotificationDotColor whiteDaysDotColor;

    if (hijri.day == 12) {
      whiteDaysTitle = 'غداً أول أيام الأيام البيض (١٣ $currentMonthName)';
      whiteDaysSubtitle =
          'يستحب صيام الأيام البيض (١٣، ١٤، ١٥)، قال ﷺ: «صيام ثلاثة أيام من كل شهر صيام الدهر».';
      whiteDaysDotColor = NotificationDotColor.red;
    } else if (hijri.day == 13) {
      whiteDaysTitle = 'اليوم أول أيام الأيام البيض (١٣ $currentMonthName)';
      whiteDaysSubtitle =
          'تقبل الله صيامكم وطاعتكم، صيام الأيام البيض كصيام الدهر.';
      whiteDaysDotColor = NotificationDotColor.green;
    } else if (hijri.day == 14) {
      whiteDaysTitle = 'اليوم ثاني أيام الأيام البيض (١٤ $currentMonthName)';
      whiteDaysSubtitle =
          'تقبل الله صيامكم وطاعتكم، صيامها من سنن المصطفى ﷺ.';
      whiteDaysDotColor = NotificationDotColor.green;
    } else if (hijri.day == 15) {
      whiteDaysTitle = 'اليوم ثالث أيام الأيام البيض (١٥ $currentMonthName)';
      whiteDaysSubtitle =
          'ختام الأيام البيض لهذا الشهر المبارك، تقبل الله صالح الأعمال.';
      whiteDaysDotColor = NotificationDotColor.green;
    } else if (hijri.day < 12) {
      final daysLeft = 13 - hijri.day;
      final daysText = daysLeft == 1
          ? 'يوم واحد'
          : (daysLeft == 2 ? 'يومين' : '${_toArabicDigits(daysLeft)} أيام');
      whiteDaysTitle = 'صيام الأيام البيض لشهر $currentMonthName';
      whiteDaysSubtitle =
          'تبدأ الأيام البيض (١٣، ١٤، ١٥) بعد $daysText، فاستعد لنيل أجرها وثوابها.';
      whiteDaysDotColor = NotificationDotColor.amber;
    } else {
      final nextMonthIndex = hijri.month % 12;
      final nextMonthName = _hijriMonthsAr[nextMonthIndex];
      whiteDaysTitle = 'صيام الأيام البيض القادمة';
      whiteDaysSubtitle =
          'تبدأ الأيام البيض القادمة يوم ١٣ من شهر $nextMonthName إن شاء الله.';
      whiteDaysDotColor = NotificationDotColor.green;
    }

    list.add(
      NotificationItemModel(
        id: 'white_days',
        title: whiteDaysTitle,
        subtitle: whiteDaysSubtitle,
        time: 'اليوم',
        dotColor: whiteDaysDotColor,
        icon: Icons.nightlight_round,
        iconStyle: NotificationIconStyle.green,
        route: AppRoutes.fastingSunan,
        isPriority: false,
        isRead: readIds.contains('white_days'),
      ),
    );

    // 3. المحافظة على الصلاة في وقتها (مرتبط ديناميكياً بالصلاة القادمة الحقيقية)
    String prayerSubtitle = 'الصلاة راحة للقلوب وطمأنينة للنفوس.';
    String prayerTime = 'اليوم';

    if (getIt.isRegistered<PrayerCubit>()) {
      try {
        final prayerState = getIt<PrayerCubit>().state;
        if (prayerState is PrayerLoaded && prayerState.nextPrayer != null) {
          final next = prayerState.nextPrayer!;
          prayerSubtitle =
              'الصلاة القادمة: صلاة ${next.name} (${next.time})، فحافظ عليها في وقتها.';
          prayerTime = 'اليوم ${next.time}';
        }
      } catch (_) {}
    }

    list.add(
      NotificationItemModel(
        id: 'prayer_time',
        title: 'لا تنس الصلاة في وقتها',
        subtitle: prayerSubtitle,
        time: prayerTime,
        dotColor: NotificationDotColor.red,
        icon: Icons.mosque_rounded,
        iconStyle: NotificationIconStyle.green,
        route: null,
        isPriority: true,
        isRead: readIds.contains('prayer_time'),
      ),
    );

    // 4. تذكير الورد القرآني اليومي (مرتبط بالختمة الفعلية)
    final String quranSubtitle = khatmah != null
        ? 'وردك الحالي: الجزء ${_toArabicDigits(khatmah.currentJuz)} من الختمة المباركة (اضغط للمتابعة).'
        : '«خيركم من تعلم القرآن وعلمه»، اقرأ وردك اليومي من آيات الله.';

    list.add(
      NotificationItemModel(
        id: 'daily_wird',
        title: 'لا تنس قراءة وردك اليومي',
        subtitle: quranSubtitle,
        time: 'اليوم',
        dotColor: NotificationDotColor.amber,
        icon: Icons.menu_book_rounded,
        iconStyle: NotificationIconStyle.bronze,
        route: khatmah != null ? AppRoutes.khatmah : AppRoutes.quran,
        isPriority: true,
        isRead: readIds.contains('daily_wird'),
      ),
    );

    // 5. الصلاة على النبي ﷺ (تفتح شيت الصلاة على النبي التفاعلي)
    final String salawatSubtitle = now.weekday == DateTime.friday
        ? 'قال ﷺ: «إن من أفضل أيامكم يوم الجمعة فأكثروا عليَّ من الصلاة فيه». (اضغط هنا)'
        : 'قال ﷺ: «من صلّى عليّ صلاة صلّى الله عليه بها عشراً». (اضغط هنا للتسبيح)';

    list.add(
      NotificationItemModel(
        id: 'salawat',
        title: 'هل صليت على النبي اليوم؟',
        subtitle: salawatSubtitle,
        time: 'اليوم',
        dotColor: NotificationDotColor.red,
        icon: Icons.spa_rounded,
        iconStyle: NotificationIconStyle.green,
        route: null,
        isPriority: true,
        isRead: readIds.contains('salawat'),
      ),
    );

    // 6. الاستغفار وذكر الله بحسب وقت اليوم
    final hour = now.hour;
    String istighfarSubtitle;
    if (hour >= 4 && hour < 12) {
      istighfarSubtitle =
          'ابدأ صباحك بذكر الله واستغفاره، فهو يفتح لك أبواب الرزق والفرج.';
    } else if (hour >= 12 && hour < 18) {
      istighfarSubtitle =
          'حصن وقتك في المساء بذكر الله والاستغفار، فهو طمأنينة لقلبك.';
    } else {
      istighfarSubtitle =
          'استغفر الله في ليلك، قال تعالى: «وَبِالْأَسْحَارِ هُمْ يَسْتَغْفِرُونَ».';
    }

    list.add(
      NotificationItemModel(
        id: 'istighfar',
        title: 'استغفر الله وأذكره',
        subtitle: istighfarSubtitle,
        time: 'اليوم',
        dotColor: NotificationDotColor.green,
        icon: Icons.radio_button_checked_rounded,
        iconStyle: NotificationIconStyle.green,
        route: AppRoutes.azkar,
        isPriority: false,
        isRead: readIds.contains('istighfar'),
      ),
    );

    // 7. اقتراح اليوم للقراءة والتدبر
    list.add(
      NotificationItemModel(
        id: 'daily_suggestion',
        title: 'اقترح اليوم',
        subtitle: 'حاول قراءة جزء من القرآن بعد الصلاة لنيل البركة والسكينة.',
        time: 'اليوم',
        dotColor: NotificationDotColor.red,
        icon: Icons.auto_stories_rounded,
        iconStyle: NotificationIconStyle.green,
        route: AppRoutes.quran,
        isPriority: true,
        isRead: readIds.contains('daily_suggestion'),
      ),
    );

    // 8. صلة الرحم والتواصل الطيب
    list.add(
      NotificationItemModel(
        id: 'kinship',
        title: 'لا تنس صلة الرحم',
        subtitle:
            'قال ﷺ: «من أحب أن يُبسط له في رزقه ويُنسأ له في أثره فليصل رحمه».',
        time: 'اليوم',
        dotColor: NotificationDotColor.amber,
        icon: Icons.people_alt_rounded,
        iconStyle: NotificationIconStyle.bronze,
        isPriority: false,
        isRead: readIds.contains('kinship'),
      ),
    );

    // 9. اقتراح الأذكار بعد الصلوات
    list.add(
      NotificationItemModel(
        id: 'azkar_suggestion',
        title: 'اقترح عليك أيضًا',
        subtitle: 'المداومة على الأذكار اليومية بعد الصلوات المكتوبة.',
        time: 'اليوم',
        dotColor: NotificationDotColor.green,
        icon: Icons.lightbulb_outline_rounded,
        iconStyle: NotificationIconStyle.green,
        route: AppRoutes.afterPrayerAzkar,
        isPriority: true,
        isRead: readIds.contains('azkar_suggestion'),
      ),
    );

    return list;
  }

  /// عدد التنبيهات المهمة غير المقروءة التي تظهر في شارة الجرس
  /// يقل عند قراءة كل إشعار ويختفي عند تصفير العداد
  static Future<int> getAlertsCount() async {
    final items = await getNotifications();
    final count =
        items.where((item) => item.isPriority && !item.isRead).length;
    alertsCountNotifier.value = count;
    return count;
  }

  static String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => int.tryParse(d) != null ? arabicDigits[int.parse(d)] : d)
        .join('');
  }
}
