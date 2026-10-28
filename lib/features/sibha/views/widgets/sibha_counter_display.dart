import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class SibhaCounterDisplay extends StatelessWidget {
  final int currentCount;
  final int totalBeads;
  final int currentRound;
  final int maxRounds;

  const SibhaCounterDisplay({
    super.key,
    required this.currentCount,
    required this.totalBeads,
    required this.currentRound,
    required this.maxRounds,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : AppColors.brownPrimary;
    final secondaryTextColor =
        isDark ? AppColors.goldenPrimary : AppColors.goldenSecondary;
    final roundsTextColor =
        isDark ? Colors.white70 : AppColors.brownSecondary;

    return Positioned(
      left: 24,
      top: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$currentCount',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 88,
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                    fontFamily: 'amiri',
                  ),
                ),
                TextSpan(
                  text: '/$totalBeads',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    height: 0.95,
                    fontFamily: 'amiri',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.goldenPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.goldenPrimary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              '${'rounds'.tr()}: $currentRound / $maxRounds',
              style: TextStyle(
                color: roundsTextColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
