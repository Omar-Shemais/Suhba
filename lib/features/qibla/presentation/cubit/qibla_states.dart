abstract class QiblaState {}

class QiblaInitial extends QiblaState {}

class QiblaLoading extends QiblaState {}

class QiblaSuccess extends QiblaState {
  final double angle;
  QiblaSuccess(this.angle);
}

class QiblaFailure extends QiblaState {
  final String message;
  QiblaFailure(this.message);
}
