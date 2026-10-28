import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Dark Theme Configuration
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'poppins',

  // Color Scheme
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2E7D5E), // Islamic emerald green
    secondary: AppColors.goldenSecondary,
    tertiary: Color(0xFF2E7D5E),
    surface: Color(0xFF1E2125), // Slate dark gray (matching Khatmah theme)
    surfaceContainer: Color(0xFF282C32),
    onPrimary: AppColors.whiteColor,
    onSecondary: AppColors.whiteColor,
    onSurface: AppColors.whiteColor,
    onSurfaceVariant: Color(0xFFA6AFB8),
    error: Color(0xFFCF6679),
    outline: Color(0xFF383E46),
  ),

  // Scaffold Background (Slate Charcoal Dark Gray matching Khatmah Screen)
  scaffoldBackgroundColor: const Color(0xFF1E2125),

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF282C32),
    foregroundColor: AppColors.whiteColor,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0xFFF0F2F5), size: 24),
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
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFFB8B8B8),
      fontFamily: 'poppins',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFFB8B8B8),
      fontFamily: 'poppins',
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Color(0xFFB8B8B8),
      fontFamily: 'poppins',
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: const Color(0xFF282C32),
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFF383E46), width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Icon Theme
  iconTheme: const IconThemeData(color: AppColors.goldenPrimary, size: 24),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.goldenPrimary,
      foregroundColor: AppColors.blackColor,
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
    fillColor: const Color(0xFF21252A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF383E46), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF383E46), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2E7D5E), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFCF6679), width: 2),
    ),
    labelStyle: const TextStyle(
      color: Color(0xFFB8B8B8),
      fontSize: 14,
      fontFamily: 'poppins',
    ),
    hintStyle: TextStyle(
      color: const Color(0xFFB8B8B8).withValues(alpha: 0.6),
      fontSize: 14,
      fontFamily: 'poppins',
    ),
    errorStyle: const TextStyle(
      color: Color(0xFFCF6679),
      fontSize: 12,
      fontFamily: 'poppins',
    ),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF21252A),
    selectedItemColor: Color(0xFF2E7D5E),
    unselectedItemColor: Color(0xFFA6AFB8),
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
    unselectedIconTheme: IconThemeData(size: 24, color: Color(0xFF9E9E9E)),
  ),

  // Floating Action Button Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.goldenPrimary,
    foregroundColor: AppColors.blackColor,
    elevation: 4,
    shape: CircleBorder(),
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: Color(0xFF424242),
    thickness: 1,
    space: 1,
  ),

  // Switch Theme
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFFC7A87A);
      }
      return const Color(0xFF757575);
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF143427);
      }
      return const Color(0xFF424242);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return Colors.white24;
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
    checkColor: WidgetStateProperty.all(AppColors.blackColor),
    side: const BorderSide(color: Color(0xFF424242), width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),

  // Dialog Theme
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF282C32),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFF383E46), width: 1),
    ),
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: Color(0xFFB8B8B8),
      fontFamily: 'poppins',
    ),
  ),

  // Bottom Sheet Theme
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF282C32),
    surfaceTintColor: Colors.transparent,
  ),

  // Snackbar Theme
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF2C2C2C),
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
    backgroundColor: AppColors.goldenPrimary.withValues(alpha: 0.2),
    deleteIconColor: AppColors.goldenPrimary,
    selectedColor: AppColors.goldenPrimary,
    secondarySelectedColor: AppColors.goldenSecondary,
    labelStyle: const TextStyle(
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.blackColor,
      fontFamily: 'poppins',
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  // Progress Indicator Theme
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFFC7A87A),
    linearTrackColor: Color(0xFF2A2A2A),
    circularTrackColor: Color(0xFF2A2A2A),
  ),

  // Slider Theme
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.goldenPrimary,
    inactiveTrackColor: const Color(0xFF424242),
    thumbColor: AppColors.goldenPrimary,
    overlayColor: AppColors.goldenPrimary.withValues(alpha: 0.2),
    valueIndicatorColor: AppColors.goldenPrimary,
    valueIndicatorTextStyle: const TextStyle(
      color: AppColors.blackColor,
      fontFamily: 'poppins',
    ),
  ),

  // List Tile Theme
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    iconColor: AppColors.goldenPrimary,
    textColor: AppColors.whiteColor,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.whiteColor,
      fontFamily: 'poppins',
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 14,
      color: Color(0xFFB8B8B8),
      fontFamily: 'poppins',
    ),
  ),
);
