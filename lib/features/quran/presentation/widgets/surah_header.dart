// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import 'package:islamic_app/core/constants/assets.dart';

class SurahHeader extends StatelessWidget {
  final String name;
  final String translation;
  final int numberOfAyahs;

  const SurahHeader({
    super.key,
    required this.name,
    required this.translation,
    required this.numberOfAyahs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryDarkColor
                  : AppColors.primaryLightColor,
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryDarkColor.withOpacity(0.1)
                  : AppColors.primaryLightColor.withOpacity(0.1),
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
                  SizedBox(height: 12.h),
                  Text(name, style: AppTextStyles.basmala(context)),
                  SizedBox(height: 5.h),

                  Text(
                    '$translation • $numberOfAyahs Ayahs',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    '﷽',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.basmala(context),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
