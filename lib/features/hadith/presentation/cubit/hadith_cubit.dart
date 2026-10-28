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
      if (isClosed) return;
      currentBook = book;
      currentPage = 1;
      allHadiths.clear();

      // 1. عرض الأحاديث المخزنة محلياً فوراً لمنع شاشة التحميل اللانهائية
      final cached = repository.getCachedHadiths(book: book);
      if (cached.isNotEmpty) {
        allHadiths.addAll(cached);
        emit(
          HadithLoaded(
            hadiths: List.from(allHadiths),
            total: allHadiths.length,
            currentPage: 1,
            hasMore: false,
          ),
        );
      } else {
        emit(HadithLoading());
      }
    }

    try {
      currentBook = book;
      final response = await repository.getHadiths(
        book: book,
        page: currentPage,
        limit: 20,
      );

      if (!loadMore) {
        allHadiths.clear();
      }

      final existingIds = allHadiths.map((h) => h.id).toSet();
      for (final h in response.hadiths) {
        if (!existingIds.contains(h.id)) {
          allHadiths.add(h);
        }
      }

      final hasMore = allHadiths.length < response.total;

      if (isClosed) return;
      emit(
        HadithLoaded(
          hadiths: List.from(allHadiths),
          total: response.total > allHadiths.length ? response.total : allHadiths.length,
          currentPage: currentPage,
          hasMore: hasMore,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      // إذا كانت الأحاديث معروضة بالفعل من الكاش، نبقي عليها ولا نظهر شاشة الخطأ
      if (allHadiths.isEmpty) {
        emit(HadithError(e.toString()));
      }
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
