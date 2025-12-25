import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  /// Sign in with Google (returns user data for confirmation)
  Future<UserModel> signInWithGoogle();

  /// Complete Google Sign In with Firebase after confirmation
  Future<UserModel> completeGoogleSignIn();

  /// Sign out
  Future<void> signOut();

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

      // Create user model from Firebase Auth (without photo - it will be loaded from Firestore)
      final user = UserModel.fromFirebaseUser(userCredential.user!);

      // Don't generate initials here - let the repository fetch photo from Firestore
      // Initials will be generated in UI if no photo exists
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

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw const AuthFailure('فشل تحديث معلومات المستخدم.');
      }

      // Create user model
      var user = UserModel.fromFirebaseUser(updatedUser);

      // Generate initials avatar for email signups
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
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthFailure('تم إلغاء تسجيل الدخول بواسطة المستخدم.');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('فشل تسجيل الدخول باستخدام Google.');
      }

      // Create user model from Google Sign In
      var user = UserModel.fromFirebaseUser(userCredential.user!);

      // Convert Google photo to base64 if it exists (for first time Google sign in)
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
  Future<UserModel> completeGoogleSignIn() async {
    // This method is no longer needed - keeping for interface compatibility
    return signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from both Firebase and Google
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw AuthFailure('فشل تسجيل الخروج: ${e.toString()}');
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

  /// Handle Firebase Auth exceptions and convert them to Failures
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
      default:
        return AuthFailure('حدث خطأ: ${e.message ?? e.code}');
    }
  }
}
