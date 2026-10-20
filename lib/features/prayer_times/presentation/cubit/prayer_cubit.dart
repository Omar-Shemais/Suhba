import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/prayer_times_model.dart';
import '../../data/repositories/prayer_repository.dart';
import 'package:islamic_app/core/services/location_service.dart';
import 'package:islamic_app/core/services/azan_notification_service.dart';
import 'package:islamic_app/features/azkar/services/azkar_notification_service.dart';

part 'prayer_state.dart';

class PrayerCubit extends Cubit<PrayerState> {
  final PrayerRepository repository;
  final LocationService locationService = LocationService();
  final AzanNotificationService notificationService = AzanNotificationService();

  Timer? _updateTimer;
  Timer? _countdownTimer;
  String _currentCity = 'Mansoura';
  String _currentCountry = 'Egypt';
  double? _currentLatitude;
  double? _currentLongitude;

  PrayerLoaded? _lastSuccessfulState;

  PrayerCubit(this.repository) : super(PrayerInitial()) {
    _initializeServices();
  }

  /// تهيئة الخدمات
  Future<void> _initializeServices() async {
    try {
      debugPrint('🚀 بدء تهيئة خدمات الصلاة...');

      // ✅ تهيئة خدمة الإشعارات
      await notificationService.initialize();
      debugPrint('✅ تم تهيئة خدمة الإشعارات');

      // ✅ جلب مواقيت الصلاة
      await loadPrayerTimes();

      // ✅ بدء المؤقتات
      _startAutoUpdateTimer();
      _startCountdownTimer();

      debugPrint('✅ تم تهيئة جميع الخدمات بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة الخدمات: $e');
      emit(PrayerError('فشل تهيئة الخدمات. حاول مرة أخرى.'));
    }
  }

