import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../../../core/errors/failures.dart';

abstract class UserFirestoreDataSource {
  /// Save user data to Firestore
  Future<void> saveUserData(UserModel user);

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String userId);

  /// Update user data in Firestore
  Future<void> updateUserData(String userId, Map<String, dynamic> data);

  /// Update user photo in Firestore
  Future<void> updateUserPhoto(String userId, String photoBase64);

  /// Delete user data from Firestore
  Future<void> deleteUserData(String userId);
}

class UserFirestoreDataSourceImpl implements UserFirestoreDataSource {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  UserFirestoreDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(
            user.toJson(),
            SetOptions(merge: true), // Merge with existing data
          );
    } catch (e) {
      throw ServerFailure('فشل حفظ بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUserData(String userId) async {
    try {
      debugPrint('🔥 [Firestore] Getting user data for: $userId');
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ [Firestore] User document does not exist');
        return null;
      }

      final data = doc.data()!;
      final photoLength = (data['photoBase64'] as String?)?.length ?? 0;
      debugPrint(
        '🔥 [Firestore] Retrieved user data, photo length: $photoLength',
      );

      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('❌ [Firestore] Failed to get user data: $e');
      throw ServerFailure('فشل استرجاع بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
    } catch (e) {
      throw ServerFailure('فشل تحديث بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserPhoto(String userId, String photoBase64) async {
    try {
      debugPrint('🔥 [Firestore] Updating photo for user: $userId');
      debugPrint('🔥 [Firestore] Photo length: ${photoBase64.length}');

      await _firestore.collection(_usersCollection).doc(userId).update({
        'photoBase64': photoBase64,
      });

      debugPrint('✅ [Firestore] Photo updated successfully');

      // Verify the update by reading back
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      final savedPhoto = doc.data()?['photoBase64'] as String?;
      debugPrint(
        '🔍 [Firestore] Verified photo length: ${savedPhoto?.length ?? 0}',
      );
    } catch (e) {
      debugPrint('❌ [Firestore] Failed to update photo: $e');
      throw ServerFailure('فشل تحديث صورة المستخدم: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserData(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw ServerFailure('فشل حذف بيانات المستخدم: ${e.toString()}');
    }
  }
}
