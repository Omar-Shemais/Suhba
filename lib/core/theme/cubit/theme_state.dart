import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Theme State - represents the current theme mode
abstract class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Initial Theme State
class ThemeInitial extends ThemeState {
  const ThemeInitial() : super(ThemeMode.system);
}

/// Theme Loaded State
class ThemeLoaded extends ThemeState {
  const ThemeLoaded(super.themeMode);
}

/// Theme Loading State
class ThemeLoading extends ThemeState {
  const ThemeLoading(super.themeMode);
}
