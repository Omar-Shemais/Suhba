import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../../../../../core/errors/failures.dart';

abstract class AuthLocalDataSource {
  /// Cache user data in Hive
  Future<void> cacheUser(UserModel user);

  /// Get cached user from Hive
  UserModel? getCachedUser();

  /// Clear cached user (for logout)
  Future<void> clearUser();

  /// Check if user is cached
  bool get hasUser;
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box _box;
  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl({required Box box}) : _box = box;

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _box.put(_userKey, user.toJson());
    } catch (e) {
      throw CacheFailure('فشل حفظ بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  UserModel? getCachedUser() {
    try {
      final userJson = _box.get(_userKey);
      if (userJson == null) return null;

      return UserModel.fromJson(Map<String, dynamic>.from(userJson as Map));
    } catch (e) {
      throw CacheFailure('فشل استرجاع بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _box.delete(_userKey);
    } catch (e) {
      throw CacheFailure('فشل حذف بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  bool get hasUser => _box.containsKey(_userKey);
}
