import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide.none,
        ),
        icon: isLoading
            ? const SizedBox.shrink()
            : Icon(
                Icons.apple,
                size: 28,
                color: isDark ? Colors.black : Colors.white,
              ),
        label: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.black : Colors.white,
                  ),
                ),
              )
            : Text(
                'sign_in_with_apple'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
      ),
    );
  }
}