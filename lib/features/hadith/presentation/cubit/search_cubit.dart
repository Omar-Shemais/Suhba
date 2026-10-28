import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/hadith_repository.dart';
import '../cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final HadithRepository repository;

  SearchCubit(this.repository) : super(SearchInitial());

  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final isArabic = _isArabic(query);

      final results = await repository.searchHadiths(
        arabicQuery: isArabic ? query : null,
        englishQuery: !isArabic ? query : null,
      );

      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> searchByLanguage({
    String? arabicQuery,
    String? englishQuery,
  }) async {
    if ((arabicQuery == null || arabicQuery.isEmpty) &&
        (englishQuery == null || englishQuery.isEmpty)) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final results = await repository.searchHadiths(
        arabicQuery: arabicQuery,
        englishQuery: englishQuery,
      );

      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void clear() {
    emit(SearchInitial());
  }
}
