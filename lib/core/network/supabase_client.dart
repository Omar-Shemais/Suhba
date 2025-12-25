import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

/// Wrapper for Supabase client to handle initialization and access
class SupabaseClientWrapper {
  static SupabaseClient? _client;

  /// Get the Supabase client instance
  /// Throws an exception if not initialized
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase client not initialized. Call SupabaseClientWrapper.init() first.',
      );
    }
    return _client!;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;

  /// Initialize Supabase
  /// Should be called once at app startup in main.dart
  static Future<void> init() async {
    try {
      debugPrint('🔵 [Supabase] Initializing...');

      await Supabase.initialize(
        url: SupabaseConstants.projectUrl,
        anonKey: SupabaseConstants.anonKey,
        debug: kDebugMode, // Enable debug logs in debug mode
      );

      _client = Supabase.instance.client;

      debugPrint('✅ [Supabase] Initialized successfully');
      debugPrint('🔗 [Supabase] URL: ${SupabaseConstants.projectUrl}');
    } catch (e) {
      debugPrint('❌ [Supabase] Initialization failed: $e');
      rethrow;
    }
  }

  /// Close Supabase connection (if needed)
  static Future<void> dispose() async {
    if (_client != null) {
      debugPrint('🔵 [Supabase] Disposing client...');
      // Supabase client doesn't have explicit dispose
      _client = null;
      debugPrint('✅ [Supabase] Client disposed');
    }
  }
}
