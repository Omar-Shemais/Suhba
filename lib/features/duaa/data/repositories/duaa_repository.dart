import 'package:flutter/material.dart';
import '../../../../core/local_database/duaa/daily_dua_local_database.dart';
import '../../../../core/local_database/duaa/dua_after_salah_local_database.dart';
import '../../../../core/local_database/duaa/dua_evening_local_database.dart';
import '../../../../core/local_database/duaa/dua_morning_local_database.dart';
import '../../../../core/local_database/duaa/ramadan/ramadan_local_database.dart';
import '../../../../core/local_database/duaa/travel_dua_local_database.dart';
import '../../../../core/local_database/duaa/when_doing_ablution.dart';
import '../../../../core/local_database/duaa/when_entering_and_leave_home.dart';
import '../../../../core/local_database/duaa/when_hearing_adhan.dart';
import '../../../../core/local_database/duaa/when_walking_up.dart';
import '../models/duaa_item.dart';

class DuaaRepository {
  static List<DuaaCategory>? _cachedCategories;

  static List<DuaaCategory> getCategories() {
    if (_cachedCategories != null) return _cachedCategories!;

    // 1. الأدعية اليومية
    final daily = DailyDuaLocalDatabase.dailyDua
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية يومية'))
        .toList();

    // 2. أدعية السفر
    final travel = TravelDuaLocalDatabase.travelDua
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية السفر'))
        .toList();

    // 3. أدعية الاستيقاظ من النوم
    final wakingUp = WhenWalkingUpDuaa.whenWalkingUpDuaa
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية الاستيقاظ'))
        .toList();

    // 4. أدعية الوضوء
    final ablution = WhenDoingAblution.whenDoingAblution
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية الوضوء'))
        .toList();

    // 5. أدعية دخول وخروج المنزل
    final home = WhenEnteringAndLeaveHome.whenEnteringAndLeaveHome
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية المنزل'))
        .toList();

    // 6. أدعية سماع الأذان
    final adhan = WhenHearingAdhan.whenHearingAdhan
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية الأذان'))
        .toList();

    // 7. أدعية بعد الصلاة
    final afterSalah = DuaAfterSalahLocalDatabase.duaAfterSalah
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية بعد الصلاة'))
        .toList();

    // 8. أدعية شهر رمضان
    final List<DuaaItem> ramadanItems = [];
    try {
      final ramadanMap = RamadanDuaa.ramadanDuaaJson['RamadanDuas'] as Map<String, dynamic>?;
      if (ramadanMap != null) {
        final fasting = (ramadanMap['ForFasting'] as List?) ?? [];
        final ashura = (ramadanMap['ForAshura'] as List?) ?? [];

        int id = 1;
        for (var item in fasting) {
          ramadanItems.add(DuaaItem.fromMap({
            'id': id++,
            'arabic': item['Arabic'],
            'translation': item['English'],
            'category': 'أدعية الصيام والإفطار',
          }));
        }
        for (var item in ashura) {
          ramadanItems.add(DuaaItem.fromMap({
            'id': id++,
            'arabic': item['Arabic'],
            'translation': item['English'],
            'category': 'أدعية العشر الأواخر وليلة القدر',
          }));
        }
      }
    } catch (_) {}

    // 9. أدعية الصباح
    final morning = DuaMorningLocalDatabase.duaMorning
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية الصباح'))
        .toList();

    // 10. أدعية المساء
    final evening = DuaEveningLocalDatabase.duaEvening
        .map((e) => DuaaItem.fromMap(e, defaultCategory: 'أدعية المساء'))
        .toList();

    _cachedCategories = [
      DuaaCategory(
        id: 'daily',
        titleAr: 'أدعية يومية',
        titleEn: 'Daily Duas',
        descriptionAr: 'الأدعية المأثورة في سائر شؤون اليوم والليلة',
        icon: Icons.calendar_today_rounded,
        accentColor: const Color(0xFFD4941C),
        items: daily,
      ),
      DuaaCategory(
        id: 'travel',
        titleAr: 'أدعية السفر',
        titleEn: 'Travel Duas',
        descriptionAr: 'دعاء ركوب الدابة، والمسير، والرجوع من السفر',
        icon: Icons.flight_takeoff_rounded,
        accentColor: const Color(0xFF3498DB),
        items: travel,
      ),
      DuaaCategory(
        id: 'waking_up',
        titleAr: 'أدعية الاستيقاظ',
        titleEn: 'Waking Up',
        descriptionAr: 'الأدعية المأثورة عند الاستيقاظ من النوم والحمد لله',
        icon: Icons.wb_sunny_outlined,
        accentColor: const Color(0xFFE67E22),
        items: wakingUp,
      ),
      DuaaCategory(
        id: 'ablution',
        titleAr: 'أدعية الوضوء',
        titleEn: 'Ablution Duas',
        descriptionAr: 'ما يُقال عند الطهارة وأعضاء الوضوء وبعد الفراغ منه',
        icon: Icons.water_drop_rounded,
        accentColor: const Color(0xFF1ABC9C),
        items: ablution,
      ),
      DuaaCategory(
        id: 'home',
        titleAr: 'دخول وخروج المنزل',
        titleEn: 'Home Duas',
        descriptionAr: 'حصن البيت والتوكل على الله عند الخروج والدخول',
        icon: Icons.home_rounded,
        accentColor: const Color(0xFF9B59B6),
        items: home,
      ),
      DuaaCategory(
        id: 'adhan',
        titleAr: 'أدعية الأذان',
        titleEn: 'Adhan Duas',
        descriptionAr: 'إجابة المؤذن والدعاء بالوسيلة والفضيلة',
        icon: Icons.notifications_active_rounded,
        accentColor: const Color(0xFFE74C3C),
        items: adhan,
      ),
      DuaaCategory(
        id: 'after_salah',
        titleAr: 'أدعية بعد الصلاة',
        titleEn: 'After Salah',
        descriptionAr: 'الاستغفار والتسبيحات والدعوات المأثورة دبر الصلوات',
        icon: Icons.mosque_rounded,
        accentColor: const Color(0xFF27AE60),
        items: afterSalah,
      ),
      DuaaCategory(
        id: 'ramadan',
        titleAr: 'أدعية شهر رمضان',
        titleEn: 'Ramadan Duas',
        descriptionAr: 'أدعية الصيام والإفطار والعشر الأواخر وليلة القدر',
        icon: Icons.nights_stay_rounded,
        accentColor: const Color(0xFFF1C40F),
        items: ramadanItems,
      ),
      DuaaCategory(
        id: 'morning_dua',
        titleAr: 'أدعية الصباح',
        titleEn: 'Morning Duas',
        descriptionAr: 'الأدعية النبوية المباركة لحصن الصباح والبركة',
        icon: Icons.wb_twilight_rounded,
        accentColor: const Color(0xFFF39C12),
        items: morning,
      ),
      DuaaCategory(
        id: 'evening_dua',
        titleAr: 'أدعية المساء',
        titleEn: 'Evening Duas',
        descriptionAr: 'الأدعية النبوية المأثورة لسكينة المساء والحفظ',
        icon: Icons.bedtime_rounded,
        accentColor: const Color(0xFF4A6FA5),
        items: evening,
      ),
    ];

    return _cachedCategories!;
  }

  static List<DuaaItem> getAllDuas() {
    final categories = getCategories();
    final List<DuaaItem> all = [];
    for (var cat in categories) {
      all.addAll(cat.items);
    }
    return all;
  }

  static List<DuaaItem> searchDuas(String query) {
    if (query.trim().isEmpty) return [];
    final cleanQuery = query.trim().toLowerCase();
    final all = getAllDuas();

    return all.where((item) {
      final inArabic = item.arabic.toLowerCase().contains(cleanQuery);
      final inTranslation = item.translation.toLowerCase().contains(cleanQuery);
      final inCategory = item.category.toLowerCase().contains(cleanQuery);
      return inArabic || inTranslation || inCategory;
    }).toList();
  }
}
