// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:islamic_app/core/services/azan_notification_service.dart'; // ❌ REMOVE THIS IMPORT
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app/app_widget.dart';
import 'core/initialization/app_initializer.dart';

void main() async {
  // ⚡ ONLY CRITICAL OPERATIONS BEFORE runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // EasyLocalization is lightweight and required for UI text
  await EasyLocalization.ensureInitialized();

  // 🔒 FORCE PORTRAIT MODE
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load saved theme mode before runApp so splash renders in exact theme on frame 0
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app_theme_mode');
  ThemeMode initialThemeMode = ThemeMode.system;
  if (savedTheme == 'light') {
    initialThemeMode = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    initialThemeMode = ThemeMode.dark;
  }

  // Initialize core services so app launches cleanly into the single SplashScreen
  try {
    await AppInitializer.initialize();
  } catch (e) {
    debugPrint('⚠️ [Main] AppInitializer error: $e');
  }

  // ⚡ START THE APP
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/lang',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MyApp(initialThemeMode: initialThemeMode),
    ),
  );
}
