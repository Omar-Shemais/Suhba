import '../../data/models/hadith_model.dart';

abstract class HadithState {}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithLoaded extends HadithState {
  final List<HadithModel> hadiths;
  final int total;
  final int currentPage;
  final bool hasMore;

  HadithLoaded({
    required this.hadiths,
    required this.total,
    required this.currentPage,
    required this.hasMore,
  });
}

class HadithError extends HadithState {
  final String message;
  HadithError(this.message);
}
