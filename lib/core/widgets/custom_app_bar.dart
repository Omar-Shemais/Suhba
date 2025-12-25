import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import 'package:islamic_app/features/quran/data/repositories/audio_repo.dart';
import 'package:islamic_app/features/quran/presentation/widgets/reciter_selector_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMore;
  final IconData? leadingIcon;
  final bool showReciterIcon;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.onMore,
    this.leadingIcon,
    this.showReciterIcon = true,
  });

  void _showReciterSelector(BuildContext context) {
    showReciterSelector(context, getIt<AudioRepository>());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: kToolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // أيقونة العودة
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: onBack ?? () => Navigator.pop(context),
            ),

            // العنوان في الوسط
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.subHead,
              ),
            ),

            // أيقونة القارئ أو أي أيقونة مخصصة إذا موجودة
            if (showReciterIcon)
              IconButton(
                icon: Icon(
                  Icons.record_voice_over,
                  color: isDark
                      ? AppColors.secondaryColor
                      : AppColors.secondaryColor,
                ),
                onPressed: () => _showReciterSelector(context),
                tooltip: 'اختيار القارئ',
              )
            else if (leadingIcon != null)
              IconButton(icon: Icon(leadingIcon), onPressed: onMore ?? () {}),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
