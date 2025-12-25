import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                pinned: false,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                title: Text(
                  'about_app'.tr(),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.sp,
                  ),
                ),
                centerTitle: true,
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Modern App Logo and Name Card
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.cardColor,
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Animated Logo Container
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.goldenPrimary.withValues(
                                    alpha: 0.25,
                                  ),
                                  AppColors.goldenPrimary.withValues(
                                    alpha: 0.15,
                                  ),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldenPrimary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? theme.cardColor.withValues(alpha: 0.9)
                                    : AppColors.whiteColor.withValues(
                                        alpha: 0.9,
                                      ),
                              ),
                              child: const Icon(
                                Icons.mosque,
                                size: 64,
                                color: AppColors.goldenPrimary,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'app_name'.tr(),
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldenPrimary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColors.goldenPrimary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              'version'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldenPrimary,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'app_description'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.9),
                              height: 1.6.h,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Modern Features Section
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.goldenPrimary.withValues(
                                    alpha: 0.08,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.r),
                                topRight: Radius.circular(24.r),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldenPrimary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.goldenPrimary,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'app_features'.tr(),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildFeatureItem(
                            icon: Icons.book,
                            title: 'quran'.tr(),
                            description: 'quran_feature_desc'.tr(),
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            icon: Icons.article,
                            title: 'hadith'.tr(),
                            description: 'hadith_feature_desc'.tr(),
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            icon: Icons.wb_sunny,
                            title: 'azkar'.tr(),
                            description: 'azkar_feature_desc'.tr(),
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            icon: Icons.access_time,
                            title: 'prayer_times'.tr(),
                            description: 'prayer_times_feature_desc'.tr(),
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            icon: Icons.explore,
                            title: 'qibla'.tr(),
                            description: 'qibla_feature_desc'.tr(),
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            icon: Icons.location_on,
                            title: 'NearestMasjed'.tr(),
                            description: 'nearest_mosque_feature_desc'.tr(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Modern Developer Info Card
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                            theme.cardColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.goldenPrimary.withValues(
                                    alpha: 0.2,
                                  ),
                                  AppColors.goldenPrimary.withValues(
                                    alpha: 0.1,
                                  ),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.code,
                              size: 32,
                              color: AppColors.goldenPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'developed_by'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.goldenPrimary.withValues(
                                    alpha: 0.15,
                                  ),
                                  AppColors.goldenPrimary.withValues(
                                    alpha: 0.08,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.goldenPrimary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5.w,
                              ),
                            ),
                            child: Text(
                              'developer_name'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldenPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 18,
                                color: Colors.red.shade400,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'made_with_love'.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.85),
                                    height: 1.5.h,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              width: 1.w,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.goldenPrimary.withValues(alpha: 0.15),
                      AppColors.goldenPrimary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldenPrimary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.goldenPrimary, size: 26),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.85,
                        ),
                        height: 1.5.h,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1.h,
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
      ),
    );
  }
}
