import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../../core/routes/app_routes.dart';

/// A mixin for screens that require authentication
///
/// Usage:
/// ```dart
/// class CommunityScreen extends StatefulWidget with AuthGuard {
///   @override
///   Widget buildAuthenticated(BuildContext context) {
///     return // Your authenticated screen content
///   }
/// }
/// ```
mixin AuthGuard on Widget {
  /// Build the authenticated content
  /// This method should be implemented by the screen that uses this mixin
  Widget buildAuthenticated(BuildContext context);

  /// Shows a login prompt dialog
  void _showLoginPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'يجب عليك تسجيل الدخول للوصول إلى هذه الميزة',
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
              onPressed: () => context.pop(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  /// Wraps the widget with auth check
  Widget withAuthGuard(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // User is authenticated, show the content
          return buildAuthenticated(context);
        } else if (state is AuthLoading || state is AuthInitial) {
          // Still loading, show loading indicator
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          // User is not authenticated, show login prompt
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLoginPrompt(context);
          });

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'تسجيل الدخول مطلوب',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'يجب عليك تسجيل الدخول للوصول إلى هذه الميزة',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutes.authLogin);
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
