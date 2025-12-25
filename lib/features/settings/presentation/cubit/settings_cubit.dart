import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/models/settings_model.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    final result = await _repository.getSettings();
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      emit(SettingsLoaded(updatedSettings));

      final result = await _repository.updateThemeMode(themeMode);
      result.fold(
        (failure) {
          // Revert on error
          emit(SettingsLoaded(currentSettings));
          emit(SettingsError(failure.message));
        },
        (_) {},
      );
    }
  }

  Future<void> updateNotifications(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final updatedSettings =
          currentSettings.copyWith(notificationsEnabled: enabled);
      emit(SettingsLoaded(updatedSettings));

      final result = await _repository.updateNotifications(enabled);
      result.fold(
        (failure) {
          // Revert on error
          emit(SettingsLoaded(currentSettings));
          emit(SettingsError(failure.message));
        },
        (_) {},
      );
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final updatedSettings =
          currentSettings.copyWith(languageCode: languageCode);
      emit(SettingsLoaded(updatedSettings));

      final result = await _repository.updateLanguage(languageCode);
      result.fold(
        (failure) {
          // Revert on error
          emit(SettingsLoaded(currentSettings));
          emit(SettingsError(failure.message));
        },
        (_) {},
      );
    }
  }
}
