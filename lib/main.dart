// lib/main.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:islamic_app/core/services/azan_notification_service.dart'; // ❌ REMOVE THIS IMPORT
import 'core/app/app_widget.dart';
import 'core/initialization/app_initializer.dart';

void main() async {
  // ⚡ ONLY CRITICAL OPERATIONS BEFORE runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 REMOVED: Notification init logic is now in AppInitializer

  // EasyLocalization is lightweight and required for UI text
  await EasyLocalization.ensureInitialized();

  // ⚡ IMMEDIATELY START THE APP
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/lang',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );

  // 🔄 DEFER ALL HEAVY INITIALIZATION
  Future.microtask(() async {
    debugPrint('🎯 [Main] First frame rendered, starting background init...');
    await AppInitializer.initialize();
  });
}
