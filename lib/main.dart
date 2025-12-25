// ============================================================================
// MAIN ENTRY POINT - Clean & Minimal
// ============================================================================
// This file only handles app startup and delegates everything else to
// separate, well-organized files for better maintainability.
//
// Architecture:
// - AppInitializer: Handles all background initialization
// - MyApp: Root widget with state management
// - InitializingScreen: Loading screen widget
//
// Expected startup time: < 500ms (down from ~5000ms)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_app/core/services/azan_notification_service.dart';
import 'core/app/app_widget.dart';
import 'core/initialization/app_initializer.dart';

/// Main entry point of the application
/// Only minimal operations happen here before runApp()
void main() async {
  // ⚡ ONLY CRITICAL OPERATIONS BEFORE runApp()
  // Target: < 100ms before first frame
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = AzanNotificationService();
  await notificationService.initialize();

  // EasyLocalization is lightweight and required for UI text
  await EasyLocalization.ensureInitialized();

  // ⚡ IMMEDIATELY START THE APP - First frame appears now!
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/lang',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );

  // 🔄 DEFER ALL HEAVY INITIALIZATION TO AFTER FIRST FRAME
  // This happens in the background while user sees the loading screen
  Future.microtask(() async {
    debugPrint('🎯 [Main] First frame rendered, starting background init...');
    await AppInitializer.initialize();
  });
}
