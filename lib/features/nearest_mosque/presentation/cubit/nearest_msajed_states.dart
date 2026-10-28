import 'package:geolocator/geolocator.dart';
import '../../data/models/masjed_model.dart';

abstract class NearestMasjedState {}

class NearestMasjedInitialState extends NearestMasjedState {}

class NearestMasjedLoadingState extends NearestMasjedState {}

class NearestMasjedSuccessState extends NearestMasjedState {
  final Position position;
  final List<MasjedModel> masjeds;

  NearestMasjedSuccessState({required this.position, required this.masjeds});
}

class NearestMasjedErrorState extends NearestMasjedState {
  final String message;

  NearestMasjedErrorState(this.message);
}
