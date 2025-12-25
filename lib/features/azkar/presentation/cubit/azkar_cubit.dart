import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/azkar_repo.dart';
import 'azkar_states.dart';

class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit() : super(AzkarInitial());

  Future<void> getMorningAzkar() async {
    emit(AzkarLoading());
    final result = await AzkarRepo.getMorningAzkar();

    result.fold(
      (error) => emit(AzkarError(error)),
      (data) => emit(MorningAzkarSuccess(data)),
    );
  }

  Future<void> getEveningAzkar() async {
    emit(AzkarLoading());
    final result = await AzkarRepo.getEveningAzkar();

    result.fold(
      (error) => emit(AzkarError(error)),
      (data) => emit(EveningAzkarSuccess(data)),
    );
  }

  Future<void> getAfterPrayerAzkar() async {
    emit(AzkarLoading());
    final result = await AzkarRepo.getAfterPrayerAzkar();

    result.fold(
      (error) => emit(AzkarError(error)),
      (data) => emit(AfterPrayerAzkarSuccess(data)),
    );
  }
}
