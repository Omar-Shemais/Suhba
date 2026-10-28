import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, SettingsModel>> getSettings() async {
    try {
      final settings = await _localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(SettingsModel settings) async {
    try {
      await _localDataSource.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateThemeMode(ThemeMode themeMode) async {
    try {
      final currentSettings = await _localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      await _localDataSource.saveSettings(updatedSettings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotifications(bool enabled) async {
    try {
      final currentSettings = await _localDataSource.getSettings();
      final updatedSettings =
          currentSettings.copyWith(notificationsEnabled: enabled);
      await _localDataSource.saveSettings(updatedSettings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String languageCode) async {
    try {
      final currentSettings = await _localDataSource.getSettings();
      final updatedSettings =
          currentSettings.copyWith(languageCode: languageCode);
      await _localDataSource.saveSettings(updatedSettings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
