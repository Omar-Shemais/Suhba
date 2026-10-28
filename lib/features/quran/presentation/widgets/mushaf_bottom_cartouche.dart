import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MushafBottomCartouche extends StatelessWidget {
  final String text;
  final bool isDark;

  const MushafBottomCartouche({
    super.key,
    required this.text,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF271F18) : const Color(0xFFFBF4E6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFC79E53),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left ornate diamond / leaf
          Icon(
            Icons.diamond_rounded,
            size: 9.sp,
            color: const Color(0xFFC79E53),
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE5C88F) : const Color(0xFF5A3E20),
              letterSpacing: 1.2,
              height: 1.1,
            ),
          ),
          SizedBox(width: 8.w),
          // Right ornate diamond / leaf
          Icon(
            Icons.diamond_rounded,
            size: 9.sp,
            color: const Color(0xFFC79E53),
          ),
        ],
      ),
    );
  }
}
