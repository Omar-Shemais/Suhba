import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:islamic_app/core/constants/api_constants.dart';
import 'package:islamic_app/core/network/dio_client.dart';
import '../models/masjed_model.dart';

class Failure {
  final String message;
  Failure(this.message);
}

class NearestMsajedRepo {
  Future<Either<Failure, Position>> getUserCurrentPosition() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      return left(
        Failure('خدمة الموقع غير مفعلة من فضلك فعلها من اعدادت الموبايل'),
      );
    }

    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return left(Failure('المستخدم رفض الصلاحية'));
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
      return left(Failure('الصلاحية مرفوضة تماما افتح الاعدادات '));
    }

    final position = await Geolocator.getCurrentPosition();
    return right(position);
  }

  Future<Either<Failure, List<MasjedModel>>> getNearestMasjeds(
    Position position,
  ) async {
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.endPointGoogleMapsurl,
        queryParameters: {
          'location': '${position.latitude},${position.longitude}',
          'radius': 250,
          'type': 'mosque',
          'key': ApiConstants.googleApiKey,
        },
      );
      List<MasjedModel> masjeds = [];
      for (var masjed in res.data['results']) {
        masjeds.add(MasjedModel.fromJson(masjed));
      }
      return right(masjeds);
    } on Exception catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
