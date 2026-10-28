import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFF143427).withValues(
                  alpha: isDark ? 0.35 : 0.08,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF143427).withValues(
                    alpha: isDark ? 0.3 : 0.12,
                  ),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isDark ? const Color(0xFFE5C992) : const Color(0xFF143427),
                size: 21.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF7ECE1) : const Color(0xFF38291B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white60 : const Color(0xFF736152),
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_left_rounded,
                  size: 22.sp,
                  color: isDark ? Colors.white38 : const Color(0xFF8C7A6B),
                ),
          ],
        ),
      ),
    );
  }
}
