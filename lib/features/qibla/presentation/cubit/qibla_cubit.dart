import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/qibla_repo.dart';
import 'qibla_states.dart';

class QiblaCubit extends Cubit<QiblaState> {
  final QiblaRepository qiblaRepo;

  QiblaCubit(this.qiblaRepo) : super(QiblaInitial());

  Future<void> getQibla() async {
    emit(QiblaLoading());

    final result = await qiblaRepo.getQiblaAngle();

    result.fold(
      (failure) => emit(QiblaFailure(failure.message)),
      (angle) => emit(QiblaSuccess(angle)),
    );
  }
}
