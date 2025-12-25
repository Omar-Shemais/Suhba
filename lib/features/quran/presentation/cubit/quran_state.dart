import 'package:equatable/equatable.dart';
import '../../data/models/quran_models.dart';

abstract class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<SurahModel> surahs;

  const QuranLoaded(this.surahs);

  @override
  List<Object?> get props => [surahs];
}

class QuranError extends QuranState {
  final String message;

  const QuranError(this.message);

  @override
  List<Object?> get props => [message];
}

class SurahDetailLoaded extends QuranState {
  final SurahModel surah;

  const SurahDetailLoaded(this.surah);

  @override
  List<Object?> get props => [surah];
}
