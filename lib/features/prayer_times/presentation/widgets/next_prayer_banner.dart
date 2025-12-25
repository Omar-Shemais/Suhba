// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import 'package:islamic_app/core/constants/assets.dart';
import '../../data/models/prayer_times_model.dart';

class NextPrayerBanner extends StatelessWidget {
  final PrayerInfo prayer;
  final String title;

  const NextPrayerBanner({
    super.key,
    required this.prayer,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 235.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, 0.5),
          radius: 1,
          colors: [
            isDark
                ? AppColors.primaryDarkColor.withOpacity(0.8)
                : AppColors.primaryColor.withOpacity(0.8),
            isDark ? AppColors.primaryDarkColor.withOpacity(0.3) : Colors.white,
          ],
          stops: const [0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.primaryDarkColor.withOpacity(0.02)
                : AppColors.primaryColor.withOpacity(0.01),
            blurRadius: 20.r,
            spreadRadius: 5.r,
            offset: Offset(0, 5.r),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 15.h),

          SizedBox(
            height: 40.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          SizedBox(
            height: 180.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -15.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      textDirection: TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          textDirection: TextDirection.ltr,
                          prayer.hours,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.timeText.copyWith(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.nightlight_round,
                          color: AppColors.primaryColor,
                          size: 28.sp,
                        ),
                        SizedBox(width: 4.w),

                        Text(
                          textDirection: TextDirection.ltr,

                          prayer.minutes,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.timeText.copyWith(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10.h,
                  right: 10.w,
                  left: 10.w,
                  child: Image.asset(
                    AssetsData.game3,
                    width: double.infinity,
                    height: 140.h,
                    fit: BoxFit.fill,
                    opacity: isDark
                        ? const AlwaysStoppedAnimation(.3)
                        : const AlwaysStoppedAnimation(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
