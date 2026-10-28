import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/constants/storage_constants.dart';

abstract class AuthLocalDataSource {
  /// Cache user data in Hive and SharedPreferences
  Future<void> cacheUser(UserModel user);

  /// Get cached user from Hive or SharedPreferences
  UserModel? getCachedUser();

  /// Clear cached user (for logout)
  Future<void> clearUser();

  /// Check if user is cached
  bool get hasUser;
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box? _boxInstance;
  final SharedPreferences? _prefs;
  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl({Box? box, SharedPreferences? prefs})
      : _boxInstance = box,
        _prefs = prefs;

  Box? _getBox() {
    if (_boxInstance != null && _boxInstance.isOpen) {
      return _boxInstance;
    }
    if (Hive.isBoxOpen(StorageConstants.userBoxName)) {
      return Hive.box(StorageConstants.userBoxName);
    }
    return null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userMap = user.toJson();
      final userJsonString = jsonEncode(userMap);

      // 1. Save to SharedPreferences (reliable across device reboots)
      try {
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.setString(_userKey, userJsonString);
        debugPrint('✅ [AuthLocal] User saved to SharedPreferences');
      } catch (e) {
        debugPrint('⚠️ [AuthLocal] Failed saving to SharedPreferences: $e');
      }

      // 2. Save to Hive
      try {
        final box = _getBox();
        if (box != null) {
          await box.put(_userKey, userMap);
          debugPrint('✅ [AuthLocal] User saved to Hive');
        } else {
          debugPrint('⚠️ [AuthLocal] Hive box not open, saved to SharedPreferences only');
        }
      } catch (e) {
        debugPrint('⚠️ [AuthLocal] Failed saving to Hive: $e');
      }
    } catch (e) {
      throw CacheFailure('فشل حفظ بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  UserModel? getCachedUser() {
    try {
      // 1. Try Hive first
      try {
        final box = _getBox();
        if (box != null) {
          final userJson = box.get(_userKey);
          if (userJson != null) {
            debugPrint('🔍 [AuthLocal] User retrieved from Hive');
            return UserModel.fromJson(Map<String, dynamic>.from(userJson as Map));
          }
        }
      } catch (e) {
        debugPrint('⚠️ [AuthLocal] Error reading from Hive: $e');
      }

      // 2. Fallback to SharedPreferences
      try {
        final prefs = _prefs;
        if (prefs != null) {
          final userString = prefs.getString(_userKey);
          if (userString != null && userString.isNotEmpty) {
            final userMap = jsonDecode(userString) as Map<String, dynamic>;
            debugPrint('🔍 [AuthLocal] User retrieved from SharedPreferences fallback');
            final user = UserModel.fromJson(userMap);
            // Re-cache to Hive if open
            final box = _getBox();
            if (box != null) {
              box.put(_userKey, user.toJson());
            }
            return user;
          }
        } else {
          // If prefs wasn't injected yet, try synchronous or async
          SharedPreferences.getInstance().then((p) {
            final userString = p.getString(_userKey);
            if (userString != null && userString.isNotEmpty) {
              final box = _getBox();
              if (box != null && !box.containsKey(_userKey)) {
                final userMap = jsonDecode(userString) as Map<String, dynamic>;
                box.put(_userKey, userMap);
              }
            }
          }).catchError((_) {});
        }
      } catch (e) {
        debugPrint('⚠️ [AuthLocal] Error reading from SharedPreferences: $e');
      }

      return null;
    } catch (e) {
      debugPrint('⚠️ [AuthLocal] Failed to retrieve cached user: $e');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      // Clear from SharedPreferences
      try {
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.remove(_userKey);
        debugPrint('🗑️ [AuthLocal] Cleared user from SharedPreferences');
      } catch (e) {
        debugPrint('⚠️ [AuthLocal] Failed to clear SharedPreferences: $e');
      }

      // Clear from Hive
      try {
        final box = _getBox();
        if (box != null) {
          await box.delete(_userKey);
          debugPrint('🗑️ [AuthLocal] Cleared user from Hive');
        }
      } catch (e) {
        debugPrint('⚠️ [AuthLocal] Failed to clear Hive: $e');
      }
    } catch (e) {
      throw CacheFailure('فشل حذف بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  bool get hasUser {
    try {
      final box = _getBox();
      if (box != null && box.containsKey(_userKey)) {
        return true;
      }
      if (_prefs != null && _prefs.containsKey(_userKey)) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}
