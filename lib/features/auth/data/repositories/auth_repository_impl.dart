import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_firestore_datasource.dart';
import '../models/user_model.dart';

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

      // Try to fetch existing user data from Firestore (to get photo and other data)
      try {
        debugPrint('📥 [Auth] جلب بيانات المستخدم من Firestore...');
        final UserModel? firestoreUser = await firestoreDataSource.getUserData(
          user.id,
        );

        if (firestoreUser != null) {
          // Use Firestore data (it has the saved photo and other data)
          user = firestoreUser;
          debugPrint('✅ [Auth] تم جلب البيانات من Firestore بنجاح');
          debugPrint(
            '📸 [Auth] Photo exists: ${firestoreUser.photoBase64 != null}, length: ${firestoreUser.photoBase64?.length ?? 0}',
          );
        } else {
          // First time login - user doesn't exist in Firestore yet
          debugPrint(
            '⚠️ [Auth] المستخدم غير موجود في Firestore - تسجيل دخول لأول مرة',
          );
          // Don't save here - we don't have photo data yet
          // Photo will be null and initials will be generated in UI
        }
      } catch (e) {
        // Error fetching from Firestore - continue without photo
        debugPrint('⚠️ [Auth] خطأ في جلب البيانات من Firestore: $e');
        debugPrint('⚠️ [Auth] المتابعة بدون صورة - سيتم عرض initials');
        // Don't save - we don't want to overwrite existing data
      }

      // Cache the user locally
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

      // Save to Firestore (cloud database)
      debugPrint('💾 [Auth] حفظ البيانات في Firestore...');
      await firestoreDataSource.saveUserData(user);
      debugPrint('✅ [Auth] تم حفظ البيانات في Firestore');

      // Cache the user locally
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

      // Try to fetch existing user data from Firestore (to get photo and other data)
      try {
        debugPrint('📥 [Auth] جلب بيانات المستخدم من Firestore...');
        final UserModel? firestoreUser = await firestoreDataSource.getUserData(
          user.id,
        );

        if (firestoreUser != null) {
          // Use existing Firestore data (has saved photo)
          user = firestoreUser;
          debugPrint('✅ [Auth] تم جلب البيانات من Firestore بنجاح');
          debugPrint(
            '📸 [Auth] Photo exists: ${firestoreUser.photoBase64 != null}, length: ${firestoreUser.photoBase64?.length ?? 0}',
          );
        } else {
          // First time Google sign in - save user with Google photo if available
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
        // Error fetching - continue without overwriting
        debugPrint('⚠️ [Auth] خطأ في جلب البيانات من Firestore: $e');
        debugPrint('⚠️ [Auth] المتابعة بدون صورة');
      }

      // Cache the user locally
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
  Future<Either<Failure, UserModel>> completeGoogleSignIn() async {
    // This method is no longer needed - keeping for interface compatibility
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
  Future<Either<Failure, UserModel>> updateUserPhoto({
    required String userId,
    required String photoBase64,
  }) async {
    try {
      debugPrint('📸 [Auth] بدء تحديث الصورة...');
      debugPrint('📸 [Auth] User ID: $userId');
      debugPrint('📸 [Auth] Photo length: ${photoBase64.length}');

      // Update photo in Firestore
      debugPrint('💾 [Auth] حفظ الصورة في Firestore...');
      await firestoreDataSource.updateUserPhoto(userId, photoBase64);
      debugPrint('✅ [Auth] تم حفظ الصورة في Firestore بنجاح');

      // Get current user and update with new photo
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        return Left(const AuthFailure('المستخدم غير مسجل دخول.'));
      }

      final updatedUser = currentUser.copyWith(
        photoBase64: photoBase64,
        updatePhoto: true, // Force photo update
      );

      debugPrint(
        '📸 [Auth] Updated user photo length: ${updatedUser.photoBase64?.length ?? 0}',
      );

      // Update cache with new photo
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
    // Try to get from cache first
    final cachedUser = localDataSource.getCachedUser();
    if (cachedUser != null) {
      return cachedUser;
    }

    // Otherwise get from Firebase
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<Either<Failure, UserModel>> refreshUserData(String userId) async {
    try {
      debugPrint('🔄 [Auth] Refreshing user data from Firestore...');
      debugPrint('👤 [Auth] User ID: $userId');

      // Fetch latest data from Firestore
      final firestoreUser = await firestoreDataSource.getUserData(userId);

      if (firestoreUser != null) {
        debugPrint('✅ [Auth] User data refreshed successfully');
        debugPrint(
          '📸 [Auth] Photo exists: ${firestoreUser.photoBase64 != null}, length: ${firestoreUser.photoBase64?.length ?? 0}',
        );

        // Update local cache with fresh data
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
