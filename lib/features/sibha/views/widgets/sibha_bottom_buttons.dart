import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class SibhaBottomButtons extends StatelessWidget {
  final int maxRounds;
  final int totalBeads;
  final VoidCallback onRoundsTap;
  final VoidCallback onResetTap;
  final VoidCallback onCounterTap;

  const SibhaBottomButtons({
    super.key,
    required this.maxRounds,
    required this.totalBeads,
    required this.onRoundsTap,
    required this.onResetTap,
    required this.onCounterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rounds target button
          _buildButton(
            context: context,
            icon: Icons.flag_outlined,
            label: 'x$maxRounds',
            onTap: onRoundsTap,
            isDark: isDark,
          ),
          // Reset button
          _buildResetButton(context),
          // Counter beads button
          _buildButton(
            context: context,
            icon: Icons.format_list_numbered_rounded,
            label: '$totalBeads',
            onTap: onCounterTap,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final bgColor = isDark
        ? const Color(0xFF26201A)
        : AppColors.containerColor;
    final textColor = isDark ? AppColors.goldenPrimary : AppColors.brownPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.goldenPrimary.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return GestureDetector(
      onTap: onResetTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.goldenGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldenPrimary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'reset'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
