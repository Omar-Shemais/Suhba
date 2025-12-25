import '../../data/models/azkar_model.dart';

abstract class AzkarState {}

class AzkarInitial extends AzkarState {}

class AzkarLoading extends AzkarState {}

// ⬇️ أذكار الصباح
class MorningAzkarSuccess extends AzkarState {
  final AzkarModel azkarModel;
  MorningAzkarSuccess(this.azkarModel);
}

// ⬇️ أذكار المساء
class EveningAzkarSuccess extends AzkarState {
  final AzkarModel azkarModel;
  EveningAzkarSuccess(this.azkarModel);
}

// ⬇️ أذكار بعد الصلاة
class AfterPrayerAzkarSuccess extends AzkarState {
  final AzkarModel azkarModel;
  AfterPrayerAzkarSuccess(this.azkarModel);
}

class AzkarError extends AzkarState {
  final String message;
  AzkarError(this.message);
}
