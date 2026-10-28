import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';

class LoginPromptSheet extends StatelessWidget {
  const LoginPromptSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          const PopScope(canPop: false, child: LoginPromptSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.goldenGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldenPrimary.withValues(alpha: .3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_outlined,
              size: 48,
              color: AppColors.whiteColor,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'login_required'.tr(),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.brownPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'must_login_to_access_profile'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.brownSecondary,
              height: 1.5.h,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              gradient: AppColors.goldenGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldenPrimary.withValues(alpha: .3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                context.pop();
                context.push(AppRoutes.authLogin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'sign_in'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.goldenPrimary, width: 2.w),
            ),
            child: ElevatedButton(
              onPressed: () {
                context.pop();
                context.push(AppRoutes.authRegister);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'create_new_account'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldenPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () {
              context.pop();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.brownSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
