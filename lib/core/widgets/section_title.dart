import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.5.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
          color: isDark ? const Color(0xFFF7ECE1) : AppColors.brownPrimary,
        ),
      ),
    );
  }
}
