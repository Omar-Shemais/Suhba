import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:islamic_app/core/services/azan_notification_service.dart';
import '../../firebase_options.dart';
import '../utils/cache_helper.dart';
import '../utils/service_locator.dart';
import '../constants/storage_constants.dart';
import '../network/supabase_client.dart';
import '../../features/community/community_injector.dart';
import '../../features/azkar/data/repositories/azkar_repo.dart';
import '../../features/azkar/services/azkar_notification_service.dart';

class AppInitializer {
  AppInitializer._();

  static bool _isInitialized = false;
  static Future<void>? _initFuture;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() {
    _initFuture ??= _performInitialization();
    return _initFuture!;
  }

  static Future<void> _performInitialization() async {
    if (_isInitialized) return;

    debugPrint('🚀 [AppInit] Starting deferred initialization...');
    final stopwatch = Stopwatch()..start();

    // 🛡️ GLOBAL SAFETY NET
    try {
      // ⏳ Phase 1: Critical Sesrvices (w/ Timeout)
      // We wrap this in its own try/catch so if it fails, we STILL try Phase 2
      try {
        await _initializePhase1().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('⚠️ [AppInit] Phase 1 (Services) failed or timed out: $e');
        // Continue to Phase 2 because we need ServiceLocator for the app to function at all
      }

      // ⏳ Phase 2: Dependency Injection (CRITICAL)
      // If this fails, the app is likely dead, but we catch it to log.
      try {
        await _initializePhase2();
      } catch (e) {
        debugPrint('❌ [AppInit] Phase 2 (DI) failed: $e');
        // This is fatal for the UI, but we don't rethrow to avoid crashing to OS home
      }

      // ⏳ Phase 3: Optional Services
      try {
        await _initializePhase3().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('⚠️ [AppInit] Phase 3 (Optional) failed: $e');
      }

      // 🏃 Phase 4: Background (Fire and forget)
      _initializePhase4();

      _isInitialized = true;
      stopwatch.stop();
      debugPrint(
        '✅ [AppInit] Complete! Total time: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stackTrace) {
      // This catches anything unexpected in the overall flow
      debugPrint('❌ [AppInit] Unexpected fatal error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Phase 1: Critical Services
  static Future<void> _initializePhase1() async {
    debugPrint('📦 [AppInit] Phase 1: Critical services...');

    // 1. SharedPreferences (Fast & usually safe, do first)
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!getIt.isRegistered<SharedPreferences>()) {
        getIt.registerSingleton<SharedPreferences>(prefs);
      }
      debugPrint('✅ [AppInit] SharedPreferences initialized');
    } catch (e) {
      debugPrint('⚠️ [AppInit] SharedPreferences init error: $e');
    }

    // 2. Hive / Local Cache (CRITICAL: must be opened before Phase 2 DI)
    try {
      await CacheHelper.init();
      await CacheHelper.openBox(StorageConstants.userBoxName);
      await CacheHelper.openBox(StorageConstants.settingsBoxName);
      debugPrint('✅ [AppInit] Hive initialized');
    } catch (e) {
      debugPrint('⚠️ [AppInit] Hive init failed: $e');
    }

    // 3. Firebase (Restores persistent auth credentials)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ [AppInit] Firebase initialized');
      } else {
        debugPrint('ℹ️ [AppInit] Firebase already initialized');
      }
    } catch (e) {
      debugPrint('⚠️ [AppInit] Firebase init error: $e');
    }

    // 4. Notifications (Non-blocking: permissions shouldn't block the phase 1 timeout)
    try {
      final notificationService = AzanNotificationService();
      notificationService.initialize().catchError((e) {
        debugPrint('⚠️ [AppInit] Notification init failed: $e');
      });
      final azkarNotificationService = AzkarNotificationService();
      azkarNotificationService.initialize().catchError((e) {
        debugPrint('⚠️ [AppInit] Azkar notification init failed: $e');
      });
      debugPrint('✅ [AppInit] Notifications triggered');
    } catch (e) {
      debugPrint('⚠️ [AppInit] Notification init error: $e');
    }
  }

  /// Phase 2: Dependency Injection Setup
  static Future<void> _initializePhase2() async {
    debugPrint('📦 [AppInit] Phase 2: Dependency injection...');
    // This MUST run for the app to work.
    try {
      setupServiceLocator();
      debugPrint('✅ [AppInit] Service locator configured');
    } catch (e) {
      debugPrint('❌ [AppInit] Service locator FAILED: $e');
      rethrow; // Re-throw to signal critical failure if needed
    }
  }

  /// Phase 3: Optional Services
  static Future<void> _initializePhase3() async {
    debugPrint('📦 [AppInit] Phase 3: Optional services...');

    // Supabase
    try {
      await SupabaseClientWrapper.init();
      setupCommunityInjector();
      debugPrint('✅ [AppInit] Supabase & Community initialized');
    } catch (e) {
      debugPrint('⚠️ [AppInit] Supabase failed (non-critical): $e');
    }

    // Timeago
    try {
      timeago.setLocaleMessages('ar', timeago.ArMessages());
    } catch (_) {}
  }

  /// Phase 4: Background Preloading
  static void _initializePhase4() {
    debugPrint('📦 [AppInit] Phase 4: Background preload...');
    AzkarRepo.getMorningAzkar()
        .then((_) {
          debugPrint('✅ [AppInit] Azkar preloaded');
        })
        .catchError((e) {
          debugPrint('⚠️ [AppInit] Azkar preload failed: $e');
        });
  }

  @visibleForTesting
  static void reset() {
    _isInitialized = false;
    _initFuture = null;
  }
}
