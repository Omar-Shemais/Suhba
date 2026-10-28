import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IslamicSurahBadge extends StatelessWidget {
  final int surahNumber;
  final bool isDark;

  const IslamicSurahBadge({
    super.key,
    required this.surahNumber,
    required this.isDark,
  });

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.tryParse(d) ?? 0])
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(44.w, 44.w),
            painter: _IslamicMedallionPainter(
              borderColor: isDark
                  ? const Color(0xFFC7A170)
                  : const Color(0xFFB59368),
              fillColor: isDark
                  ? const Color(0xFF2C2219)
                  : const Color(0xFFFDFBF7),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Text(
              _toArabicDigits(surahNumber),
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF7ECE1)
                    : const Color(0xFF38291B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicMedallionPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;

  _IslamicMedallionPainter({
    required this.borderColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 2;
    final innerR = outerR * 0.82;
    const points = 8;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - (math.pi / 2);
      final r = (i % 2 == 0) ? outerR : innerR;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Outer stroke
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Inner concentric ring
    final innerCirclePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, innerR * 0.85, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant _IslamicMedallionPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor ||
      oldDelegate.fillColor != fillColor;
}
