import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5.w,
          ),
        ),
        icon: isLoading
            ? const SizedBox.shrink()
            : Image.asset(
                'assets/images/google_logo.png',
                height: 24.h,
                width: 24.w,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to a colored icon if image not found
                  return const Icon(Icons.g_mobiledata, size: 32);
                },
              ),
        label: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Text(
                'sign_in_with_google'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
      ),
    );
  }
}
