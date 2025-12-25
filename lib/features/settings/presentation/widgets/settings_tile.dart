import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldenPrimary.withValues(alpha: .08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.goldenPrimary, size: 21),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownPrimary,
                      letterSpacing: -0.2,
                      height: 1.3.h,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 5.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.brownSecondary.withValues(alpha: .8),
                        fontWeight: FontWeight.w500,
                        height: 1.2.h,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: AppColors.brownSecondary.withValues(alpha: .5),
                ),
          ],
        ),
      ),
    );
  }
}
