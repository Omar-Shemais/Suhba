import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class CommunityStyles {
  CommunityStyles._();

  static BoxDecoration glassmorphicCard({
    Color? color,
    List<Color>? gradientColors,
    double borderRadius = 20,
    bool withBorder = true,
  }) {
    return BoxDecoration(
      gradient: gradientColors != null
          ? LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      color: color ?? Colors.white.withValues(alpha: .95),
      borderRadius: BorderRadius.circular(borderRadius),
      border: withBorder
          ? Border.all(color: Colors.white.withValues(alpha: .5), width: 1.5.w)
          : null,
      boxShadow: [
        BoxShadow(
          color: AppColors.goldenPrimary.withValues(alpha: .1),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -5,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration premiumCard({
    double borderRadius = 20,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.goldenPrimary.withValues(alpha: .15),
          blurRadius: 25,
          offset: const Offset(0, 10),
          spreadRadius: -8,
        ),
        BoxShadow(
          color: AppColors.brownSecondary.withValues(alpha: .08),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  static BoxDecoration gradientBorder({
    double borderRadius = 16,
    double borderWidth = 2,
    Gradient? gradient,
    required borderwidth,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.goldenTripleGradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  static BoxDecoration floatingButton() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          AppColors.goldenPrimary,
          AppColors.goldenSecondary,
          Color(0xFFA86B0D),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.goldenPrimary.withValues(alpha: .4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.goldenSecondary.withValues(alpha: .3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static TextStyle headingLarge = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.brownPrimary,
    letterSpacing: -0.5,
    height: 1.2.h,
  );

  static TextStyle headingMedium = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.brownPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    color: AppColors.brownPrimary.withValues(alpha: .9),
    height: 1.5.h,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    color: AppColors.brownSecondary.withValues(alpha: .9),
    height: 1.4.h,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    color: AppColors.brownSecondary.withValues(alpha: .7),
  );

  static TextStyle caption = TextStyle(
    fontSize: 11.sp,
    color: AppColors.brownSecondary.withValues(alpha: .6),
  );

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 12);
}
