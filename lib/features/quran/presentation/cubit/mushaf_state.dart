import '../../data/models/mushaf_models.dart';

abstract class MushafState {}

class MushafInitial extends MushafState {}

class MushafLoading extends MushafState {}

class MushafLoaded extends MushafState {
  final List<MushafPage> pages;
  final int currentPage;

  MushafLoaded(this.pages, {this.currentPage = 0});
}

class MushafError extends MushafState {
  final String message;

  MushafError(this.message);
}
