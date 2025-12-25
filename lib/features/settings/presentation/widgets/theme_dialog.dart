import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/settings_model.dart' as model;
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<SettingsCubit>(),
          child: const ThemeDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final currentTheme = state is SettingsLoaded
            ? state.settings.themeMode
            : model.ThemeMode.system;

        return AlertDialog(
          backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'theme'.tr(),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeOption(
                title: 'light_mode'.tr(),
                icon: Icons.light_mode,
                value: model.ThemeMode.light,
                currentTheme: currentTheme,
                onTap: () {
                  context.read<SettingsCubit>().updateThemeMode(
                    model.ThemeMode.light,
                  );
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 8.h),
              _ThemeOption(
                title: 'dark_mode'.tr(),
                icon: Icons.dark_mode,
                value: model.ThemeMode.dark,
                currentTheme: currentTheme,
                onTap: () {
                  context.read<SettingsCubit>().updateThemeMode(
                    model.ThemeMode.dark,
                  );
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 8.h),
              _ThemeOption(
                title: 'system_mode'.tr(),
                icon: Icons.brightness_auto,
                value: model.ThemeMode.system,
                currentTheme: currentTheme,
                onTap: () {
                  context.read<SettingsCubit>().updateThemeMode(
                    model.ThemeMode.system,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final model.ThemeMode value;
  final model.ThemeMode currentTheme;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.value,
    required this.currentTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = currentTheme == value;

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
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color?.withValues(alpha: 0.6),
              size: 24,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16.sp,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color?.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
