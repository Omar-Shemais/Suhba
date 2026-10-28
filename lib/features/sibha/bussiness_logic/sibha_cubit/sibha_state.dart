import '../../data/model/sibha_model.dart';

abstract class SibhaState {}

class SibhaInitial extends SibhaState {}

class SibhaLoading extends SibhaState {}

class SibhaLoaded extends SibhaState {
  final List<SibhaModel> sibhas;
  SibhaLoaded(this.sibhas);
}

class SibhaError extends SibhaState {
  final String message;
  SibhaError(this.message);
}
