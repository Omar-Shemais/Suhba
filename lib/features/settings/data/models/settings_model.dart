import 'package:equatable/equatable.dart';

enum ThemeMode {
  light,
  dark,
  system,
}

class SettingsModel extends Equatable {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String languageCode;

  const SettingsModel({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.languageCode = 'ar',
  });

  SettingsModel copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? languageCode,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'notificationsEnabled': notificationsEnabled,
      'languageCode': languageCode,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      languageCode: json['languageCode'] ?? 'ar',
    );
  }

  @override
  List<Object?> get props => [themeMode, notificationsEnabled, languageCode];
}
