import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/sibha_repository.dart';
import 'sibha_state.dart';

class SibhaCubit extends Cubit<SibhaState> {
  SibhaCubit(this.sibhaRepository) : super(SibhaInitial());
  final SibhaRepository sibhaRepository;

  void getSibhaData() {
    emit(SibhaLoading());
    final data = sibhaRepository.getSibhaData();
    data.fold(
      (failure) {
        emit(SibhaError(failure.message));
      },
      (sibha) {
        emit(SibhaLoaded(sibha));
      },
    );
  }
}
