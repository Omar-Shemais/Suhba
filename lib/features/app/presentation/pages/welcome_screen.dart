import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                ).gradient,
          color: isDark ? theme.scaffoldBackgroundColor : null,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Islamic Pattern Background - Top Right
              Positioned(
                top: -50,
                right: -50,
                child: Opacity(
                  opacity: isDark ? 0.05 : 0.1,
                  child: Icon(
                    Icons.mosque,
                    size: 250,
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : AppColors.whiteColor,
                  ),
                ),
              ),

              // Islamic Pattern Background - Bottom Left
              Positioned(
                bottom: -30,
                left: -30,
                child: Opacity(
                  opacity: isDark ? 0.05 : 0.1,
                  child: Icon(
                    Icons.mosque,
                    size: 200,
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : AppColors.whiteColor,
                  ),
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),

                    // Welcome Title
                    Text(
                      'welcome_to_app'.tr(),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        shadows: isDark
                            ? null
                            : [
                                Shadow(
                                  color: AppColors.whiteColor.withValues(
                                    alpha: .5,
                                  ),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16.h),

                    // Subtitle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'app_description'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5.h,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Login Button with Gradient
                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldenGradient,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldenPrimary.withValues(
                              alpha: .4,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          context.go(AppRoutes.authLogin);
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
                            color: isDark
                                ? AppColors.blackColor
                                : AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Register Button
                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surface
                            : AppColors.whiteColor.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.goldenPrimary,
                          width: 1.w,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          context.go(AppRoutes.authRegister);
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

                    SizedBox(height: 24.h),

                    // Continue as Guest Button
                    TextButton(
                      onPressed: () {
                        context.go(AppRoutes.home);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'continue_as_guest'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Terms and Privacy
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'terms_agreement'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: .8,
                          ),
                          height: 1.4.h,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
