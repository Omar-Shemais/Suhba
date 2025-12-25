part of 'prayer_cubit.dart';

abstract class PrayerState {}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final PrayerTimesModel prayerTimes;
  final List<PrayerInfo> prayers;
  final PrayerInfo? nextPrayer;
  final String city;
  final String country;

  PrayerLoaded({
    required this.prayerTimes,
    required this.prayers,
    this.nextPrayer,
    required this.city,
    required this.country,
  });

  // نسخة جديدة من الـ state مع تحديث بعض البيانات
  PrayerLoaded copyWith({
    PrayerTimesModel? prayerTimes,
    List<PrayerInfo>? prayers,
    PrayerInfo? nextPrayer,
    String? city,
    String? country,
  }) {
    return PrayerLoaded(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      prayers: prayers ?? this.prayers,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}

// State خاص بالـ Error مع الاحتفاظ بآخر بيانات صحيحة
class PrayerError extends PrayerState {
  final String message;
  final PrayerLoaded? lastSuccessfulState;

  PrayerError(this.message, {this.lastSuccessfulState});
}

// State خاص بعملية Refresh (مع عرض البيانات الحالية)
class PrayerRefreshing extends PrayerState {
  final PrayerLoaded currentData;

  PrayerRefreshing(this.currentData);
}

// State خاص بتحديث الموقع (مع عرض البيانات الحالية)
class PrayerLocationLoading extends PrayerState {
  final PrayerLoaded currentData;

  PrayerLocationLoading(this.currentData);
}
