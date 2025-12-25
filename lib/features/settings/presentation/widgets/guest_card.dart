import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';

class GuestCard extends StatelessWidget {
  const GuestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  AppColors.whiteColor,
                  AppColors.whiteColor.withValues(alpha: .98),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? theme.colorScheme.surface : null,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldenPrimary.withValues(
              alpha: isDark ? 0.04 : 0.08,
            ),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldenPrimary.withValues(alpha: .15),
                  AppColors.goldenPrimary.withValues(alpha: .08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldenPrimary.withValues(alpha: .12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              size: 38,
              color: AppColors.goldenPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'sign_in_for_complete_experience'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5.h,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 55.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldenGradient,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldenPrimary.withValues(alpha: .3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutes.authLogin);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'sign_in'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.blackColor
                            : AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 55.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surface
                        : AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.goldenPrimary,
                      width: 2.w,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutes.authRegister);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'register'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