  /// بدء العداد التنازلي (كل ثانية)
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is PrayerLoaded) {
        final currentState = state as PrayerLoaded;
        emit(
          PrayerLoaded(
            prayerTimes: currentState.prayerTimes,
            prayers: _getPrayerList(currentState.prayerTimes),
            nextPrayer: currentState.nextPrayer,
            city: _currentCity,
            country: _currentCountry,
          ),
        );
      } else if (state is PrayerRefreshing) {
        final refreshState = state as PrayerRefreshing;
        emit(
          PrayerRefreshing(
            PrayerLoaded(
              prayerTimes: refreshState.currentData.prayerTimes,
              prayers: _getPrayerList(refreshState.currentData.prayerTimes),
              nextPrayer: refreshState.currentData.nextPrayer,
              city: _currentCity,
              country: _currentCountry,
            ),
          ),
        );
      } else if (state is PrayerLocationLoading) {
        final locationState = state as PrayerLocationLoading;
        emit(
          PrayerLocationLoading(
            PrayerLoaded(
              prayerTimes: locationState.currentData.prayerTimes,
              prayers: _getPrayerList(locationState.currentData.prayerTimes),
              nextPrayer: locationState.currentData.nextPrayer,
              city: _currentCity,
              country: _currentCountry,
            ),
          ),
        );
      }
    });
  }

  /// بدء التحديث التلقائي
  void _startAutoUpdateTimer() {
    _updateTimer?.cancel();

    // ✅ فحص كل ساعة
    _updateTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await _checkAndUpdateIfNeeded();
    });

    // ✅ فحص الموقع كل 12 ساعة
    Timer.periodic(const Duration(hours: 12), (timer) async {
      await _checkAndUpdateLocation();
    });
  }

  /// التحقق من الحاجة للتحديث
  Future<void> _checkAndUpdateIfNeeded() async {
    try {
      final shouldUpdate = await repository.shouldUpdatePrayerTimes();
      if (shouldUpdate) {
        debugPrint('🔄 حان وقت تحديث مواقيت الصلاة...');
        await loadPrayerTimes(silentUpdate: true);
      }
    } catch (e) {
      debugPrint('❌ خطأ في فحص التحديث: $e');
    }
  }

  /// التحقق من الحاجة لتحديث الموقع
  Future<void> _checkAndUpdateLocation() async {
    try {
      final shouldUpdate = await locationService.shouldUpdateLocation();
      if (shouldUpdate) {
        debugPrint('🔄 حان وقت تحديث الموقع...');
        await refreshLocation();
      }
    } catch (e) {
      debugPrint('❌ خطأ في فحص الموقع: $e');
    }
  }

  /// تحديث الموقع
  Future<void> refreshLocation() async {
    if (_lastSuccessfulState != null) {
      emit(PrayerLocationLoading(_lastSuccessfulState!));
    } else {
      emit(PrayerLoading());
    }

    try {
      debugPrint('📍 جلب الموقع الحالي...');

      final location = await locationService.getCurrentLocation();

      if (location != null) {
        _currentCity = location['city']!;
        _currentCountry = location['country']!;
        _currentLatitude = location['latitude'];
        _currentLongitude = location['longitude'];

        debugPrint('✅ تم الحصول على الموقع: $_currentCity, $_currentCountry');

        await loadPrayerTimes(
          latitude: _currentLatitude,
          longitude: _currentLongitude,
        );
      } else {
        final savedLocation = await locationService.getSavedLocation();
        if (savedLocation != null) {
          _currentCity = savedLocation['city']!;
          _currentCountry = savedLocation['country']!;
          _currentLatitude = savedLocation['latitude'];
          _currentLongitude = savedLocation['longitude'];

          debugPrint('✅ استخدام موقع محفوظ: $_currentCity');
        }

        await loadPrayerTimes(
          latitude: _currentLatitude,
          longitude: _currentLongitude,
        );
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحديث الموقع: $e');
      if (_lastSuccessfulState != null) {
        emit(_lastSuccessfulState!);
      } else {
        emit(PrayerError('فشل تحديث الموقع. تأكد من الاتصال بالإنترنت.'));
      }
    }
  }

  /// جلب مواقيت الصلاة
  Future<void> loadPrayerTimes({
    double? latitude,
    double? longitude,
    bool silentUpdate = false,
  }) async {
    try {
      if (!silentUpdate) {
        emit(PrayerLoading());
      }

      debugPrint('📖 جلب مواقيت الصلاة...');

      // ✅ جلب الموقع إذا لم يكن موجوداً
      if (latitude == null || longitude == null) {
        final savedLocation = await locationService.getSavedLocation();
        if (savedLocation != null) {
          _currentCity = savedLocation['city'];
          _currentCountry = savedLocation['country'];
          latitude = savedLocation['latitude'];
          longitude = savedLocation['longitude'];
          debugPrint('📍 استخدام موقع محفوظ: $_currentCity');
        } else {
          final currentLocation = await locationService.getCurrentLocation();
          if (currentLocation != null) {
            _currentCity = currentLocation['city'];
            _currentCountry = currentLocation['country'];
            latitude = currentLocation['latitude'];
            longitude = currentLocation['longitude'];
            debugPrint('📍 استخدام موقع حالي: $_currentCity');
          } else {
            // Default للمنصورة
            _currentCity = 'Mansoura';
            _currentCountry = 'Egypt';
            latitude = 31.0409;
            longitude = 31.3785;
            debugPrint('📍 استخدام موقع افتراضي: $_currentCity');
          }
        }
      }

      _currentLatitude = latitude;
      _currentLongitude = longitude;

      // ✅ جلب من Cache أولاً
      final cached = await repository.getCachedPrayerTimes();
      if (cached != null && cached.isValidForToday()) {
        debugPrint('💾 استخدام بيانات محفوظة');

        final prayerList = _getPrayerList(cached);
        final loadedState = PrayerLoaded(
          prayerTimes: cached,
          prayers: prayerList,
          nextPrayer: _getNextPrayer(prayerList),
          city: _currentCity,
          country: _currentCountry,
        );

        _lastSuccessfulState = loadedState;
        emit(loadedState);

        // ✅ جدولة الإشعارات
        await _schedulePrayerNotifications(cached);
        return;
      }

      // ✅ جلب من API
      debugPrint('🌐 جلب من API...');
      final result = await repository.getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
      );

      result.fold(
        (error) {
          debugPrint('❌ خطأ في جلب البيانات: $error');
          if (_lastSuccessfulState != null) {
            emit(
              PrayerError(
                'لا يوجد اتصال بالإنترنت',
                lastSuccessfulState: _lastSuccessfulState,
              ),
            );
          } else {
            emit(PrayerError('لا يوجد اتصال بالإنترنت. حاول مرة أخرى.'));
          }
        },
        (prayerTimes) async {
          debugPrint('✅ تم جلب مواقيت الصلاة بنجاح');

          final prayerList = _getPrayerList(prayerTimes);
          final loadedState = PrayerLoaded(
            prayerTimes: prayerTimes,
            prayers: prayerList,
            nextPrayer: _getNextPrayer(prayerList),
            city: _currentCity,
            country: _currentCountry,
          );

          _lastSuccessfulState = loadedState;
          emit(loadedState);

          // ✅ جدولة الإشعارات
          await _schedulePrayerNotifications(prayerTimes);
        },
      );
    } catch (e) {
      debugPrint('❌ خطأ غير متوقع: $e');
      if (_lastSuccessfulState != null) {
        emit(_lastSuccessfulState!);
      } else {
        emit(PrayerError('حدث خطأ. حاول مرة أخرى.'));
      }
    }
  }

  /// جدولة إشعارات الصلاة
  Future<void> _schedulePrayerNotifications(PrayerTimesModel model) async {
    try {
      debugPrint('🔔 بدء جدولة إشعارات الصلاة...');

      final times = {
        'fajr': model.fajr,
        'dhuhr': model.dhuhr,
        'asr': model.asr,
        'maghrib': model.maghrib,
        'isha': model.isha,
      };

      debugPrint('🕐 أوقات الصلاة:');
      times.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      await notificationService.schedulePrayerNotifications(times);
      // ✅ مزامنة مواعيد أذكار الصباح والمساء تلقائياً مع الشروق والغروب وفجر وعصر اليوم
      await AzkarNotificationService().syncWithPrayerTimes(model);

      // ✅ التحقق من الإشعارات المجدولة
      final pending = await notificationService.getPendingNotifications();
      debugPrint('✅ تم جدولة ${pending.length} إشعارات بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في جدولة الإشعارات: $e');
    }
  }

  /// تحديث مواقيت الصلاة (Pull to Refresh)
  Future<void> refreshPrayerTimes() async {
    if (_lastSuccessfulState != null) {
      emit(PrayerRefreshing(_lastSuccessfulState!));
    } else {
      emit(PrayerLoading());
    }

    try {
      final result = await repository.getPrayerTimes(
        latitude: _currentLatitude,
        longitude: _currentLongitude,
      );

      result.fold(
        (error) {
          if (_lastSuccessfulState != null) {
            emit(_lastSuccessfulState!);
          } else {
            emit(PrayerError('لا يوجد اتصال بالإنترنت. حاول مرة أخرى.'));
          }
        },
        (prayerTimes) async {
          final prayerList = _getPrayerList(prayerTimes);
          final loadedState = PrayerLoaded(
            prayerTimes: prayerTimes,
            prayers: prayerList,
            nextPrayer: _getNextPrayer(prayerList),
            city: _currentCity,
            country: _currentCountry,
          );

          _lastSuccessfulState = loadedState;
          emit(loadedState);

          await _schedulePrayerNotifications(prayerTimes);
        },
      );
    } catch (e) {
      debugPrint('❌ خطأ في التحديث: $e');
      if (_lastSuccessfulState != null) {
        emit(_lastSuccessfulState!);
      }
    }
  }

  /// تحويل الوقت من String إلى DateTime
  DateTime _parseTimeString(String timeString, DateTime now) {
    try {
      final cleanTime = timeString.trim();
      final parts = cleanTime.split(' ');
      if (parts.isEmpty) return now;

      final timePart = parts[0];
      final period = parts.length > 1 ? parts[1].toUpperCase() : '';

      final timeParts = timePart.split(':');
      if (timeParts.length < 2) return now;

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return now;
    }
  }

  /// الحصول على قائمة الصلوات
  List<PrayerInfo> _getPrayerList(PrayerTimesModel model) {
    final now = DateTime.now();
    final prayers = [
      PrayerInfo(
        name: 'Fajr',
        nameAr: 'الفجر',
        time: model.fajr,
        isPassed: _isPrayerPassed(model.fajr, now),
        isNext: false,
      ),
      PrayerInfo(
        name: 'Sunrise',
        nameAr: 'الشروق',
        time: model.sunrise,
        isPassed: _isPrayerPassed(model.sunrise, now),
        isNext: false,
      ),
      PrayerInfo(
        name: 'Dhuhr',
        nameAr: 'الظهر',
        time: model.dhuhr,
        isPassed: _isPrayerPassed(model.dhuhr, now),
        isNext: false,
      ),
      PrayerInfo(
        name: 'Asr',
        nameAr: 'العصر',
        time: model.asr,
        isPassed: _isPrayerPassed(model.asr, now),
        isNext: false,
      ),
      PrayerInfo(
        name: 'Maghrib',
        nameAr: 'المغرب',
        time: model.maghrib,
        isPassed: _isPrayerPassed(model.maghrib, now),
        isNext: false,
      ),
      PrayerInfo(
        name: 'Isha',
        nameAr: 'العشاء',
        time: model.isha,
        isPassed: _isPrayerPassed(model.isha, now),
        isNext: false,
      ),
    ];

    return prayers;
  }

  bool _isPrayerPassed(String prayerTime, DateTime now) {
    final prayerDateTime = _parseTimeString(prayerTime, now);
    return now.isAfter(prayerDateTime);
  }

  PrayerInfo? _getNextPrayer(List<PrayerInfo> prayers) {
    for (var prayer in prayers) {
      if (!prayer.isPassed) {
        return PrayerInfo(
          name: prayer.name,
          nameAr: prayer.nameAr,
          time: prayer.time,
          isPassed: prayer.isPassed,
          isNext: true,
        );
      }
    }
    return prayers.first;
  }

  /// حساب الوقت المتبقي للصلاة التالية
  String getTimeRemaining(String prayerTime) {
    try {
      final now = DateTime.now();
      var prayerDateTime = _parseTimeString(prayerTime, now);

      if (prayerDateTime.isBefore(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      final difference = prayerDateTime.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00:00';
    }
  }

  @override
  Future<void> close() {
    _updateTimer?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
