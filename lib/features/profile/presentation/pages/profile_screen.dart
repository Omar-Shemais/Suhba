import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/image_picker_service.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../../../core/widgets/modern_card.dart';
import '../../../../../core/widgets/section_title.dart';
import '../widgets/login_prompt_sheet.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_detail_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth status when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowLoginPrompt();
    });
  }

  void _checkAndShowLoginPrompt() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      LoginPromptSheet.show(context);
    }
  }

  void _handleSignOut() {
    context.read<AuthCubit>().signOut();
  }

  Future<void> _handlePhotoUpload() async {
    // Show image picker dialog
    final imageFile = await ImagePickerService.showImageSourceDialog(context);

    if (imageFile != null && mounted) {
      // Upload photo using AuthCubit
      context.read<AuthCubit>().updateUserPhoto(imageFile);
    }
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
                  opacity: isDark ? 0.04 : 0.08,
                  child: Icon(
                    Icons.person,
                    size: 220,
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
                  opacity: isDark ? 0.04 : 0.08,
                  child: Icon(
                    Icons.account_circle,
                    size: 180,
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : AppColors.whiteColor,
                  ),
                ),
              ),

              // Main Content
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthAuthenticated ||
                      state is AuthPhotoUploading) {
                    final user = state is AuthAuthenticated
                        ? state.user
                        : (state as AuthPhotoUploading).user;
                    final isUploadingPhoto = state is AuthPhotoUploading;

                    // User is authenticated, show profile content
                    return CustomScrollView(
                      slivers: [
                        // App Bar
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          floating: true,
                          pinned: false,
                          title: Text(
                            'profile'.tr(),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.sp,
                            ),
                          ),
                          centerTitle: true,
                          leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: theme.colorScheme.onSurface,
                            ),
                            onPressed: () => context.pop(),
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              SizedBox(height: 20.h),

                              // Profile Avatar Section
                              Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: AppColors.goldenGradient,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.goldenPrimary
                                                .withValues(alpha: .4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: EditableUserAvatar(
                                        user: user,
                                        radius: 60,
                                        isLoading: isUploadingPhoto,
                                        onEditTap: isUploadingPhoto
                                            ? null
                                            : _handlePhotoUpload,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // User Name
                              Text(
                                user.displayName ?? user.email.split('@')[0],
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 8.h),

                              // User Email
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 32.h),

                              // Email Verification Status Card
                              ProfileInfoCard(
                                icon: user.emailVerified
                                    ? Icons.verified_user
                                    : Icons.warning_outlined,
                                iconColor: user.emailVerified
                                    ? AppColors.successColor
                                    : const Color(0xFFFF9800),
                                title: user.emailVerified
                                    ? 'email_verified'.tr()
                                    : 'email_not_verified'.tr(),
                                subtitle: user.emailVerified
                                    ? null
                                    : 'please_verify_email'.tr(),
                              ),

                              SizedBox(height: 16.h),

                              // Account Details Section
                              SectionTitle(title: 'account_details'.tr()),
                              SizedBox(height: 12.h),

                              ModernCard(
                                child: Column(
                                  children: [
                                    ProfileDetailRow(
                                      icon: Icons.calendar_today_outlined,
                                      title: 'joined_date'.tr(),
                                      value:
                                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 32.h),

                              // Logout Button
                              _buildLogoutButton(),

                              SizedBox(height: 40.h),
                            ]),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // User is not authenticated, show placeholder
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.surface
                                  : AppColors.whiteColor.withValues(alpha: .7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_off_outlined,
                              size: 80,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            'login_required'.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'must_login_to_access_profile'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5.h,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
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
        onPressed: _handleSignOut,
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
