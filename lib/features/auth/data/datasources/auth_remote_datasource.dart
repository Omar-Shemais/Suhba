import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
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

  /// Sign in with Facebook
  Future<UserModel> signInWithFacebook();

  /// Sign in with Apple
  Future<UserModel> signInWithApple();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

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
  Future<UserModel> signInWithFacebook() async {
    try {
      final facebookProvider = OAuthProvider('facebook.com');
      facebookProvider.addScope('email');
      facebookProvider.addScope('public_profile');

      final userCredential = await _firebaseAuth.signInWithProvider(
        facebookProvider,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('فشل تسجيل الدخول باستخدام Facebook.');
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
      if (e.code == 'web-context-cancelled' ||
          e.code == 'popup-closed-by-user' ||
          e.code == 'canceled') {
        throw const AuthFailure('تم إلغاء تسجيل الدخول بواسطة المستخدم.');
      }
      if (e.code == 'channel-error' ||
          (e.message != null && e.message!.contains('signInWithProvider'))) {
        throw const AuthFailure(
          'تسجيل الدخول عبر Facebook غير مفعل بعد في Firebase Console. يرجى تفعيل موفّر Facebook في لوحة تحكم Firebase أولاً.',
        );
      }
      throw _handleFirebaseAuthException(e);
    } on PlatformException catch (e) {
      if (e.code == 'channel-error' ||
          (e.message != null && e.message!.contains('signInWithProvider'))) {
        throw const AuthFailure(
          'تسجيل الدخول عبر Facebook غير مفعل بعد في Firebase Console. يرجى تفعيل موفّر Facebook في لوحة تحكم Firebase أولاً.',
        );
      }
      throw AuthFailure('حدث خطأ في منصة التشغيل: ${e.message ?? e.code}');
    } catch (e) {
      final str = e.toString();
      if (str.contains('signInWithProvider') || str.contains('channel-error')) {
        throw const AuthFailure(
          'تسجيل الدخول عبر Facebook غير مفعل بعد في Firebase Console. يرجى تفعيل موفّر Facebook في لوحة تحكم Firebase أولاً.',
        );
      }
      throw AuthFailure(
        'حدث خطأ أثناء تسجيل الدخول بواسطة Facebook: $str',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthFailure('حدث خطأ أثناء إرسال رابط إعادة التعيين: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      UserCredential userCredential;
      String? appleDisplayName;

      if (!kIsWeb && Platform.isIOS) {
        // Native Apple ID dialog on iOS
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oAuthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        userCredential = await _firebaseAuth.signInWithCredential(
          oAuthCredential,
        );

        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          appleDisplayName = [
            appleCredential.givenName,
            appleCredential.familyName,
          ].where((name) => name != null && name.isNotEmpty).join(' ');
        }
      } else {
        // Android / Web / other: use Firebase OAuthProvider
        final appleProvider = OAuthProvider('apple.com');
        appleProvider.addScope('email');
        appleProvider.addScope('name');

        userCredential = await _firebaseAuth.signInWithProvider(
          appleProvider,
        );
      }

      if (userCredential.user == null) {
        throw const AuthFailure('فشل تسجيل الدخول باستخدام Apple.');
      }

      var user = UserModel.fromFirebaseUser(userCredential.user!);

      // For first-time Apple sign in, update display name if provided
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        if (appleDisplayName != null && appleDisplayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(appleDisplayName);
          await userCredential.user!.reload();

          final updatedUser = _firebaseAuth.currentUser;
          if (updatedUser != null) {
            user = UserModel.fromFirebaseUser(updatedUser);
          }
        }

        final nameForInitials =
            appleDisplayName ?? user.displayName ?? (user.email.isNotEmpty ? user.email : 'User');
        final photoBase64 = await ImageHelper.generateInitialsAvatarBase64(
          nameForInitials,
        );
        user = user.copyWith(photoBase64: photoBase64, updatePhoto: true);
      }

      return user;
    } on SignInWithAppleAuthorizationException catch (e) {
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
      if (e.code == 'web-context-cancelled' ||
          e.code == 'popup-closed-by-user' ||
          e.code == 'canceled') {
        throw const AuthFailure('تم إلغاء تسجيل الدخول بواسطة المستخدم.');
      }
      if (e.code == 'channel-error' ||
          (e.message != null && e.message!.contains('signInWithProvider'))) {
        throw const AuthFailure(
          'تسجيل الدخول عبر Apple غير مفعل بعد في Firebase Console. يرجى تفعيل موفّر Apple في لوحة تحكم Firebase أولاً.',
        );
      }
      throw _handleFirebaseAuthException(e);
    } on PlatformException catch (e) {
      if (e.code == 'channel-error' ||
          (e.message != null && e.message!.contains('signInWithProvider'))) {
        throw const AuthFailure(
          'تسجيل الدخول عبر Apple غير مفعل بعد في Firebase Console. يرجى تفعيل موفّر Apple في لوحة تحكم Firebase أولاً.',
        );
      }
      throw AuthFailure('حدث خطأ في منصة التشغيل: ${e.message ?? e.code}');
    } catch (e) {
      final str = e.toString();
      if (str.contains('signInWithProvider') || str.contains('channel-error')) {
        throw const AuthFailure(
          'تسجيل الدخول عبر Apple غير مفعل بعد في Firebase Console. يرجى تفعيل موفّر Apple في لوحة تحكم Firebase أولاً.',
        );
      }
      throw AuthFailure(
        'حدث خطأ أثناء تسجيل الدخول بواسطة Apple: $str',
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

      debugPrint(
        '🗑️ [Remote] Deleting Firebase Auth account for user: ${user.uid}',
      );

      await user.delete();

      debugPrint('✅ [Remote] Firebase Auth account deleted successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [Remote] Firebase Auth deletion error: ${e.code}');

      if (e.code == 'requires-recent-login') {
        throw const AuthFailure(
          'يجب إعادة تسجيل الدخول لحذف الحساب. يرجى تسجيل الخروج وتسجيل الدخول مرة أخرى.',
        );
      }

      throw AuthFailure('فشل حذف الحساب: ${e.message}');
    } catch (e) {
      debugPrint('❌ [Remote] Unexpected error: $e');
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
      case 'channel-error':
        if (e.message != null && e.message!.contains('signInWithProvider')) {
          return const AuthFailure(
            'تسجيل الدخول عبر Facebook غير مفعل بعد في Firebase Console. يرجى تفعيل موفّر Facebook في لوحة تحكم Firebase.',
          );
        }
        return AuthFailure('حدث خطأ في الاتصال: ${e.message ?? e.code}');
      case 'CONFIGURATION_NOT_FOUND':
        return const AuthFailure(
          'موفّر تسجيل الدخول غير مفعل في Firebase Console. يرجى تفعيله في Sign-in method.',
        );
      default:
        return AuthFailure('حدث خطأ: ${e.message ?? e.code}');
    }
  }
}
