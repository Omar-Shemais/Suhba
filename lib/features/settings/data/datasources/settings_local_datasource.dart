import '../../../../core/utils/cache_helper.dart';
import '../../../../core/constants/storage_constants.dart';
import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
  Future<void> clearSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _settingsKey = 'app_settings';

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final data = await CacheHelper.getData<Map>(
        boxName: StorageConstants.settingsBoxName,
        key: _settingsKey,
      );
      
      if (data != null) {
        return SettingsModel.fromJson(Map<String, dynamic>.from(data));
      }
      
      // Return default settings if no data found
      return const SettingsModel();
    } catch (e) {
      return const SettingsModel();
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    await CacheHelper.saveData(
      boxName: StorageConstants.settingsBoxName,
      key: _settingsKey,
      value: settings.toJson(),
    );
  }

  @override
  Future<void> clearSettings() async {
    await CacheHelper.removeData(
      boxName: StorageConstants.settingsBoxName,
      key: _settingsKey,
    );
  }
}
