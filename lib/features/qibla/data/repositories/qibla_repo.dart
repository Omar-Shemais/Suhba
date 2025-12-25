import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:dartz/dartz.dart';

class Failure {
  final String message;
  Failure(this.message);
}

class QiblaRepository {
  // 1) ask for permission
  Future<Either<Failure, Position>> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(Failure('خدمة الموقع مش مفعلة. فعلها من الإعدادات.'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(Failure('الصلاحية مرفوضة من المستخدم.'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(Failure('الصلاحية مرفوضة نهائيًا. افتح الإعدادات.'));
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return Right(position);
    } catch (e) {
      return Left(Failure('حدث خطأ أثناء الحصول على الموقع: $e'));
    }
  }

  // 2) calculate qibla
  double calculateQibla(double userLat, double userLng) {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

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

  // 3) الدالة العامة اللى هيناديها الـ Cubit
  Future<Either<Failure, double>> getQiblaAngle() async {
    final positionResult = await determinePosition();

    return positionResult.fold((failure) => Left(failure), (position) {
      final angle = calculateQibla(position.latitude, position.longitude);
      return Right(angle);
    });
  }
}
