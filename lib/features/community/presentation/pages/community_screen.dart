import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/constants/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
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
      _showLoginPrompt();
    }
  }

  void _showLoginPrompt() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => PopScope(
        canPop: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 16.h),
              Text(
                'تسجيل الدخول مطلوب',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'يجب عليك تسجيل الدخول للوصول إلى المجتمع',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    context.push(AppRoutes.authLogin);
                  },
                  child: const Text('تسجيل الدخول'),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop();
                    context.push(AppRoutes.authRegister);
                  },
                  child: const Text('إنشاء حساب جديد'),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('إلغاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    // User is authenticated, show community content
                    return Center(
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
                    );
                  } else {
                    // User is not authenticated, show placeholder
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? theme.colorScheme.surface
                                    : AppColors.whiteColor.withValues(
                                        alpha: 0.7,
                                      ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock_outlined,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Text(
                              'تسجيل الدخول مطلوب',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'يجب عليك تسجيل الدخول للوصول إلى المجتمع',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
}
