import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                        color: AppColors.goldenPrimary.withValues(alpha: 0.1),
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
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.privacy_tip_rounded,
                      color: AppColors.goldenPrimary,
                      size: 24,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'privacy_policy'.tr(),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.cardColor,
                            theme.colorScheme.primary.withValues(alpha: 0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldenPrimary.withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            title: 'privacy_intro_title'.tr(),
                            content: 'privacy_intro_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          _buildSection(
                            title: 'privacy_data_collection_title'.tr(),
                            content: 'privacy_data_collection_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          _buildSection(
                            title: 'privacy_data_usage_title'.tr(),
                            content: 'privacy_data_usage_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          _buildSection(
                            title: 'privacy_data_storage_title'.tr(),
                            content: 'privacy_data_storage_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          _buildSection(
                            title: 'privacy_data_sharing_title'.tr(),
                            content: 'privacy_data_sharing_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          _buildSection(
                            title: 'privacy_user_rights_title'.tr(),
                            content: 'privacy_user_rights_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          _buildSection(
                            title: 'privacy_security_title'.tr(),
                            content: 'privacy_security_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          _buildSection(
                            title: 'privacy_changes_title'.tr(),
                            content: 'privacy_changes_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          _buildSection(
                            title: 'privacy_contact_title'.tr(),
                            content: 'privacy_contact_content'.tr(),
                          ),
                          SizedBox(height: 24.h),
                          Center(
                            child: Text(
                              'privacy_last_updated'.tr(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.goldenPrimary,
                      AppColors.goldenPrimary.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brownPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.brownSecondary.withValues(alpha: 0.9),
                height: 1.7.h,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
