import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Light Theme Configuration
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'poppins',

  // Color Scheme
  colorScheme: const ColorScheme.light(
    primary: AppColors.goldenPrimary,
    secondary: AppColors.goldenSecondary,
    tertiary: AppColors.brownPrimary,
    surface: AppColors.backgroundLight,
    onPrimary: AppColors.whiteColor,
    onSecondary: AppColors.whiteColor,
    onSurface: AppColors.brownPrimary,
    onSurfaceVariant: AppColors.brownSecondary,
    error: AppColors.errorColor,
    outline: AppColors.dividerColor,
  ),

  // Scaffold Background
  scaffoldBackgroundColor: AppColors.backgroundLight,

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.goldenPrimary,
    foregroundColor: AppColors.whiteColor,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.whiteColor, size: 24),
    titleTextStyle: TextStyle(
      color: AppColors.whiteColor,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'poppins',
    ),
  ),

  // Text Theme
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.brownSecondary,
      fontFamily: 'poppins',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.brownSecondary,
      fontFamily: 'poppins',
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.brownSecondary,
      fontFamily: 'poppins',
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.whiteColor,
    elevation: 2,
    shadowColor: AppColors.goldenPrimary.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Icon Theme
  iconTheme: const IconThemeData(color: AppColors.goldenPrimary, size: 24),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.goldenPrimary,
      foregroundColor: AppColors.whiteColor,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'poppins',
      ),
    ),
  ),

  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.goldenPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'poppins',
      ),
    ),
  ),

  // Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.goldenPrimary,
      side: const BorderSide(color: AppColors.goldenPrimary, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'poppins',
      ),
    ),
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.whiteColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.dividerColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.dividerColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.goldenPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
    ),
    labelStyle: const TextStyle(
      color: AppColors.brownSecondary,
      fontSize: 14,
      fontFamily: 'poppins',
    ),
    hintStyle: TextStyle(
      color: AppColors.brownSecondary.withValues(alpha: 0.6),
      fontSize: 14,
      fontFamily: 'poppins',
    ),
    errorStyle: const TextStyle(
      color: AppColors.errorColor,
      fontSize: 12,
      fontFamily: 'poppins',
    ),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.whiteColor,
    selectedItemColor: AppColors.goldenPrimary,
    unselectedItemColor: AppColors.brownSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFamily: 'poppins',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'poppins',
    ),
    selectedIconTheme: IconThemeData(size: 28, color: AppColors.goldenPrimary),
    unselectedIconTheme: IconThemeData(
      size: 24,
      color: AppColors.brownSecondary,
    ),
  ),

  // Floating Action Button Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.goldenPrimary,
    foregroundColor: AppColors.whiteColor,
    elevation: 4,
    shape: CircleBorder(),
  ),

  // Divider Theme
  dividerTheme: DividerThemeData(
    color: AppColors.dividerColor,
    thickness: 1,
    space: 1,
  ),

  // Switch Theme
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.goldenPrimary;
      }
      return AppColors.brownSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.goldenPrimary.withValues(alpha: 0.5);
      }
      return AppColors.dividerColor;
    }),
  ),

  // Checkbox Theme
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.goldenPrimary;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.whiteColor),
    side: const BorderSide(color: AppColors.dividerColor, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),

  // Dialog Theme
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.whiteColor,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: AppColors.brownSecondary,
      fontFamily: 'poppins',
    ),
  ),

  // Snackbar Theme
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.brownPrimary,
    contentTextStyle: const TextStyle(
      color: AppColors.whiteColor,
      fontSize: 14,
      fontFamily: 'poppins',
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),

  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.goldenPrimary.withValues(alpha: 0.1),
    deleteIconColor: AppColors.goldenPrimary,
    selectedColor: AppColors.goldenPrimary,
    secondarySelectedColor: AppColors.goldenSecondary,
    labelStyle: const TextStyle(
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  // Progress Indicator Theme
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.goldenPrimary,
    linearTrackColor: AppColors.dividerColor,
    circularTrackColor: AppColors.dividerColor,
  ),

  // Slider Theme
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.goldenPrimary,
    inactiveTrackColor: AppColors.dividerColor,
    thumbColor: AppColors.goldenPrimary,
    overlayColor: AppColors.goldenPrimary.withValues(alpha: 0.2),
    valueIndicatorColor: AppColors.goldenPrimary,
    valueIndicatorTextStyle: const TextStyle(
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
  ),

  // List Tile Theme
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    iconColor: AppColors.goldenPrimary,
    textColor: AppColors.brownPrimary,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.brownPrimary,
      fontFamily: 'poppins',
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 14,
      color: AppColors.brownSecondary,
      fontFamily: 'poppins',
    ),
  ),
);
