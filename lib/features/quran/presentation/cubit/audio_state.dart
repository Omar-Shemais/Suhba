import 'package:equatable/equatable.dart';

abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {
  final int? targetSurahId;
  final int? targetAyahNumber;
  final String? targetRadioUrl;

  const AudioLoading({
    this.targetSurahId,
    this.targetAyahNumber,
    this.targetRadioUrl,
  });

  @override
  List<Object?> get props => [targetSurahId, targetAyahNumber, targetRadioUrl];
}

class AudioPlaying extends AudioState {
  final Duration currentPosition;
  final Duration totalDuration;
  final int? currentSurahId;

  const AudioPlaying({
    required this.currentPosition,
    required this.totalDuration,
    this.currentSurahId,
  });

  @override
  List<Object?> get props => [
    currentPosition.inSeconds,
    totalDuration,
    currentSurahId,
  ];
}

class AudioPlayingAyah extends AudioState {
  final Duration currentPosition;
  final Duration totalDuration;
  final int? currentSurahId;
  final int? currentAyahNumber;

  const AudioPlayingAyah({
    required this.currentPosition,
    required this.totalDuration,
    this.currentSurahId,
    this.currentAyahNumber,
  });

  @override
  List<Object?> get props => [
    currentPosition.inSeconds,
    totalDuration,
    currentSurahId,
    currentAyahNumber,
  ];
}

class AudioPaused extends AudioState {
  final Duration currentPosition;
  final Duration totalDuration;
  final int? currentSurahId;
  final int? currentAyahNumber;

  const AudioPaused({
    required this.currentPosition,
    required this.totalDuration,
    this.currentSurahId,
    this.currentAyahNumber,
  });

  @override
  List<Object?> get props => [
    currentPosition,
    totalDuration,
    currentSurahId,
    currentAyahNumber,
  ];
}

class AudioCompleted extends AudioState {
  final int? currentSurahId;
  final int? currentAyahNumber;

  const AudioCompleted({this.currentSurahId, this.currentAyahNumber});

  @override
  List<Object?> get props => [currentSurahId, currentAyahNumber];
}

// ✅ Error
class AudioError extends AudioState {
  final String message;
  final int? targetSurahId;
  final int? targetAyahNumber;
  final String? targetRadioUrl;

  const AudioError({
    required this.message,
    this.targetSurahId,
    this.targetAyahNumber,
    this.targetRadioUrl,
  });

  @override
  List<Object?> get props => [
    message,
    targetSurahId,
    targetAyahNumber,
    targetRadioUrl,
  ];
}

class AudioPlayingRadio extends AudioState {
  final String url;

  const AudioPlayingRadio({required this.url});

  @override
  List<Object?> get props => [url];
}
