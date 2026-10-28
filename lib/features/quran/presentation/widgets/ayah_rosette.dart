import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AyahMedallion extends StatelessWidget {
  final int ayahNumber;
  final double fontSize;
  final bool isDark;
  final bool isPlaying;
  final bool isLastRead;

  const AyahMedallion({
    super.key,
    required this.ayahNumber,
    required this.fontSize,
    required this.isDark,
    this.isPlaying = false,
    this.isLastRead = false,
  });

  String _toArabic(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join('');
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic size relative to font size
    final double dimension = (fontSize * 1.1).clamp(20.0, 34.0);

    return Container(
      width: dimension.w,
      height: dimension.w,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: CustomPaint(
        painter: _AyahRosettePainter(
          isDark: isDark,
          isPlaying: isPlaying,
          isLastRead: isLastRead,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 1.5.h),
            child: Text(
              _toArabic(ayahNumber),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: (dimension * 0.44).sp,
                fontWeight: FontWeight.bold,
                color: isPlaying || isLastRead
                    ? const Color(0xFF143427)
                    : (isDark ? const Color(0xFFD5AF72) : const Color(0xFF6B4423)),
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AyahRosettePainter extends CustomPainter {
  final bool isDark;
  final bool isPlaying;
  final bool isLastRead;

  const _AyahRosettePainter({
    required this.isDark,
    required this.isPlaying,
    this.isLastRead = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background fill
    final fillPaint = Paint()
      ..color = isPlaying
          ? const Color(0xFFF9E7BA)
          : (isLastRead
              ? const Color(0xFFF4E3C1)
              : (isDark ? const Color(0xFF261E16) : const Color(0xFFFAF2E4)))
      ..style = PaintingStyle.fill;

    // Rosette outline
    final goldPaint = Paint()
      ..color = (isPlaying || isLastRead)
          ? const Color(0xFF143427)
          : const Color(0xFFC9A050)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLastRead || isPlaying ? 1.6 : 1.25;

    // 8-point Islamic rosette
    final path = Path();
    const int numPoints = 8;
    for (int i = 0; i < numPoints * 2; i++) {
      final double r = (i % 2 == 0) ? radius : radius * 0.88;
      final double angle = (i * pi) / numPoints;
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, goldPaint);

    // Inner delicate gold ring
    final innerPaint = Paint()
      ..color = (isPlaying ? const Color(0xFF143427) : const Color(0xFFC9A050))
          .withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius * 0.72, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _AyahRosettePainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.isPlaying != isPlaying;
}
