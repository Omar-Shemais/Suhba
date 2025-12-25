import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/mushaf_repo.dart';
import '../../data/helpers/mushaf_storage_helper.dart';
import '../cubit/mushaf_state.dart';

class MushafCubit extends Cubit<MushafState> {
  final MushafRepository repository;

  MushafCubit(this.repository) : super(MushafInitial());

  // ✅ تحميل المصحف مع استرجاع آخر صفحة
  Future<void> loadMushaf() async {
    try {
      emit(MushafLoading());

      final verses = await repository.loadFullQuran();
      final pages = repository.paginateVerses(verses);

      // استرجاع آخر صفحة محفوظة
      final lastPage = await MushafStorageHelper.getLastPage();

      // التأكد من أن الصفحة في النطاق الصحيح
      final validPage = lastPage < pages.length ? lastPage : 0;

      emit(MushafLoaded(pages, currentPage: validPage));
    } catch (e) {
      emit(MushafError(e.toString()));
    }
  }

  // ✅ الانتقال لصفحة مع الحفظ
  void goToPage(int pageNumber) {
    if (state is MushafLoaded) {
      final currentState = state as MushafLoaded;

      // حفظ الصفحة الحالية
      MushafStorageHelper.saveLastPage(pageNumber);

      emit(MushafLoaded(currentState.pages, currentPage: pageNumber));
    }
  }

  // ✅ الانتقال لسورة معينة
  void jumpToSurah(int surahId) {
    if (state is MushafLoaded) {
      final currentState = state as MushafLoaded;

      for (int i = 0; i < currentState.pages.length; i++) {
        final page = currentState.pages[i];
        if (page.verses.any(
          (verse) => verse.surahId == surahId && verse.isNewSurah,
        )) {
          // حفظ الصفحة عند الانتقال
          MushafStorageHelper.saveLastPage(i);
          emit(MushafLoaded(currentState.pages, currentPage: i));
          return;
        }
      }
    }
  }

  // ✅ وضع/إزالة العلامة المرجعية (واحدة فقط)
  Future<void> toggleBookmark(int pageNumber) async {
    final isBookmarked = await MushafStorageHelper.isBookmarked(pageNumber);

    if (isBookmarked) {
      // إزالة العلامة
      await MushafStorageHelper.removeBookmark();
    } else {
      // وضع علامة جديدة (وحذف القديمة تلقائياً)
      await MushafStorageHelper.setBookmark(pageNumber);
    }

    // تحديث الواجهة
    if (state is MushafLoaded) {
      final currentState = state as MushafLoaded;
      emit(
        MushafLoaded(currentState.pages, currentPage: currentState.currentPage),
      );
    }
  }

  // ✅ الحصول على العلامة المرجعية
  Future<int?> getBookmark() async {
    return await MushafStorageHelper.getBookmark();
  }

  // ✅ التحقق من وجود علامة مرجعية
  Future<bool> isPageBookmarked(int pageNumber) async {
    return await MushafStorageHelper.isBookmarked(pageNumber);
  }

  // ✅ الانتقال للعلامة المرجعية
  Future<void> goToBookmark() async {
    final bookmark = await MushafStorageHelper.getBookmark();
    if (bookmark != null && state is MushafLoaded) {
      final currentState = state as MushafLoaded;
      if (bookmark < currentState.pages.length) {
        goToPage(bookmark);
      }
    }
  }
}
