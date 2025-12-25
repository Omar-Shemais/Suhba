import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to sync Firebase Auth users with Supabase database
/// This ensures that authenticated Firebase users have a corresponding record in Supabase
class SupabaseAuthSyncService {
  final SupabaseClient _supabase;
  final FirebaseAuth _firebaseAuth;

  SupabaseAuthSyncService({
    required SupabaseClient supabase,
    required FirebaseAuth firebaseAuth,
  }) : _supabase = supabase,
       _firebaseAuth = firebaseAuth;

  /// Sync the current Firebase user to Supabase users table
  /// Call this after successful Firebase sign in/sign up
  Future<void> syncUserToSupabase() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      debugPrint('⚠️ [AuthSync] No Firebase user to sync');
      return;
    }

    try {
      debugPrint('🔄 [AuthSync] Syncing user: ${firebaseUser.uid}');

      // Prepare user data
      final userData = {
        'id': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': firebaseUser.displayName ?? 'مستخدم',
        'avatar_url': firebaseUser.photoURL,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Upsert (insert or update) user in Supabase
      await _supabase
          .from('users')
          .upsert(
            userData,
            onConflict: 'id', // Update if exists
          );

      debugPrint('✅ [AuthSync] User synced successfully');
      debugPrint('📧 [AuthSync] Email: ${firebaseUser.email}');
      debugPrint('👤 [AuthSync] Name: ${userData['name']}');
    } catch (e) {
      debugPrint('❌ [AuthSync] Failed to sync user: $e');
      // Don't throw - allow user to continue even if sync fails
      // They can retry later
    }
  }

  /// Hook to call after user signs in
  Future<void> onUserSignedIn() async {
    await syncUserToSupabase();
  }

  /// Hook to call after user signs up
  Future<void> onUserSignedUp() async {
    await syncUserToSupabase();
  }

  /// Update user profile in Supabase
  Future<void> updateUserProfile({
    String? name,
    String? avatarUrl,
    String? bio,
  }) async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint('🔄 [AuthSync] Updating user profile: ${firebaseUser.uid}');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (bio != null) updateData['bio'] = bio;

      await _supabase
          .from('users')
          .update(updateData)
          .eq('id', firebaseUser.uid);

      debugPrint('✅ [AuthSync] Profile updated successfully');
    } catch (e) {
      debugPrint('❌ [AuthSync] Failed to update profile: $e');
      rethrow;
    }
  }

  /// Check if user exists in Supabase
  Future<bool> userExistsInSupabase(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('❌ [AuthSync] Failed to check user existence: $e');
      return false;
    }
  }
}
