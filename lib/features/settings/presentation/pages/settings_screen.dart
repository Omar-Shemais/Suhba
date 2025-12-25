import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/services/azan_notification_service.dart';
import '../../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../../core/theme/cubit/theme_state.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/guest_card.dart';
import '../widgets/settings_tile.dart';
import '../widgets/language_dialog.dart';
import '../../../../../core/widgets/modern_card.dart';
import '../../../../../core/widgets/section_title.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AzanNotificationService _notificationService =
      AzanNotificationService();
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationService.isNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    await _notificationService.setNotificationsEnabled(value);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? "prayer_notification_active".tr()
              : "prayer_notification_inactive".tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        backgroundColor: value ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'ok'.tr(),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    context.read<AuthCubit>().signOut();
  }

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
                  opacity: 0.08,
                  child: Icon(
                    Icons.settings_suggest,
                    size: 220,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              // Islamic Pattern Background - Bottom Left
              Positioned(
                bottom: -30,
                left: -30,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    Icons.tune,
                    size: 180,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),

              // Main Content
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        floating: true,
                        pinned: false,
                        title: Text(
                          'more'.tr(),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                          ),
                        ),
                        centerTitle: true,
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Auth Section
                            if (state is AuthAuthenticated) ...[
                              UserProfileCard(state: state),
                              SizedBox(height: 20.h),
                            ] else ...[
                              const GuestCard(),
                              SizedBox(height: 20.h),
                            ],

                            // Settings Section
                            SectionTitle(title: 'settings'.tr()),
                            SizedBox(height: 12.h),
                            ModernCard(
                              child: Column(
                                children: [
                                  SettingsTile(
                                    icon: Icons.language_outlined,
                                    title: 'language'.tr(),
                                    subtitle:
                                        context.locale.languageCode == 'ar'
                                        ? 'arabic'.tr()
                                        : 'english'.tr(),
                                    onTap: () => LanguageDialog.show(context),
                                  ),
                                  _buildDivider(),
                                  BlocBuilder<ThemeCubit, ThemeState>(
                                    builder: (context, themeState) {
                                      final isDark =
                                          themeState.themeMode ==
                                          ThemeMode.dark;
                                      return SettingsTile(
                                        icon: isDark
                                            ? Icons.dark_mode
                                            : Icons.light_mode,
                                        title: 'dark_mode'.tr(),
                                        subtitle: isDark
                                            ? 'dark_mode_on'.tr()
                                            : 'dark_mode_off'.tr(),
                                        trailing: Switch(
                                          value: isDark,
                                          activeTrackColor: AppColors
                                              .goldenPrimary
                                              .withValues(alpha: 0.5),
                                          activeThumbColor:
                                              AppColors.goldenPrimary,
                                          onChanged: (value) {
                                            context
                                                .read<ThemeCubit>()
                                                .toggleTheme();
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _isLoading
                                      ? _buildLoadingTile()
                                      : SettingsTile(
                                          icon: Icons.notifications_outlined,
                                          title: 'notifications'.tr(),
                                          subtitle: _notificationsEnabled
                                              ? "prayer_notification_active"
                                                    .tr()
                                              : "prayer_notification_inactive"
                                                    .tr(),
                                          trailing: Switch(
                                            value: _notificationsEnabled,
                                            activeThumbColor:
                                                AppColors.goldenPrimary,
                                            onChanged: _toggleNotifications,
                                          ),
                                        ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // About Section
                            SectionTitle(title: 'about'.tr()),
                            SizedBox(height: 12.h),
                            ModernCard(
                              child: Column(
                                children: [
                                  SettingsTile(
                                    icon: Icons.info_outline,
                                    title: 'about_app'.tr(),
                                    onTap: () => context.push(AppRoutes.about),
                                  ),
                                  _buildDivider(),
                                  SettingsTile(
                                    icon: Icons.privacy_tip_outlined,
                                    title: 'privacy_policy'.tr(),
                                    onTap: () =>
                                        context.push(AppRoutes.privacyPolicy),
                                  ),
                                  _buildDivider(),
                                  SettingsTile(
                                    icon: Icons.help_outline,
                                    title: 'help_and_support'.tr(),
                                    onTap: () =>
                                        context.push(AppRoutes.helpSupport),
                                  ),
                                ],
                              ),
                            ),

                            // Logout Button (only if authenticated)
                            if (state is AuthAuthenticated) ...[
                              SizedBox(height: 32.h),
                              _buildLogoutButton(context),
                            ],

                            SizedBox(height: 20.h),

                            // Version Info
                            Center(
                              child: Text(
                                'version'.tr(),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: .7),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingTile() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldenPrimary.withValues(alpha: .12),
                  AppColors.goldenPrimary.withValues(alpha: .08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.goldenPrimary,
              size: 21,
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إشعارات الصلاة',
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.goldenPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1.h,
        color: AppColors.goldenPrimary.withValues(alpha: .1),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : AppColors.whiteColor.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.errorColor, width: 2.w),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _handleSignOut(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        icon: const Icon(Icons.logout, color: AppColors.errorColor),
        label: Text(
          'sign_out'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.errorColor,
          ),
        ),
      ),
    );
  }
}
