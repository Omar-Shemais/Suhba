import 'package:dartz/dartz.dart';
import 'package:islamic_app/core/errors/failures.dart';

import '../data_source/local_data_source.dart';
import '../model/sibha_model.dart';

class SibhaRepository {
  final SibhaLocalDataSource sibhaLocalDataSource;

  SibhaRepository({required this.sibhaLocalDataSource});

  Either<Failure, List<SibhaModel>> getSibhaData() {
    try {
      final localData = sibhaLocalDataSource.getSibhaData();
      return Right(localData);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل بيانات السبحة: ${e.toString()}'));
    }
  }
}
