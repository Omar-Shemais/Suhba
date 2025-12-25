// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import '../../data/models/prayer_times_model.dart';
import '../cubit/prayer_cubit.dart';

class PrayerDateCard extends StatelessWidget {
  final String date;
  final String hijriDate;
  final String enHijriDate;

  final String timeRemaining;
  final PrayerInfo prayer;
  final String city;
  final String country;

  const PrayerDateCard({
    super.key,
    required this.date,
    required this.hijriDate,
    required this.timeRemaining,
    required this.prayer,
    required this.city,
    required this.country,
    required this.enHijriDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark
                ? AppColors.primaryDarkColor.withOpacity(0.09)
                : AppColors.primaryColor.withOpacity(0.09),
            isDark
                ? AppColors.primaryDarkColor.withOpacity(0.05)
                : AppColors.primaryColor.withOpacity(0.05),
            isDark
                ? AppColors.primaryDarkColor.withOpacity(0.005)
                : AppColors.primaryColor.withOpacity(0.005),
            isDark ? Colors.transparent : Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // القسم الأول (الوقت المتبقي)
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('remaming_time'.tr(), style: AppTextStyles.secondary),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        isArabic ? prayer.nameAr : prayer.name,
                        style: AppTextStyles.subHead,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(timeRemaining, style: AppTextStyles.subHead),
                  ],
                ),
              ],
            ),
          ),

          // الخط الفاصل
          SizedBox(
            height: 40.h,
            child: VerticalDivider(
              color: isDark
                  ? AppColors.primaryDarkColor.withOpacity(0.5)
                  : AppColors.primaryColor.withOpacity(0.5),
              thickness: 3,
              width: 25.w,
            ),
          ),

          // القسم الثاني (المدينة والتاريخ الهجري)
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        isArabic ? hijriDate : enHijriDate,
                        style: AppTextStyles.secondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // ✅ استبدل الـ BlocBuilder القديم في PrayerDateCard بهذا الكود
                    BlocBuilder<PrayerCubit, PrayerState>(
                      builder: (context, state) {
                        // نتحقق لو الـ state هو PrayerLocationLoading
                        final isLoading = state is PrayerLocationLoading;

                        return InkWell(
                          onTap: isLoading
                              ? null
                              : () {
                                  context.read<PrayerCubit>().refreshLocation();
                                },
                          child: isLoading
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    valueColor: AlwaysStoppedAnimation(
                                      isDark
                                          ? AppColors.primaryDarkColor
                                          : AppColors.primaryColor,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  size: 18.sp,
                                  color: isDark
                                      ? AppColors.primaryDarkColor
                                      : AppColors.primaryColor,
                                ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  "$city, $country",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subHead,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
