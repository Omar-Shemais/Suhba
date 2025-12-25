import 'package:hive_flutter/hive_flutter.dart';

class CacheHelper {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box<T>> openBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  static Future<void> saveData<T>({
    required String boxName,
    required String key,
    required T value,
  }) async {
    final box = await openBox<T>(boxName);
    await box.put(key, value);
  }

  static Future<T?> getData<T>({
    required String boxName,
    required String key,
  }) async {
    final box = await openBox<T>(boxName);
    return box.get(key);
  }

  static Future<void> removeData({
    required String boxName,
    required String key,
  }) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  static Future<void> clearBox(String boxName) async {
    final box = await openBox(boxName);
    await box.clear();
  }
}
