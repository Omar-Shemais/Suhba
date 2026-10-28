// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../../data/models/prayer_times_model.dart';

class PrayerTimeCard extends StatelessWidget {
  final PrayerInfo prayer;

  const PrayerTimeCard({super.key, required this.prayer});

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

  @override
  Widget build(BuildContext context) {
    final isPassed = prayer.isPassed;
    final isNext = prayer.isNext;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      width: 76.w,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: isNext
            ? (isDark
                ? AppColors.primaryColor.withValues(alpha: 0.18)
                : AppColors.primaryColor.withValues(alpha: 0.12))
            : isPassed
                ? (isDark
                    ? AppColors.primaryDarkColor.withValues(alpha: 0.45)
                    : AppColors.containerColor.withValues(alpha: 0.55))
                : (isDark ? AppColors.primaryDarkColor : AppColors.containerColor),
        borderRadius: BorderRadius.circular(14.r),
        border: isNext
            ? Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.6),
                width: 1.2,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: isNext
                  ? AppColors.primaryColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPrayerIcon(prayer.name),
              color: isNext
                  ? AppColors.primaryColor
                  : isPassed
                      ? (isDark ? Colors.grey[500] : Colors.grey[600])
                      : AppColors.primaryColor,
              size: 20.sp,
            ),
          ),

          SizedBox(height: 4.h),

          // Prayer Name (Arabic / English)
          Text(
            isArabic ? prayer.nameAr : prayer.name,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
              color: isNext
                  ? AppColors.primaryColor
                  : isPassed
                      ? (isDark ? Colors.grey[400] : Colors.grey[600])
                      : (isDark ? Colors.white : AppColors.textPrimary),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 2.h),

          // Prayer Time
          Text(
            textDirection: TextDirection.ltr,
            prayer.time,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.bold,
              color: isNext
                  ? AppColors.primaryColor
                  : isPassed
                      ? (isDark ? Colors.grey[400] : Colors.grey[600])
                      : (isDark ? Colors.white : AppColors.textPrimary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
