// ============================================================================
// APP INITIALIZER - Handles all deferred initialization
// ============================================================================
// This class manages the app's background initialization after the first frame.
// It ensures services are loaded in the correct order without blocking startup.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../utils/cache_helper.dart';
import '../utils/service_locator.dart';
import '../constants/storage_constants.dart';
import '../network/supabase_client.dart';
import '../../features/community/community_injector.dart';
import '../../features/azkar/data/repositories/azkar_repo.dart';

/// Singleton class to manage app initialization
/// Ensures initialization happens only once and in the correct order
class AppInitializer {
  // Private constructor to prevent instantiation
  AppInitializer._();

  static bool _isInitialized = false;
  static Future<void>? _initFuture;

  /// Returns true if initialization is complete
  static bool get isInitialized => _isInitialized;

  /// Single entry point for initialization
  /// Returns the same Future if called multiple times (prevents duplicate init)
  static Future<void> initialize() {
    _initFuture ??= _performInitialization();
    return _initFuture!;
  }

  /// Performs the actual initialization in phases
  static Future<void> _performInitialization() async {
    if (_isInitialized) return;

    debugPrint('🚀 [AppInit] Starting deferred initialization...');
    final stopwatch = Stopwatch()..start();

    try {
      await _initializePhase1();
      await _initializePhase2();
      await _initializePhase3();
      _initializePhase4();

      _isInitialized = true;
      stopwatch.stop();
      debugPrint(
        '✅ [AppInit] Complete! Total time: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [AppInit] Initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Phase 1: Critical Services
  /// Required for basic app functionality (~800-1200ms)
  static Future<void> _initializePhase1() async {
    debugPrint('📦 [AppInit] Phase 1: Critical services...');

    // Firebase - Required for Auth
    await Firebase.initializeApp();
    debugPrint('✅ [AppInit] Firebase initialized');

    // SharedPreferences - Required for many features
    await SharedPreferences.getInstance();
    debugPrint('✅ [AppInit] SharedPreferences initialized');

    // Hive - Required for local storage
    await CacheHelper.init();
    await CacheHelper.openBox(StorageConstants.userBoxName);
    debugPrint('✅ [AppInit] Hive initialized');
  }

  /// Phase 2: Dependency Injection Setup
  /// Fast, synchronous registration (~50-100ms)
  static Future<void> _initializePhase2() async {
    debugPrint('📦 [AppInit] Phase 2: Dependency injection...');

    setupServiceLocator();
    debugPrint('✅ [AppInit] Service locator configured');
  }

  /// Phase 3: Optional Services
  /// Can fail without breaking app (~500-1000ms)
  static Future<void> _initializePhase3() async {
    debugPrint('📦 [AppInit] Phase 3: Optional services...');

    // Supabase for Community Feature - Non-critical
    try {
      await SupabaseClientWrapper.init();
      setupCommunityInjector();
      debugPrint('✅ [AppInit] Supabase & Community initialized');
    } catch (e) {
      debugPrint('⚠️ [AppInit] Supabase failed (non-critical): $e');
    }

    // Setup timeago locale for Arabic
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    debugPrint('✅ [AppInit] Timeago locale configured');
  }

  /// Phase 4: Background Preloading
  /// Loads data lazily without blocking (~200-500ms)
  static void _initializePhase4() {
    debugPrint('📦 [AppInit] Phase 4: Background preload...');

    // Preload Azkar data in background (don't await)
    AzkarRepo.getMorningAzkar().then((_) {
      debugPrint('✅ [AppInit] Azkar preloaded');
    }).catchError((e) {
      debugPrint('⚠️ [AppInit] Azkar preload failed: $e');
    });
  }

  /// Reset initialization state (useful for testing)
  @visibleForTesting
  static void reset() {
    _isInitialized = false;
    _initFuture = null;
  }
}
