import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../../core/utils/image_helper.dart';
import '../../../community/community_injector.dart' as community_di;
import '../../../../../core/services/supabase_auth_sync_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    // Listen to auth state changes from Firebase
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      debugPrint(
        '🔔 [AuthCubit] Firebase auth state changed, user: ${user?.id}, currentState: ${state.runtimeType}',
      );

      // Skip auto-emit if we're in loading or pending Google Sign In state
      if (state is AuthLoading || state is GoogleSignInPending) {
        debugPrint(
          '⏸️ [AuthCubit] Skipping Firebase listener emit (state: ${state.runtimeType})',
        );
        return;
      }

      if (user != null) {
        debugPrint(
          '✅ [AuthCubit] Emitting AuthAuthenticated from Firebase listener',
        );
        emit(AuthAuthenticated(user));
      } else {
        debugPrint(
          '🚪 [AuthCubit] Emitting AuthUnauthenticated from Firebase listener',
        );
        emit(const AuthUnauthenticated());
      }
    });
  }

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    try {
      final user = _authRepository.getCurrentUser();

      if (user != null) {
        debugPrint('🔍 [AuthCubit] User found in cache: ${user.id}');
        debugPrint(
          '📸 [AuthCubit] Cached photo length: ${user.photoBase64?.length ?? 0}',
        );

        // First emit cached user to show UI immediately
        emit(AuthAuthenticated(user));

        // Then refresh from Firestore in background to get latest data
        debugPrint('🔄 [AuthCubit] Refreshing user data from Firestore...');
        _refreshUserFromFirestore(user.id);
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Refresh user data from Firestore in background
  Future<void> _refreshUserFromFirestore(String userId) async {
    try {
      debugPrint('📥 [AuthCubit] Background refresh from Firestore...');

      final result = await _authRepository.refreshUserData(userId);

      result.fold(
        (failure) {
          debugPrint('⚠️ [AuthCubit] Failed to refresh: ${failure.message}');
          // Keep current state, just log the error
        },
        (refreshedUser) {
          debugPrint('✅ [AuthCubit] User data refreshed successfully');
          debugPrint(
            '📸 [AuthCubit] Refreshed photo length: ${refreshedUser.photoBase64?.length ?? 0}',
          );
          // Emit new state with refreshed data
          emit(AuthAuthenticated(refreshedUser));
        },
      );
    } catch (e) {
      debugPrint('⚠️ [AuthCubit] Error refreshing from Firestore: $e');
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.isRight()) {
      final user = result.getOrElse(() => throw Exception('User not found'));
      // Sync user to Supabase BEFORE emitting authenticated state
      await _syncUserToSupabase();
      emit(AuthAuthenticated(user));
    } else {
      final failure = result.fold(
        (f) => f,
        (r) => throw Exception('Unexpected state'),
      );
      emit(AuthError(failure.message));
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.isRight()) {
      final user = result.getOrElse(() => throw Exception('User not found'));
      // Sync user to Supabase BEFORE emitting authenticated state
      await _syncUserToSupabase();
      emit(AuthAuthenticated(user));
    } else {
      final failure = result.fold(
        (f) => f,
        (r) => throw Exception('Unexpected state'),
      );
      emit(AuthError(failure.message));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    debugPrint('🔵 [AuthCubit] Starting Google Sign In');
    emit(const AuthLoading());

    final result = await _authRepository.signInWithGoogle();

    if (result.isRight()) {
      final user = result.getOrElse(() => throw Exception('User not found'));
      debugPrint('✅ [AuthCubit] Google Sign In success');
      // Sync user to Supabase BEFORE emitting authenticated state
      await _syncUserToSupabase();
      emit(AuthAuthenticated(user));
    } else {
      final failure = result.fold(
        (f) => f,
        (r) => throw Exception('Unexpected state'),
      );
      debugPrint('❌ [AuthCubit] Google Sign In failed: ${failure.message}');
      emit(AuthError(failure.message));
    }
  }

  /// Sync Firebase user to Supabase
  Future<void> _syncUserToSupabase() async {
    try {
      await community_di.sl<SupabaseAuthSyncService>().onUserSignedIn();
      debugPrint('✅ [AuthCubit] User synced to Supabase');
    } catch (e) {
      debugPrint('❌ [AuthCubit] Failed to sync user to Supabase: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    emit(const AuthLoading());

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Update user photo from File
  Future<void> updateUserPhoto(File imageFile) async {
    // Get current user
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) {
      emit(const AuthError('المستخدم غير مسجل دخول.'));
      return;
    }

    // Emit loading state but preserve current user
    emit(AuthPhotoUploading(currentUser));

    try {
      // Convert image to base64
      final photoBase64 = await ImageHelper.fileToBase64(imageFile);

      if (photoBase64 == null) {
        emit(const AuthError('فشل تحويل الصورة. يرجى المحاولة مرة أخرى.'));
        emit(AuthAuthenticated(currentUser)); // Restore previous state
        return;
      }

      // Update photo in repository
      final result = await _authRepository.updateUserPhoto(
        userId: currentUser.id,
        photoBase64: photoBase64,
      );

      result.fold(
        (failure) {
          debugPrint('❌ [AuthCubit] فشل تحديث الصورة: ${failure.message}');
          emit(AuthError(failure.message));
          emit(AuthAuthenticated(currentUser)); // Restore previous state
        },
        (updatedUser) {
          debugPrint('✅ [AuthCubit] تم تحديث الصورة بنجاح');
          debugPrint(
            '📸 [AuthCubit] Photo length: ${updatedUser.photoBase64?.length ?? 0}',
          );
          debugPrint('🔄 [AuthCubit] Emitting new AuthAuthenticated state');
          emit(AuthAuthenticated(updatedUser));
        },
      );
    } catch (e) {
      emit(AuthError('حدث خطأ أثناء تحديث الصورة: ${e.toString()}'));
      emit(AuthAuthenticated(currentUser)); // Restore previous state
    }
  }

  /// Get current user
  bool get isAuthenticated => _authRepository.isAuthenticated;

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
