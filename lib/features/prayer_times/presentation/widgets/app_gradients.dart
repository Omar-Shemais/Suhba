import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class AppGradients {
  // Radial Gradient موحد للـ AppBar والـ Banner
  static RadialGradient getRadialGradient(
    BuildContext context, {
    Alignment center = Alignment.center,
    double radius = 1.5,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RadialGradient(
      center: center,
      radius: radius,
      colors: [
        isDark
            ? AppColors.primaryDarkColor.withValues(alpha: .25)
            : AppColors.primaryColor.withValues(alpha: .25),
        isDark
            ? AppColors.primaryDarkColor.withValues(alpha: .12)
            : AppColors.primaryColor.withValues(alpha: .12),
        isDark
            ? AppColors.primaryDarkColor.withValues(alpha: .05)
            : AppColors.primaryColor.withValues(alpha: .05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
  }

  static LinearGradient getLinearGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        isDark
            ? AppColors.primaryDarkColor.withValues(alpha: .15)
            : AppColors.primaryColor.withValues(alpha: .15),
        isDark
            ? AppColors.primaryDarkColor.withValues(alpha: .08)
            : AppColors.primaryColor.withValues(alpha: .08),
        isDark
            ? AppColors.primaryDarkColor.withValues(alpha: .03)
            : AppColors.primaryColor.withValues(alpha: .03),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
  }
}
