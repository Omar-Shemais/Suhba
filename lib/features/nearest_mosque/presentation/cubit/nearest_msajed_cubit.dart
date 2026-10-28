import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/nearest_msajed_states.dart';
import '../../data/repositories/nearest_msajed_repo.dart';

class NearestMasjedCubit extends Cubit<NearestMasjedState> {
  final NearestMsajedRepo nearestMsajedRepo;

  NearestMasjedCubit(this.nearestMsajedRepo)
    : super(NearestMasjedInitialState());

  Future<void> getNearestMasjeds() async {
    emit(NearestMasjedLoadingState());

    final positionResult = await nearestMsajedRepo.getUserCurrentPosition();

    await positionResult.fold(
      (failure) async {
        emit(NearestMasjedErrorState(failure.message));
      },
      (position) async {
        final masjedsResult = await nearestMsajedRepo.getNearestMasjeds(
          position,
        );

        masjedsResult.fold(
          (failure) {
            emit(NearestMasjedErrorState(failure.message));
          },
          (masjeds) {
            emit(
              NearestMasjedSuccessState(position: position, masjeds: masjeds),
            );
          },
        );
      },
    );
  }
}
