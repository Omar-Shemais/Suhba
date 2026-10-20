abstract class CountAndRoundState {}

class CountAndRoundInitial extends CountAndRoundState {}

class SibhaLoadedStateWithUpdate extends CountAndRoundState {
  final int count;
  final int round;
  final int counter; // أضف الحقل هنا

  SibhaLoadedStateWithUpdate(
    this.count,
    this.round, {
    required this.counter,
  });
}
