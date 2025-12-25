import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/utils/image_helper.dart';

abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Apple
  Future<UserModel> signInWithApple();

  /// Complete Google Sign In with Firebase after confirmation
  Future<UserModel> completeGoogleSignIn();

  /// Sign out
  Future<void> signOut();

  /// Delete the current user's Firebase Auth account
  Future<void> deleteAccount();

  /// Get current user
  UserModel? getCurrentUser();

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Listen to auth state changes
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('فشل تسجيل الدخول. المستخدم غير موجود.');
      }

      final user = UserModel.fromFirebaseUser(userCredential.user!);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthFailure('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('فشل إنشاء الحساب.');
      }

      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw const AuthFailure('فشل تحديث معلومات المستخدم.');
      }

      var user = UserModel.fromFirebaseUser(updatedUser);

      final photoBase64 = await ImageHelper.generateInitialsAvatarBase64(
        displayName.isNotEmpty ? displayName : email,
      );
      user = user.copyWith(photoBase64: photoBase64, updatePhoto: true);

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthFailure('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthFailure('تم إلغاء تسجيل الدخول بواسطة المستخدم.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('فشل تسجيل الدخول باستخدام Google.');
      }

      var user = UserModel.fromFirebaseUser(userCredential.user!);

      if (userCredential.user!.photoURL != null) {
        final photoBase64 = await ImageHelper.urlToBase64(
          userCredential.user!.photoURL!,
        );
        if (photoBase64 != null) {
          user = user.copyWith(photoBase64: photoBase64, updatePhoto: true);
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthFailure(
        'حدث خطأ أثناء تسجيل الدخول بواسطة Google: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with Apple credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        oAuthCredential,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('فشل تسجيل الدخول باستخدام Apple.');
      }

      var user = UserModel.fromFirebaseUser(userCredential.user!);

      // For first-time Apple sign in, update display name if provided
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        String? displayName;

        // Try to construct display name from Apple's name components
        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          displayName = [
            appleCredential.givenName,
            appleCredential.familyName,
          ].where((name) => name != null && name.isNotEmpty).join(' ');

          if (displayName.isNotEmpty) {
            await userCredential.user!.updateDisplayName(displayName);
            await userCredential.user!.reload();

            // Refresh user model with updated name
            final updatedUser = _firebaseAuth.currentUser;
            if (updatedUser != null) {
              user = UserModel.fromFirebaseUser(updatedUser);
            }
          }
        }

        // Generate initials avatar for Apple sign-in
        final nameForInitials =
            displayName ?? user.displayName ?? user.email ?? 'User';
        final photoBase64 = await ImageHelper.generateInitialsAvatarBase64(
          nameForInitials,
        );
        user = user.copyWith(photoBase64: photoBase64, updatePhoto: true);
      }

      return user;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle Apple-specific exceptions
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw const AuthFailure('تم إلغاء تسجيل الدخول بواسطة المستخدم.');
        case AuthorizationErrorCode.failed:
          throw const AuthFailure('فشل تسجيل الدخول باستخدام Apple.');
        case AuthorizationErrorCode.invalidResponse:
          throw const AuthFailure('استجابة غير صالحة من Apple.');
        case AuthorizationErrorCode.notHandled:
          throw const AuthFailure('لم تتم معالجة طلب تسجيل الدخول.');
        case AuthorizationErrorCode.unknown:
          throw const AuthFailure('حدث خطأ غير معروف.');
        default:
          throw AuthFailure('حدث خطأ: ${e.code}');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthFailure(
        'حدث خطأ أثناء تسجيل الدخول بواسطة Apple: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> completeGoogleSignIn() async {
    return signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw AuthFailure('فشل تسجيل الخروج: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure('لا يوجد مستخدم مسجل دخول');
      }

      print(
        '🗑️ [Remote] Deleting Firebase Auth account for user: ${user.uid}',
      );

      await user.delete();

      print('✅ [Remote] Firebase Auth account deleted successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ [Remote] Firebase Auth deletion error: ${e.code}');

      if (e.code == 'requires-recent-login') {
        throw const AuthFailure(
          'يجب إعادة تسجيل الدخول لحذف الحساب. يرجى تسجيل الخروج وتسجيل الدخول مرة أخرى.',
        );
      }

      throw AuthFailure('فشل حذف الحساب: ${e.message}');
    } catch (e) {
      print('❌ [Remote] Unexpected error: $e');
      throw AuthFailure('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  Failure _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundFailure(
          'البريد الإلكتروني غير مسجل. يرجى إنشاء حساب جديد.',
        );
      case 'wrong-password':
        return const InvalidCredentialsFailure(
          'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.',
        );
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure(
          'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد آخر أو تسجيل الدخول.',
        );
      case 'invalid-email':
        return const InvalidEmailFailure(
          'البريد الإلكتروني غير صحيح. يرجى إدخال بريد إلكتروني صحيح.',
        );
      case 'weak-password':
        return const WeakPasswordFailure(
          'كلمة المرور ضعيفة. يجب أن تحتوي على 6 أحرف على الأقل.',
        );
      case 'user-disabled':
        return const UserDisabledFailure(
          'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم.',
        );
      case 'too-many-requests':
        return const TooManyRequestsFailure(
          'محاولات كثيرة جداً. يرجى المحاولة لاحقاً.',
        );
      case 'operation-not-allowed':
        return const OperationNotAllowedFailure(
          'طريقة تسجيل الدخول غير مفعلة. يرجى التواصل مع الدعم.',
        );
      case 'invalid-credential':
        return const InvalidCredentialsFailure(
          'بيانات الاعتماد غير صحيحة. يرجى المحاولة مرة أخرى.',
        );
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          'يوجد حساب بنفس البريد الإلكتروني بطريقة دخول مختلفة.',
        );
      case 'requires-recent-login':
        return const AuthFailure('يجب إعادة تسجيل الدخول لإجراء هذه العملية.');
      default:
        return AuthFailure('حدث خطأ: ${e.message ?? e.code}');
    }
  }
}
