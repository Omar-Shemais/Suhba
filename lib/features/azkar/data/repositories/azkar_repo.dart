import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../../../../core/network/dio_client.dart';
import '../models/azkar_model.dart';
import '../../../../../core/constants/api_constants.dart';

class AzkarRepo {
  static Future<Either<String, AzkarModel>> getMorningAzkar() async {
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarMorningApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);

      return right(azkar);
    } catch (e) {
      log(e.toString());
      return left(e.toString());
    }
  }

  static Future<Either<String, AzkarModel>> getEveningAzkar() async {
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarMassaApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);

      return right(azkar);
    } catch (e) {
      log(e.toString());
      return left(e.toString());
    }
  }

  static Future<Either<String, AzkarModel>> getAfterPrayerAzkar() async {
    try {
      final res = await DioClient.getData(
        endPoint: ApiConstants.azkarPostPrayerApiBase,
      );

      final azkar = AzkarModel.fromJson(res.data);

      return right(azkar);
    } catch (e) {
      log(e.toString());
      return left(e.toString());
    }
  }
}
