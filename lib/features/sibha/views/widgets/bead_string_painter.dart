import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class BeadStringPainter extends CustomPainter {
  final int currentCount;
  final bool isDark;

  BeadStringPainter({
    required this.currentCount,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pathMetrics = _createCurvedPath(size).computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final totalLength = metric.length;

    // Elegant golden silk cord
    final ropeColor = isDark
        ? AppColors.goldenPrimary.withValues(alpha: 0.8)
        : AppColors.goldenSecondary;

    final ropeShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : AppColors.brownPrimary.withValues(alpha: 0.25);

    // 1. Cord drop shadow
    final shadowPaint = Paint()
      ..color = ropeShadowColor
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int i = 0; i < 3; i++) {
      _drawRopeSegment(canvas, metric, totalLength, 0.05 + (i / 3.0) * 0.25,
          0.05 + ((i + 1) / 3.0) * 0.25, shadowPaint);
    }
    for (int i = 0; i < 2; i++) {
      _drawRopeSegment(canvas, metric, totalLength, 0.7 + (i / 2.0) * 0.25,
          0.7 + ((i + 1) / 2.0) * 0.25, shadowPaint);
    }
    _drawRopeSegment(canvas, metric, totalLength, 0.3, 0.7, shadowPaint);

    // 2. Main golden cord
    final ropePaint = Paint()
      ..color = ropeColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      _drawRopeSegment(canvas, metric, totalLength, 0.05 + (i / 3.0) * 0.25,
          0.05 + ((i + 1) / 3.0) * 0.25, ropePaint);
    }

    for (int i = 0; i < 2; i++) {
      _drawRopeSegment(canvas, metric, totalLength, 0.7 + (i / 2.0) * 0.25,
          0.7 + ((i + 1) / 2.0) * 0.25, ropePaint);
    }

    _drawRopeSegment(
        canvas,
        metric,
        totalLength,
        0.3,
        0.7,
        Paint()
          ..color = AppColors.goldenPrimary.withValues(alpha: 0.7)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  void _drawRopeSegment(Canvas canvas, PathMetric metric, double totalLength,
      double startPos, double endPos, Paint paint) {
    final startTangent = metric.getTangentForOffset(totalLength * startPos);
    if (startTangent != null) {
      canvas.drawPath(
        Path()
          ..moveTo(startTangent.position.dx, startTangent.position.dy)
          ..addPath(
              metric.extractPath(totalLength * startPos, totalLength * endPos),
              Offset.zero),
        paint,
      );
    }
  }

  Path _createCurvedPath(Size size) {
    return Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2 + 250),
          radius: 350.0,
        ),
        -2.8,
        2.0,
      );
  }

  @override
  bool shouldRepaint(covariant BeadStringPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.currentCount != currentCount;
}
