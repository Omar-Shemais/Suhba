import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
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
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      debugPrint(
        '🔔 [AuthCubit] Firebase auth state changed, user: ${user?.id}, currentState: ${state.runtimeType}',
      );

      if (state is AuthLoading ||
          state is GoogleSignInPending ||
          state is AuthDeletingAccount) {
        debugPrint(
          '⏸️ [AuthCubit] Skipping Firebase listener emit (state: ${state.runtimeType})',
        );
        return;
      }

      if (user != null) {
        UserModel userToEmit = user;
        // If we currently have an authenticated user with photoBase64, preserve it
        if (state is AuthAuthenticated) {
          final currentUser = (state as AuthAuthenticated).user;
          if (user.photoBase64 == null && currentUser.photoBase64 != null) {
            userToEmit = user.copyWith(photoBase64: currentUser.photoBase64);
          }
        } else {
          final cachedUser = _authRepository.getCurrentUser();
          if (cachedUser != null &&
              cachedUser.id == user.id &&
              cachedUser.photoBase64 != null) {
            userToEmit = user.copyWith(photoBase64: cachedUser.photoBase64);
          }
        }

        debugPrint(
          '✅ [AuthCubit] Emitting AuthAuthenticated from Firebase listener: ${userToEmit.id}',
        );
        emit(AuthAuthenticated(userToEmit));
      } else {
        // Firebase user is null (can happen during initial startup/cold boot or offline)
        // DO NOT log out if there is a valid cached user session!
        final cachedUser = _authRepository.getCurrentUser();
        if (cachedUser != null) {
          debugPrint(
            '🛡️ [AuthCubit] Firebase user is null, but cached user found (${cachedUser.id}). Preserving session.',
          );
          if (state is! AuthAuthenticated) {
            emit(AuthAuthenticated(cachedUser));
          }
          return;
        }

        debugPrint(
          '🚪 [AuthCubit] Emitting AuthUnauthenticated from Firebase listener',
        );
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    try {
      final user = _authRepository.getCurrentUser();

      if (user != null) {
        debugPrint('🔍 [AuthCubit] User found in cache/remote: ${user.id}');
        debugPrint(
          '📸 [AuthCubit] Cached photo length: ${user.photoBase64?.length ?? 0}',
        );

        emit(AuthAuthenticated(user));

        debugPrint('🔄 [AuthCubit] Refreshing user data from Firestore...');
        _refreshUserFromFirestore(user.id);
      } else {
        debugPrint('ℹ️ [AuthCubit] No user found in cache or remote');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Error in checkAuthStatus: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _refreshUserFromFirestore(String userId) async {
    try {
      debugPrint('📥 [AuthCubit] Background refresh from Firestore...');

      final result = await _authRepository.refreshUserData(userId);

      result.fold(
        (failure) {
          debugPrint('⚠️ [AuthCubit] Failed to refresh: ${failure.message}');
        },
        (refreshedUser) {
          debugPrint('✅ [AuthCubit] User data refreshed successfully');
          debugPrint(
            '📸 [AuthCubit] Refreshed photo length: ${refreshedUser.photoBase64?.length ?? 0}',
          );
          emit(AuthAuthenticated(refreshedUser));
        },
      );
    } catch (e) {
      debugPrint('⚠️ [AuthCubit] Error refreshing from Firestore: $e');
    }
  }

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

  Future<void> signInWithGoogle() async {
    debugPrint('🔵 [AuthCubit] Starting Google Sign In');
    emit(const AuthLoading());

    final result = await _authRepository.signInWithGoogle();

    if (result.isRight()) {
      final user = result.getOrElse(() => throw Exception('User not found'));
      debugPrint('✅ [AuthCubit] Google Sign In success');
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

  Future<void> signInWithFacebook() async {
    debugPrint('🔵 [AuthCubit] Starting Facebook Sign In');
    emit(const AuthLoading());

    final result = await _authRepository.signInWithFacebook();

    if (result.isRight()) {
      final user = result.getOrElse(() => throw Exception('User not found'));
      debugPrint('✅ [AuthCubit] Facebook Sign In success');
      await _syncUserToSupabase();
      emit(AuthAuthenticated(user));
    } else {
      final failure = result.fold(
        (f) => f,
        (r) => throw Exception('Unexpected state'),
      );
      debugPrint('❌ [AuthCubit] Facebook Sign In failed: ${failure.message}');
      emit(AuthError(failure.message));
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    final result = await _authRepository.sendPasswordResetEmail(email);
    return result.fold(
      (failure) {
        emit(AuthError(failure.message));
        return false;
      },
      (_) => true,
    );
  }

  Future<void> signInWithApple() async {
    debugPrint('🍎 [AuthCubit] Starting Apple Sign In');
    emit(const AuthLoading());

    final result = await _authRepository.signInWithApple();

    if (result.isRight()) {
      final user = result.getOrElse(() => throw Exception('User not found'));
      debugPrint('✅ [AuthCubit] Apple Sign In success');
      await _syncUserToSupabase();
      emit(AuthAuthenticated(user));
    } else {
      final failure = result.fold(
        (f) => f,
        (r) => throw Exception('Unexpected state'),
      );
      debugPrint('❌ [AuthCubit] Apple Sign In failed: ${failure.message}');
      emit(AuthError(failure.message));
    }
  }

  Future<void> _syncUserToSupabase() async {
    try {
      await community_di.sl<SupabaseAuthSyncService>().onUserSignedIn();
      debugPrint('✅ [AuthCubit] User synced to Supabase');
    } catch (e) {
      debugPrint('❌ [AuthCubit] Failed to sync user to Supabase: $e');
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> deleteAccount() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) {
      emit(const AuthError('المستخدم غير مسجل دخول.'));
      return;
    }

    debugPrint(
      '🗑️ [AuthCubit] Starting account deletion for user: ${currentUser.id}',
    );
    emit(const AuthDeletingAccount());

    final result = await _authRepository.deleteAccount(currentUser.id);

    result.fold(
      (failure) {
        debugPrint('❌ [AuthCubit] Account deletion failed: ${failure.message}');
        emit(AuthError(failure.message));
        // Return to authenticated state if deletion fails
        emit(AuthAuthenticated(currentUser));
      },
      (_) {
        debugPrint('✅ [AuthCubit] Account deleted successfully');
        emit(const AuthUnauthenticated());
      },
    );
  }

  Future<void> updateUserPhoto(File imageFile) async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) {
      emit(const AuthError('المستخدم غير مسجل دخول.'));
      return;
    }

    emit(AuthPhotoUploading(currentUser));

    try {
      final photoBase64 = await ImageHelper.fileToBase64(imageFile);

      if (photoBase64 == null) {
        emit(const AuthError('فشل تحويل الصورة. يرجى المحاولة مرة أخرى.'));
        emit(AuthAuthenticated(currentUser));
        return;
      }

      final result = await _authRepository.updateUserPhoto(
        userId: currentUser.id,
        photoBase64: photoBase64,
      );

      result.fold(
        (failure) {
          debugPrint('❌ [AuthCubit] فشل تحديث الصورة: ${failure.message}');
          emit(AuthError(failure.message));
          emit(AuthAuthenticated(currentUser));
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
      emit(AuthAuthenticated(currentUser));
    }
  }

  bool get isAuthenticated => _authRepository.isAuthenticated;

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
