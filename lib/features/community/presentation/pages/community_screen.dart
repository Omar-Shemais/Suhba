import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const LoginScreen(showBackButton: false);
        }

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'المجتمع',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark ? null : AppColors.backgroundGradient,
              color: isDark ? theme.scaffoldBackgroundColor : null,
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Background patterns
                  if (!isDark) ...[
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Opacity(
                        opacity: 0.05,
                        child: Icon(
                          Icons.groups,
                          size: 200,
                          color: AppColors.goldenPrimary,
                        ),
                      ),
                    ),
                  ],
                  if (isDark) ...[
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Opacity(
                        opacity: 0.03,
                        child: Icon(
                          Icons.groups,
                          size: 200,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                  // Main content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
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
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.groups,
                              size: 64,
                              color: AppColors.goldenPrimary,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            'مرحباً ${state.user.displayName ?? state.user.email}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'صفحة المجتمع',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'سيتم إضافة محتوى المجتمع هنا',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
