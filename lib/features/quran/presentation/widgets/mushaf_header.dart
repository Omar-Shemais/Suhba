// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import 'package:islamic_app/core/constants/assets.dart';

class MushafHeader extends StatelessWidget {
  final String surahName;
  final String surahNameEnglish;

  const MushafHeader({
    super.key,
    required this.surahName,
    required this.surahNameEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.secondaryColor.withOpacity(0.4)
                : AppColors.primaryColor.withOpacity(0.3),
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.secondaryColor.withOpacity(0.1)
                : AppColors.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -2,
            right: -10,
            child: Image.asset(
              AssetsData.kaaba,
              width: 40.w,
              height: 40.h,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.3),
            ),
          ),
          Align(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Text(
                  surahName,
                  style: AppTextStyles.basmala(
                    context,
                  ).copyWith(fontSize: 30.sp),
                ),
                SizedBox(height: 5.h),
                Text(surahNameEnglish, style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
