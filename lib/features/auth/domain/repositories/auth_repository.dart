import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google
  Future<Either<Failure, UserModel>> signInWithGoogle();

  /// Sign in with Facebook
  Future<Either<Failure, UserModel>> signInWithFacebook();

  /// Sign in with Apple
  Future<Either<Failure, UserModel>> signInWithApple();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Complete Google Sign In with Firebase after confirmation
  Future<Either<Failure, UserModel>> completeGoogleSignIn();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Delete account
  /// 🟢 ADDED THIS METHOD
  Future<Either<Failure, void>> deleteAccount(String userId);

  /// Update user photo
  Future<Either<Failure, UserModel>> updateUserPhoto({
    required String userId,
    required String photoBase64,
  });

  /// Get current user (from cache or Firebase)
  UserModel? getCurrentUser();

  /// Refresh user data from Firestore
  Future<Either<Failure, UserModel>> refreshUserData(String userId);

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Listen to auth state changes
  Stream<UserModel?> get authStateChanges;
}
