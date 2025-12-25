import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/hadith_model.dart';
import '../../data/repositories/hadith_repository.dart';
import '../cubit/hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  final HadithRepository repository;
  String currentBook = 'all';
  int currentPage = 1;
  List<HadithModel> allHadiths = [];

  HadithCubit(this.repository) : super(HadithInitial());

  Future<void> loadHadiths({String book = 'all', bool loadMore = false}) async {
    if (!loadMore) {
      if (isClosed) return; // نتأكد من Cubit مفتوح
      emit(HadithLoading());
      currentPage = 1;
      allHadiths.clear();
    }

    try {
      currentBook = book;
      final response = await repository.getHadiths(
        book: book,
        page: currentPage,
        limit: 20,
      );

      allHadiths.addAll(response.hadiths);
      final hasMore = allHadiths.length < response.total;

      if (isClosed) return;
      emit(
        HadithLoaded(
          hadiths: List.from(allHadiths),
          total: response.total,
          currentPage: currentPage,
          hasMore: hasMore,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(HadithError(e.toString()));
    }
  }

  Future<void> loadMoreHadiths() async {
    if (state is HadithLoaded) {
      final currentState = state as HadithLoaded;
      if (currentState.hasMore) {
        currentPage++;
        await loadHadiths(book: currentBook, loadMore: true);
      }
    }
  }
}
