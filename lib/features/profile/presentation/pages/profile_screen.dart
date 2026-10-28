import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_account_title'.tr()),
        content: Text('delete_account_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthCubit>().deleteAccount();
    }
  }

  Future<void> _handlePhotoUpload() async {
    final imageFile = await ImagePickerService.showImageSourceDialog(context);

    if (imageFile != null && mounted) {
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
              // Background decorations
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  } else if (state is AuthUnauthenticated) {
                    // Navigate back or show message when account is deleted
                    context.pop();
                  }
                },
                builder: (context, state) {
                  if (state is AuthDeletingAccount) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 24),
                          Text(
                            'deleting_account'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AuthAuthenticated ||
                      state is AuthPhotoUploading) {
                    final user = state is AuthAuthenticated
                        ? state.user
                        : (state as AuthPhotoUploading).user;
                    final isUploadingPhoto = state is AuthPhotoUploading;

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
                              fontSize: 24,
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
                              const SizedBox(height: 20),

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

                              const SizedBox(height: 24),

                              // User Name
                              Text(
                                user.displayName ?? user.email.split('@')[0],
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              // User Email
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

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

                              const SizedBox(height: 16),

                              // Account Details Section
                              SectionTitle(title: 'account_details'.tr()),
                              const SizedBox(height: 12),

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

                              const SizedBox(height: 32),

                              // Logout Button
                              _buildLogoutButton(),

                              const SizedBox(height: 16),

                              // Delete Account Button
                              _buildDeleteAccountButton(),

                              const SizedBox(height: 40),
                            ]),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // User is not authenticated
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
                          const SizedBox(height: 32),
                          Text(
                            'login_required'.tr(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'must_login_to_access_profile'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5,
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
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : AppColors.whiteColor.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorColor, width: 2),
      ),
      child: ElevatedButton.icon(
        onPressed: _handleSignOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.logout, color: AppColors.errorColor),
        label: Text(
          'sign_out'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.errorColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : AppColors.whiteColor.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.errorColor.withValues(alpha: .5),
          width: 1.5,
        ),
      ),
      child: TextButton.icon(
        onPressed: _handleDeleteAccount,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          Icons.delete_forever,
          color: AppColors.errorColor.withValues(alpha: .8),
        ),
        label: Text(
          'delete_account'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.errorColor.withValues(alpha: .8),
          ),
        ),
      ),
    );
  }
}
