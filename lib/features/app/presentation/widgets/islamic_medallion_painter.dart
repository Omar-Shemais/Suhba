import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicMedallionPainter extends CustomPainter {
  final double progress;
  final Color goldColor;
  final bool isDark;

  IslamicMedallionPainter({
    required this.progress,
    required this.goldColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Soft outer ambient ring
    final outerRingPaint = Paint()
      ..color = goldColor.withValues(alpha: isDark ? 0.22 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 2, outerRingPaint);

    // 2. Animated main gold border (circular reveal)
    if (progress > 0.0) {
      final sweepAngle = 2 * math.pi * progress;
      final mainRingPaint = Paint()
        ..color = goldColor.withValues(alpha: isDark ? 0.85 : 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        -math.pi / 2,
        sweepAngle,
        false,
        mainRingPaint,
      );
    }

    // 3. Inner fine accent circle
    final innerRingPaint = Paint()
      ..color = goldColor.withValues(alpha: isDark ? 0.30 : 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius - 10, innerRingPaint);

    // 4. Four delicate arabesque accent florets (top, bottom, left, right)
    if (progress >= 0.75) {
      final accentAlpha = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);
      final accentPaint = Paint()
        ..color = goldColor.withValues(alpha: accentAlpha * 0.9)
        ..style = PaintingStyle.fill;

      const dotRadius = 2.4;
      final cardinalDistance = radius - 6;

      _drawDiamond(canvas, Offset(center.dx, center.dy - cardinalDistance), dotRadius, accentPaint);
      _drawDiamond(canvas, Offset(center.dx, center.dy + cardinalDistance), dotRadius, accentPaint);
      _drawDiamond(canvas, Offset(center.dx - cardinalDistance, center.dy), dotRadius, accentPaint);
      _drawDiamond(canvas, Offset(center.dx + cardinalDistance, center.dy), dotRadius, accentPaint);
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicMedallionPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.goldColor != goldColor ||
        oldDelegate.isDark != isDark;
  }
}
