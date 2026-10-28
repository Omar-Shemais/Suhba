abstract class QiblaState {}

class QiblaInitial extends QiblaState {}

class QiblaLoading extends QiblaState {}

class QiblaSuccess extends QiblaState {
  final double angle;
  final double latitude;
  final double longitude;

  QiblaSuccess({
    required this.angle,
    required this.latitude,
    required this.longitude,
  });
}

class QiblaFailure extends QiblaState {
  final String message;
  QiblaFailure(this.message);
}
