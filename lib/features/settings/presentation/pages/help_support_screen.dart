import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'help_and_support'.tr(),
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
                    // Modern Contact Support Section
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
                            color: AppColors.goldenPrimary.withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
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
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: const Icon(
                                  Icons.support_agent_rounded,
                                  color: AppColors.goldenPrimary,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'contact_support'.tr(),
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
                          SizedBox(height: 20.h),
                          _buildContactItem(
                            icon: Icons.email_outlined,
                            title: 'support_email'.tr(),
                            subtitle: 'support_email_address'.tr(),
                            onTap: () {
                              // TODO: Open email app
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Modern FAQs Section
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldenPrimary.withValues(
                              alpha: isDark ? 0.05 : 0.1,
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
                                    Icons.quiz_rounded,
                                    color: AppColors.goldenPrimary,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'faq'.tr(),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.brownPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildFAQItem(
                            question: 'faq_how_to_use_app'.tr(),
                            answer: 'faq_how_to_use_app_answer'.tr(),
                          ),
                          _buildDivider(),
                          _buildFAQItem(
                            question: 'faq_prayer_times_accuracy'.tr(),
                            answer: 'faq_prayer_times_accuracy_answer'.tr(),
                          ),
                          _buildDivider(),
                          _buildFAQItem(
                            question: 'faq_qibla_direction'.tr(),
                            answer: 'faq_qibla_direction_answer'.tr(),
                          ),
                          _buildDivider(),
                          _buildFAQItem(
                            question: 'faq_notifications'.tr(),
                            answer: 'faq_notifications_answer'.tr(),
                          ),
                          _buildDivider(),
                          _buildFAQItem(
                            question: 'faq_account_delete'.tr(),
                            answer: 'faq_account_delete_answer'.tr(),
                          ),
                          _buildDivider(),
                          _buildFAQItem(
                            question: 'faq_report_issue'.tr(),
                            answer: 'faq_report_issue_answer'.tr(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Modern App Info Card
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.goldenPrimary.withValues(alpha: 0.08),
                            theme.cardColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldenPrimary.withValues(
                              alpha: isDark ? 0.06 : 0.12,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
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
                              Icons.support_agent,
                              size: 48,
                              color: AppColors.goldenPrimary,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'support_team_available'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.9),
                              height: 1.6.h,
                              fontWeight: FontWeight.w500,
                            ),
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

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.goldenPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.goldenPrimary, size: 24),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.goldenPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Theme(
          data: ThemeData(
            dividerColor: Colors.transparent,
            splashColor: AppColors.goldenPrimary.withValues(alpha: 0.05),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 16,
            ),
            title: Text(
              question,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            iconColor: AppColors.goldenPrimary,
            collapsedIconColor: theme.colorScheme.onSurfaceVariant,
            children: [
              Text(
                answer,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.9,
                  ),
                  height: 1.5.h,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1.h,
        color: AppColors.goldenPrimary.withValues(alpha: 0.1),
      ),
    );
  }
}
