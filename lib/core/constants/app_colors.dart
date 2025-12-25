import 'package:flutter/material.dart';

/// App Colors Constants
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  /// Black Color - #1F1F1F
  static const Color blackColor = Color(0xFF1F1F1F);

  /// Primary Color - #FFB030
  static const Color primaryColor = Color(0xFFFFB030);

  /// Primary Light Color (for Light Mode)
  static const Color primaryLightColor = Color(0xFFfae9cd);

  /// Primary Dark Color (for Dark Mode)
  static const Color primaryDarkColor = Color(0xFF5B4636);

  /// Secondary Color - #874D14
  static const Color secondaryColor = Color(0xFF874D14);

  /// Container Color - #FAF2EB
  static const Color containerColor = Color(0xFFfaf2eb);

  // Additional colors for better UI
  /// White Color
  static const Color whiteColor = Color(0xFFFFFFFF);

  /// Background Color (Light)
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Background Color (Dark)
  static const Color backgroundDark = Color(0xFF121212);

  /// Text Color (Primary)
  static const Color textPrimary = blackColor;

  /// Text Color (Secondary)
  static const Color textSecondary = Color(0xFF757575);

  /// Text Color (On Primary)
  static const Color textOnPrimary = whiteColor;

  /// Error Color
  static const Color errorColor = Color(0xFFD32F2F);

  /// Success Color
  static const Color successColor = Color(0xFF388E3C);

  /// Divider Color
  static const Color dividerColor = Color(0xFFE0E0E0);

  /// Border Color
  static const borderColor = Color(0xFFEEEEEE);
  // ==================== Golden Theme Colors ====================

  /// Golden Primary - #D4941C (Main golden color for gradients & borders)
  static const Color goldenPrimary = Color(0xFFD4941C);

  /// Golden Secondary - #B8770E (Darker golden for gradients)
  static const Color goldenSecondary = Color(0xFFB8770E);

  /// Brown Primary - #6B4423 (Dark brown for main text)
  static const Color brownPrimary = Color(0xFF6B4423);

  /// Brown Secondary - #8B6B47 (Light brown for secondary text & labels)
  static const Color brownSecondary = Color(0xFF8B6B47);

  // Background Gradient Colors
  /// Background Light 1 - #FFF5E6 (Lightest cream)
  static const Color backgroundLight1 = Color(0xFFFFF5E6);

  /// Background Light 2 - #FFE4C4 (Light cream)
  static const Color backgroundLight2 = Color(0xFFFFE4C4);

  /// Background Light 3 - #FDD7A8 (Medium cream)
  static const Color backgroundLight3 = Color(0xFFFDD7A8);

  /// Background Light 4 - #F4C18B (Darker cream)
  static const Color backgroundLight4 = Color(0xFFF4C18B);

  // Common Gradients
  /// Golden Gradient (for buttons, borders, etc.)
  static const LinearGradient goldenGradient = LinearGradient(
    colors: [goldenPrimary, goldenSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary Gradient
  static const Color primaryLightColorWithOpacity = Color(
    0xB3FAE9CD,
  ); // 70% opacity
  static const LinearGradient secanderyGradient = LinearGradient(
    colors: [primaryLightColor, primaryLightColorWithOpacity],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Precomputed color with 70% opacity for primaryDarkColor
  static const Color primaryDarkColorWithOpacity = Color(
    0xB35B4636,
  ); // 70% opacity

  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryDarkColor, primaryDarkColorWithOpacity],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Golden Triple Gradient (for borders with more shine)
  static const LinearGradient goldenTripleGradient = LinearGradient(
    colors: [goldenPrimary, goldenSecondary, goldenPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background Gradient (for screens)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      backgroundLight1,
      backgroundLight2,
      backgroundLight3,
      backgroundLight4,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
