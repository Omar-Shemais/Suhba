import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoldenParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double maxOpacity;
  final double swayPhase;
  final double swaySpeed;

  const GoldenParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.maxOpacity,
    required this.swayPhase,
    required this.swaySpeed,
  });
}

class GoldenParticlesPainter extends CustomPainter {
  final double progress;
  final Color goldColor;
  final List<GoldenParticle> particles;

  GoldenParticlesPainter({
    required this.progress,
    required this.goldColor,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentY = (p.y - progress * p.speed) % 1.0;
      final sway = math.sin((progress * p.swaySpeed * 2 * math.pi) + p.swayPhase) * 0.018;
      final currentX = (p.x + sway).clamp(0.02, 0.98);

      final verticalAlpha = math.sin(currentY * math.pi).clamp(0.0, 1.0);
      final finalAlpha = p.maxOpacity * verticalAlpha;

      if (finalAlpha <= 0.01) continue;

      paint.color = goldColor.withValues(alpha: finalAlpha);
      canvas.drawCircle(
        Offset(currentX * size.width, currentY * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GoldenParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.goldColor != goldColor;
  }
}
