import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:dartz/dartz.dart';

class Failure {
  final String message;
  Failure(this.message);
}

class QiblaData {
  final double angle;
  final double latitude;
  final double longitude;

  const QiblaData({
    required this.angle,
    required this.latitude,
    required this.longitude,
  });
}

class QiblaRepository {
  // 1) ask for permission and determine location
  Future<Either<Failure, Position>> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(Failure('خدمة الموقع غير مفعلة. يرجى تفعيلها من الإعدادات.'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(Failure('تم رفض صلاحية الوصول إلى الموقع.'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(Failure('صلاحية الموقع مرفوضة نهائياً. يرجى تفعيلها من إعدادات الهاتف.'));
      }

      // Try fetching current position with timeout, fallback to last known
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
        return Right(position);
      } catch (_) {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          return Right(lastPosition);
        }
        rethrow;
      }
    } catch (e) {
      // Last chance fallback
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          return Right(lastPosition);
        }
      } catch (_) {}
      return Left(Failure('تعذر تحديد موقعك الحالي. تأكد من تفعيل الـ GPS وحاول مجدداً.'));
    }
  }

  // 2) calculate Qibla angle from user position to Kaaba
  double calculateQibla(double userLat, double userLng) {
    const double kaabaLat = 21.4225241;
    const double kaabaLng = 39.8261818;

    final double userLatRad = userLat * (pi / 180);
    final double userLngRad = userLng * (pi / 180);
    final double kaabaLatRad = kaabaLat * (pi / 180);
    final double kaabaLngRad = kaabaLng * (pi / 180);

    final double deltaLng = kaabaLngRad - userLngRad;

    final double y = sin(deltaLng);
    final double x =
        cos(userLatRad) * tan(kaabaLatRad) - sin(userLatRad) * cos(deltaLng);
    final double angle = atan2(y, x);

    return (angle * 180 / pi + 360) % 360;
  }

  // 3) Public method for Cubit
  Future<Either<Failure, QiblaData>> getQiblaAngle() async {
    final positionResult = await determinePosition();

    return positionResult.fold((failure) => Left(failure), (position) {
      final angle = calculateQibla(position.latitude, position.longitude);
      return Right(QiblaData(
        angle: angle,
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    });
  }
}
