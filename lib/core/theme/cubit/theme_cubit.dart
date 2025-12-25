import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

/// Theme Cubit - manages app theme state
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'app_theme_mode';

  ThemeCubit() : super(const ThemeInitial()) {
    _loadTheme();
  }

  /// Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      ThemeMode themeMode;
      switch (savedTheme) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          themeMode = ThemeMode.system;
          break;
      }

      emit(ThemeLoaded(themeMode));
    } catch (e) {
      // If error, default to system theme
      emit(const ThemeLoaded(ThemeMode.system));
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final currentMode = state.themeMode;
    ThemeMode newMode;

    // Toggle: light -> dark -> light
    if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      newMode = ThemeMode.light;
    }

    await _saveTheme(newMode);
    emit(ThemeLoaded(newMode));
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    await _saveTheme(mode);
    emit(ThemeLoaded(mode));
  }

  /// Set light theme
  Future<void> setLightTheme() async {
    await _saveTheme(ThemeMode.light);
    emit(const ThemeLoaded(ThemeMode.light));
  }

  /// Set dark theme
  Future<void> setDarkTheme() async {
    await _saveTheme(ThemeMode.dark);
    emit(const ThemeLoaded(ThemeMode.dark));
  }

  /// Set system theme
  Future<void> setSystemTheme() async {
    await _saveTheme(ThemeMode.system);
    emit(const ThemeLoaded(ThemeMode.system));
  }

  /// Save theme to SharedPreferences
  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;

      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }

      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Check if current theme is dark
  bool get isDarkMode => state.themeMode == ThemeMode.dark;

  /// Check if current theme is light
  bool get isLightMode => state.themeMode == ThemeMode.light;

  /// Check if current theme is system
  bool get isSystemMode => state.themeMode == ThemeMode.system;
}
