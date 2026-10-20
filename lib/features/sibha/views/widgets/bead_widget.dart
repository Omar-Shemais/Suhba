import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class BeadWidget extends StatelessWidget {
  final double opacity;
  final double scale;
  final bool isDark;

  const BeadWidget({
    super.key,
    required this.opacity,
    required this.scale,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 55,
          height: 55,
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.35, -0.38),
                  radius: 0.85,
                  colors: [
                    Color(0xFFFFF7E6), // Specular golden white highlight
                    Color(0xFFFFCF66), // Bright amber gold
                    AppColors.goldenPrimary, // 0xFFD4941C
                    AppColors.goldenSecondary, // 0xFFB8770E
                    Color(0xFF6B4423), // AppColors.brownPrimary
                    Color(0xFF3B210B), // Deep ambient shadow
                  ],
                  stops: [0.0, 0.22, 0.48, 0.70, 0.88, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B210B).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(2, 6),
                  ),
                  BoxShadow(
                    color: AppColors.goldenPrimary.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Glossy Specular Sheen
                  Positioned(
                    top: 9,
                    left: 11,
                    child: Container(
                      width: 11,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius:
                            const BorderRadius.all(Radius.elliptical(11, 7)),
                      ),
                    ),
                  ),
                  // Subtle Golden Inner Rim / Thread Hole Accent
                  Center(
                    child: Container(
                      width: 2.5,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF422208).withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
