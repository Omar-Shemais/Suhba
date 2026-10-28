import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_firestore_datasource.dart';
import '../models/user_model.dart';
import '../../../../../core/utils/image_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserFirestoreDataSource firestoreDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.firestoreDataSource,
  });

  @override
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 [Auth] محاولة تسجيل الدخول بالإيميل: $email');

      var user = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      debugPrint('✅ [Auth] تم تسجيل الدخول بنجاح');

      try {
        debugPrint('📥 [Auth] جلب بيانات المستخدم من Firestore...');
        final UserModel? firestoreUser = await firestoreDataSource.getUserData(
          user.id,
        );

        if (firestoreUser != null) {
          user = firestoreUser;
          debugPrint('✅ [Auth] تم جلب البيانات من Firestore بنجاح');
          debugPrint(
            '📸 [Auth] Photo exists: ${firestoreUser.photoBase64 != null}, length: ${firestoreUser.photoBase64?.length ?? 0}',
          );
        } else {
          debugPrint(
            '⚠️ [Auth] المستخدم غير موجود في Firestore - تسجيل دخول لأول مرة',
          );
        }
      } catch (e) {
        debugPrint('⚠️ [Auth] خطأ في جلب البيانات من Firestore: $e');
        debugPrint('⚠️ [Auth] المتابعة بدون صورة - سيتم عرض initials');
      }

      debugPrint('💾 [Auth] حفظ البيانات محلياً...');
      await localDataSource.cacheUser(user);
      debugPrint('✅ [Auth] تم حفظ البيانات محلياً');

      return Right(user);
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] فشل تسجيل الدخول: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] خطأ غير متوقع: ${e.toString()}');
      return Left(AuthFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      debugPrint('📝 [Auth] محاولة إنشاء حساب جديد: $email');

      final user = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      debugPrint('✅ [Auth] تم إنشاء الحساب بنجاح');

      debugPrint('💾 [Auth] حفظ البيانات في Firestore...');
      await firestoreDataSource.saveUserData(user);
      debugPrint('✅ [Auth] تم حفظ البيانات في Firestore');

      debugPrint('💾 [Auth] حفظ البيانات محلياً...');
      await localDataSource.cacheUser(user);
      debugPrint('✅ [Auth] تم حفظ البيانات محلياً');

      return Right(user);
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] فشل إنشاء الحساب: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] خطأ غير متوقع: ${e.toString()}');
      return Left(AuthFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      debugPrint('🔐 [Auth] محاولة تسجيل الدخول بجوجل');

      var user = await remoteDataSource.signInWithGoogle();
      debugPrint('✅ [Auth] تم تسجيل الدخول بجوجل بنجاح');

      try {
        debugPrint('📥 [Auth] جلب بيانات المستخدم من Firestore...');
        final UserModel? firestoreUser = await firestoreDataSource.getUserData(
          user.id,
        );

        if (firestoreUser != null) {
          user = firestoreUser;
          debugPrint('✅ [Auth] تم جلب البيانات من Firestore بنجاح');
          debugPrint(
            '📸 [Auth] Photo exists: ${firestoreUser.photoBase64 != null}, length: ${firestoreUser.photoBase64?.length ?? 0}',
          );
        } else {
          if (user.photoBase64 != null) {
            debugPrint(
              '💾 [Auth] تسجيل دخول Google لأول مرة - حفظ البيانات مع صورة Google...',
            );
            debugPrint(
              '📸 [Auth] Google photo length: ${user.photoBase64?.length ?? 0}',
            );
            await firestoreDataSource.saveUserData(user);
            debugPrint('✅ [Auth] تم حفظ البيانات في Firestore');
          } else {
            debugPrint('⚠️ [Auth] تسجيل دخول Google لأول مرة بدون صورة');
          }
        }
      } catch (e) {
        debugPrint('⚠️ [Auth] خطأ في جلب البيانات من Firestore: $e');
        debugPrint('⚠️ [Auth] المتابعة بدون صورة');
      }

      debugPrint('💾 [Auth] حفظ البيانات محلياً...');
      await localDataSource.cacheUser(user);
      debugPrint('✅ [Auth] تم حفظ البيانات محلياً');

      return Right(user);
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] فشل تسجيل الدخول بجوجل: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] خطأ غير متوقع: ${e.toString()}');
      return Left(AuthFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithFacebook() async {
    try {
      debugPrint('🔐 [Auth] محاولة تسجيل الدخول بـ Facebook');

      var user = await remoteDataSource.signInWithFacebook();
      debugPrint('✅ [Auth] تم تسجيل الدخول بـ Facebook بنجاح');

      try {
        debugPrint('📥 [Auth] جلب بيانات المستخدم من Firestore...');
        final UserModel? firestoreUser = await firestoreDataSource.getUserData(
          user.id,
        );

        if (firestoreUser != null) {
          user = firestoreUser;
          debugPrint('✅ [Auth] تم جلب البيانات من Firestore بنجاح');
          debugPrint(
            '📸 [Auth] Photo exists: ${firestoreUser.photoBase64 != null}, length: ${firestoreUser.photoBase64?.length ?? 0}',
          );
        } else {
          if (user.photoBase64 == null) {
            final nameForInitials = (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName!
                : (user.email.isNotEmpty ? user.email : 'User');
            final photoBase64 = await ImageHelper.generateInitialsAvatarBase64(
              nameForInitials,
            );
            user = user.copyWith(photoBase64: photoBase64, updatePhoto: true);
          }
          await firestoreDataSource.saveUserData(user);
          debugPrint('✅ [Auth] تم حفظ بيانات مستخدم Facebook في Firestore');
        }
      } catch (e) {
        debugPrint('⚠️ [Auth] خطأ في التعامل مع بيانات Firestore: $e');
      }

      debugPrint('💾 [Auth] حفظ البيانات محلياً...');
      await localDataSource.cacheUser(user);
      debugPrint('✅ [Auth] تم حفظ البيانات محلياً');

      return Right(user);
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] فشل تسجيل الدخول بـ Facebook: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] خطأ غير متوقع: ${e.toString()}');
      return Left(AuthFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 [Auth] إرسال رابط إعادة تعيين كلمة المرور إلى: $email');
      await remoteDataSource.sendPasswordResetEmail(email);
      debugPrint('✅ [Auth] تم إرسال رابط إعادة التعيين بنجاح');
      return const Right(null);
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] فشل إرسال رابط التعيين: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] خطأ غير متوقع: ${e.toString()}');
      return Left(AuthFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithApple() async {
    try {
      debugPrint('🔐 [Auth] محاولة تسجيل الدخول بـ Apple');

      var user = await remoteDataSource.signInWithApple();
      debugPrint('✅ [Auth] تم تسجيل الدخول بـ Apple بنجاح');

      try {
        debugPrint('📥 [Auth] جلب بيانات المستخدم من Firestore...');
        final UserModel? firestoreUser = await firestoreDataSource.getUserData(
          user.id,
        );

        if (firestoreUser != null) {
          user = firestoreUser;
          debugPrint('✅ [Auth] تم جلب البيانات من Firestore بنجاح');
          debugPrint(
            '📸 [Auth] Photo exists: ${firestoreUser.photoBase64 != null}, length: ${firestoreUser.photoBase64?.length ?? 0}',
          );
        } else {
          if (user.photoBase64 != null) {
            debugPrint(
              '💾 [Auth] تسجيل دخول Apple لأول مرة - حفظ البيانات مع صورة initials...',
            );
            debugPrint(
              '📸 [Auth] Apple photo length: ${user.photoBase64?.length ?? 0}',
            );
            await firestoreDataSource.saveUserData(user);
            debugPrint('✅ [Auth] تم حفظ البيانات في Firestore');
          } else {
            debugPrint('⚠️ [Auth] تسجيل دخول Apple لأول مرة بدون صورة');
          }
        }
      } catch (e) {
        debugPrint('⚠️ [Auth] خطأ في جلب البيانات من Firestore: $e');
        debugPrint('⚠️ [Auth] المتابعة بدون صورة');
      }

      debugPrint('💾 [Auth] حفظ البيانات محلياً...');
      await localDataSource.cacheUser(user);
      debugPrint('✅ [Auth] تم حفظ البيانات محلياً');

      return Right(user);
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] فشل تسجيل الدخول بـ Apple: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] خطأ غير متوقع: ${e.toString()}');
      return Left(AuthFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> completeGoogleSignIn() async {
    return signInWithGoogle();
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearUser();

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AuthFailure('فشل تسجيل الخروج: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String userId) async {
    try {
      debugPrint('🗑️ [Auth] بدء حذف الحساب...');
      debugPrint('👤 [Auth] User ID: $userId');

      // Delete user data from Firestore
      debugPrint('🗑️ [Auth] حذف بيانات المستخدم من Firestore...');
      await firestoreDataSource.deleteUserData(userId);
      debugPrint('✅ [Auth] تم حذف البيانات من Firestore');

      // Delete Firebase Auth account
      debugPrint('🗑️ [Auth] حذف حساب Firebase Auth...');
      await remoteDataSource.deleteAccount();
      debugPrint('✅ [Auth] تم حذف حساب Firebase Auth');

      // Clear local cache
      debugPrint('🗑️ [Auth] مسح البيانات المحلية...');
      await localDataSource.clearUser();
      debugPrint('✅ [Auth] تم مسح البيانات المحلية');

      debugPrint('✅ [Auth] تم حذف الحساب بنجاح');
      return const Right(null);
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] فشل حذف الحساب: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] خطأ في حذف الحساب: ${e.toString()}');
      return Left(AuthFailure('فشل حذف الحساب: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserPhoto({
    required String userId,
    required String photoBase64,
  }) async {
    try {
      debugPrint('📸 [Auth] بدء تحديث الصورة...');
      debugPrint('📸 [Auth] User ID: $userId');
      debugPrint('📸 [Auth] Photo length: ${photoBase64.length}');

      debugPrint('💾 [Auth] حفظ الصورة في Firestore...');
      await firestoreDataSource.updateUserPhoto(userId, photoBase64);
      debugPrint('✅ [Auth] تم حفظ الصورة في Firestore بنجاح');

      final currentUser = getCurrentUser();
      if (currentUser == null) {
        return Left(const AuthFailure('المستخدم غير مسجل دخول.'));
      }

      final updatedUser = currentUser.copyWith(
        photoBase64: photoBase64,
        updatePhoto: true,
      );

      debugPrint(
        '📸 [Auth] Updated user photo length: ${updatedUser.photoBase64?.length ?? 0}',
      );

      debugPrint('💾 [Auth] حفظ الصورة في الـ cache...');
      await localDataSource.cacheUser(updatedUser);
      debugPrint('✅ [Auth] تم حفظ الصورة في الـ cache بنجاح');

      return Right(updatedUser);
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] فشل تحديث الصورة: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] خطأ في تحديث الصورة: ${e.toString()}');
      return Left(AuthFailure('فشل تحديث الصورة: ${e.toString()}'));
    }
  }

  @override
  UserModel? getCurrentUser() {
    final cachedUser = localDataSource.getCachedUser();
    if (cachedUser != null) {
      return cachedUser;
    }

    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<Either<Failure, UserModel>> refreshUserData(String userId) async {
    try {
      debugPrint('🔄 [Auth] Refreshing user data from Firestore...');
      debugPrint('👤 [Auth] User ID: $userId');

      final firestoreUser = await firestoreDataSource.getUserData(userId);

      if (firestoreUser != null) {
        debugPrint('✅ [Auth] User data refreshed successfully');
        debugPrint(
          '📸 [Auth] Photo exists: ${firestoreUser.photoBase64 != null}, length: ${firestoreUser.photoBase64?.length ?? 0}',
        );

        await localDataSource.cacheUser(firestoreUser);
        debugPrint('💾 [Auth] Cache updated with fresh data');

        return Right(firestoreUser);
      } else {
        debugPrint('⚠️ [Auth] User not found in Firestore');
        return Left(const AuthFailure('المستخدم غير موجود في قاعدة البيانات'));
      }
    } on Failure catch (failure) {
      debugPrint('❌ [Auth] Failed to refresh user data: ${failure.message}');
      return Left(failure);
    } catch (e) {
      debugPrint('❌ [Auth] Error refreshing user data: $e');
      return Left(AuthFailure('فشل تحديث البيانات: ${e.toString()}'));
    }
  }

  @override
  bool get isAuthenticated {
    return remoteDataSource.isAuthenticated || localDataSource.hasUser;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }
}
