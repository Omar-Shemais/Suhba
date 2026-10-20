import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FacebookSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const FacebookSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  static const String _facebookSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#1877F2" d="M24 0C10.74 0 0 10.74 0 24c0 11.99 8.79 21.93 20.25 23.73V30.97h-6.09V24h6.09v-5.31c0-6.01 3.58-9.34 9.07-9.34 2.62 0 5.37.47 5.37.47v5.91h-3.03c-2.98 0-3.91 1.85-3.91 3.75V24h6.66l-1.07 6.97h-5.59v16.76C39.21 45.93 48 35.99 48 24 48 10.74 37.26 0 24 0z"/>
  <path fill="#FFFFFF" d="M33.26 30.97L34.33 24h-6.66v-4.52c0-1.9.93-3.75 3.91-3.75h3.03v-5.91s-2.75-.47-5.37-.47c-5.49 0-9.07 3.33-9.07 9.34V24h-6.09v6.97h6.09v16.76c1.22.19 2.47.29 3.75.29s2.53-.1 3.75-.29V30.97h5.59z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.12),
            width: 1.2.w,
          ),
          elevation: isDark ? 0 : 0.5,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: isLoading
            ? SizedBox(
                height: 22.h,
                width: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF1877F2),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.string(
                    _facebookSvg,
                    height: 22.h,
                    width: 22.w,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'sign_in_with_facebook'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
