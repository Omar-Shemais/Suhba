// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import '../../data/models/prayer_times_model.dart';

class PrayerTimeCard extends StatelessWidget {
  final PrayerInfo prayer;

  const PrayerTimeCard({super.key, required this.prayer});

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny;
      case '.hr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.cloud;
      case 'maghrib':
        return Icons.nights_stay;
      case 'isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = prayer.isPassed;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      width: 90.w,
      decoration: BoxDecoration(
        color: isPassed
            ? (isDark
                  ? AppColors.primaryDarkColor.withOpacity(0.5)
                  : AppColors.containerColor.withOpacity(0.5))
            : (isDark ? AppColors.primaryDarkColor : AppColors.containerColor),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getPrayerIcon(prayer.name),
              color: AppColors.primaryColor,
              size: 28.sp,
            ),
          ),

          SizedBox(height: 8.h),

          // Prayer Name (Arabic)
          Text(
            isArabic ? prayer.nameAr : prayer.name,
            style: AppTextStyles.textstyle14,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 4.h),

          // Prayer Time
          Text(
            textDirection: TextDirection.ltr,
            prayer.time,
            style: AppTextStyles.button,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
