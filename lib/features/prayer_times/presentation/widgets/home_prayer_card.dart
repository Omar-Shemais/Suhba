import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/prayer_times_model.dart';

class HomePrayerCard extends StatelessWidget {
  final PrayerInfo nextPrayer;
  final String timeRemaining;
  final List<PrayerInfo> prayers;

  const HomePrayerCard({
    super.key,
    required this.nextPrayer,
    required this.timeRemaining,
    required this.prayers,
  });

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight_rounded;
      case 'sunrise':
        return Icons.wb_sunny_rounded;
      case 'dhuhr':
      case '.hr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.cloud_outlined;
      case 'maghrib':
        return Icons.nights_stay_rounded;
      case 'isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time_rounded;
    }
  }

  String _cleanTime(String time) {
    final trimmed = time.trim();
    if (trimmed.contains(' ')) {
      return trimmed.split(' ').first;
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // القسم العلوي: الصلاة القادمة واسمها على جانب، والعداد والوقت المتبقي على الجانب الآخر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الجانب الأول: الصلاة القادمة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصلاة القادمة',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFB5A495)
                            : const Color(0xFF9E8B7A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      nextPrayer.nameAr,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: isDark
                            ? const Color(0xFFF0F2F5)
                            : const Color(0xFF38271B),
                      ),
                    ),
                  ],
                ),
              ),

              // الجانب الثاني: العداد التنازلي والوقت المتبقي
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeRemaining,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF2E7D5E)
                            : const Color(0xFF143427),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'الوقت المتبقي',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFB5A495)
                            : const Color(0xFF9E8B7A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // خط فاصل ناعم
          Divider(
            color: isDark
                ? const Color(0xFF383E46)
                : const Color(0xFFEFE6D8),
            height: 1,
            thickness: 1,
          ),

          SizedBox(height: 14.h),

          // شريط مواقيت الصلاة الستة بشكل أفقي مدمج ومريح
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: prayers.map((prayer) {
              final isNext = prayer.isNext;
              final isPassed = prayer.isPassed;

              final activeColor = isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427);
              final passedColor = isDark
                  ? const Color(0xFF7A6B5F)
                  : const Color(0xFFA6998C);
              final normalColor = isDark
                  ? const Color(0xFFD4C5B6)
                  : const Color(0xFF5A4839);

              final itemColor = isNext
                  ? activeColor
                  : isPassed
                      ? passedColor
                      : normalColor;

              return Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isNext
                        ? (isDark
                            ? activeColor.withValues(alpha: 0.14)
                            : const Color(0xFFF3E9DA))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // الأيقونة
                      Icon(
                        _getPrayerIcon(prayer.name),
                        size: 20.sp,
                        color: itemColor,
                      ),
                      SizedBox(height: 4.h),

                      // اسم الصلاة
                      Text(
                        prayer.nameAr,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                              isNext ? FontWeight.bold : FontWeight.w600,
                          color: itemColor,
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // وقت الصلاة
                      Text(
                        _cleanTime(prayer.time),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                              isNext ? FontWeight.bold : FontWeight.w600,
                          color: itemColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
