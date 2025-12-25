import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:islamic_app/core/services/azan_notification_service.dart';
import '../utils/cache_helper.dart';
import '../utils/service_locator.dart';
import '../constants/storage_constants.dart';
import '../network/supabase_client.dart';
import '../../features/community/community_injector.dart';
import '../../features/azkar/data/repositories/azkar_repo.dart';

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
      // We do not rethrow here to prevent the app from crashing on splash
      // Instead, we log it and allow the app to try continuing
    }
  }

  /// Phase 1: Critical Services
  static Future<void> _initializePhase1() async {
    debugPrint('📦 [AppInit] Phase 1: Critical services...');

    // 1. Notifications
    try {
      final notificationService = AzanNotificationService();
      await notificationService.initialize();
      debugPrint('✅ [AppInit] Notifications initialized');
    } catch (e) {
      debugPrint('⚠️ [AppInit] Notification init failed (Non-fatal): $e');
    }

    // 2. Firebase (🟢 FIX: Check if already initialized to prevent crash)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        debugPrint('✅ [AppInit] Firebase initialized');
      } else {
        debugPrint('ℹ️ [AppInit] Firebase already initialized (Skipping)');
      }
    } catch (e) {
      debugPrint('⚠️ [AppInit] Firebase init error: $e');
    }

    // 3. SharedPreferences
    await SharedPreferences.getInstance();
    debugPrint('✅ [AppInit] SharedPreferences initialized');

    // 4. Hive
    await CacheHelper.init();
    await CacheHelper.openBox(StorageConstants.userBoxName);
    debugPrint('✅ [AppInit] Hive initialized');
  }

  /// Phase 2: Dependency Injection Setup
  static Future<void> _initializePhase2() async {
    debugPrint('📦 [AppInit] Phase 2: Dependency injection...');
    setupServiceLocator();
    debugPrint('✅ [AppInit] Service locator configured');
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
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    debugPrint('✅ [AppInit] Timeago locale configured');
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
