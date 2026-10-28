import 'package:hive_flutter/hive_flutter.dart';

class CacheHelper {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box> openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  static Future<void> saveData<T>({
    required String boxName,
    required String key,
    required T value,
  }) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  static Future<T?> getData<T>({
    required String boxName,
    required String key,
  }) async {
    final box = await openBox(boxName);
    final value = box.get(key);
    if (value == null) return null;
    return value as T?;
  }

  static bool isBoxOpen(String boxName) => Hive.isBoxOpen(boxName);

  static Box? getBox(String boxName) {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return null;
  }

  static T? getDataSync<T>({
    required String boxName,
    required String key,
  }) {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      final value = box.get(key);
      if (value == null) return null;
      return value as T?;
    }
    return null;
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
