import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/settings_model.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsModel>> getSettings();
  Future<Either<Failure, void>> saveSettings(SettingsModel settings);
  Future<Either<Failure, void>> updateThemeMode(ThemeMode themeMode);
  Future<Either<Failure, void>> updateNotifications(bool enabled);
  Future<Either<Failure, void>> updateLanguage(String languageCode);
}
