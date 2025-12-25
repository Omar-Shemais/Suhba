import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/quran_models.dart';
import '../../data/repositories/quran_repo.dart';
import '../cubit/quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final QuranRepository repository;
  List<SurahModel>? _allSurahs;

  QuranCubit(this.repository) : super(QuranInitial());

  Future<void> loadSurahs() async {
    try {
      if (isClosed) return;
      emit(QuranLoading());

      final surahs = await repository.getAllSurahs();

      if (isClosed) return;
      _allSurahs = surahs;
      emit(QuranLoaded(surahs));
    } catch (e) {
      if (isClosed) return;
      emit(QuranError(e.toString()));
    }
  }

  Future<void> loadSurahById(int id) async {
    try {
      if (isClosed) return;
      emit(QuranLoading());

      final surah = await repository.getSurahById(id);

      if (isClosed) return;
      emit(SurahDetailLoaded(surah));
    } catch (e) {
      if (isClosed) return;
      emit(QuranError(e.toString()));
    }
  }

  void filterByType(String type) {
    if (_allSurahs == null) {
      loadSurahs();
      return;
    }

    if (isClosed) return;
    emit(QuranLoading());

    final filtered = _allSurahs!
        .where((surah) => surah.type.toLowerCase() == type.toLowerCase())
        .toList();

    if (isClosed) return;
    emit(QuranLoaded(filtered));
  }

  Future<void> searchSurahs(String query) async {
    try {
      if (isClosed) return;
      emit(QuranLoading());

      final surahs = await repository.searchSurahs(query);

      if (isClosed) return;
      emit(QuranLoaded(surahs));
    } catch (e) {
      if (isClosed) return;
      emit(QuranError(e.toString()));
    }
  }
}
