import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageDialog extends StatelessWidget {
  final String currentLocale;

  const LanguageDialog({super.key, required this.currentLocale});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return LanguageDialog(currentLocale: context.locale.languageCode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        'language'.tr(),
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            title: 'arabic'.tr(),
            value: 'ar',
            currentLocale: currentLocale,
            onTap: () {
              context.setLocale(const Locale('ar'));
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: 8.h),
          _LanguageOption(
            title: 'english'.tr(),
            value: 'en',
            currentLocale: currentLocale,
            onTap: () {
              context.setLocale(const Locale('en'));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String value;
  final String currentLocale;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.value,
    required this.currentLocale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = currentLocale == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color?.withValues(alpha: 0.6),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
