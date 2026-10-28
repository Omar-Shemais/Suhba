import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const CustomShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: isDark
            ? const Color(0xFF282C32)
            : const Color(0xFFEADBCE).withValues(alpha: 0.5),
        highlightColor: isDark
            ? const Color(0xFF383E46)
            : const Color(0xFFFAF5ED),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
