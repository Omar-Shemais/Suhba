import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:islamic_app/core/constants/api_constants.dart';
import 'package:islamic_app/core/network/dio_client.dart';
import 'package:islamic_app/core/network/connectivity_helper.dart';
import 'package:islamic_app/core/services/location_service.dart';
import 'package:islamic_app/core/services/azan_notification_service.dart';
import 'package:islamic_app/features/prayer_times/data/repositories/prayer_repository.dart';
import 'package:islamic_app/features/prayer_times/presentation/cubit/prayer_cubit.dart';
import 'package:islamic_app/features/hadith/data/repositories/hadith_repository.dart';
import 'package:islamic_app/features/quran/data/repositories/audio_repo.dart';
import 'package:islamic_app/features/quran/data/repositories/mushaf_repo.dart';
import 'package:islamic_app/features/quran/data/repositories/quran_repo.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';
import 'package:islamic_app/core/constants/storage_constants.dart';

// Auth imports
import 'package:islamic_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:islamic_app/features/auth/data/datasources/user_firestore_datasource.dart';
import 'package:islamic_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:islamic_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:islamic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:islamic_app/features/auth/presentation/cubit/auth_cubit.dart';

// Settings imports
import 'package:islamic_app/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:islamic_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:islamic_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:islamic_app/features/settings/presentation/cubit/settings_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Network
  getIt.registerLazySingleton(() => DioClient.instance);
  getIt.registerLazySingleton(() => ConnectivityHelper());
  // Services
  getIt.registerLazySingleton(() => LocationService());
  getIt.registerLazySingleton(() => AzanNotificationService());

  // Repositories
  //QURAN REPO
  getIt.registerLazySingleton<QuranRepository>(() => QuranRepositoryImpl());
  //mushaf repo
  getIt.registerLazySingleton<MushafRepository>(() => MushafRepository());
  // AUDIO REPO
  getIt.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
  // PRAYER REPO
  getIt.registerLazySingleton<PrayerRepository>(() => PrayerRepositoryImpl());

  // Prayer Cubit
  getIt.registerFactory<PrayerCubit>(
    () => PrayerCubit(getIt<PrayerRepository>()),
  );

  //  Audio Cubit
  getIt.registerLazySingleton<AudioCubit>(
    () => AudioCubit(getIt<AudioRepository>()),
  );
  //quran cubit
  // Auth Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<UserFirestoreDataSource>(
    () => UserFirestoreDataSourceImpl(),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(box: Hive.box(StorageConstants.userBoxName)),
  );

  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      firestoreDataSource: getIt<UserFirestoreDataSource>(),
    ),
  );

  // Auth Cubit
  getIt.registerFactory(
    () => AuthCubit(authRepository: getIt<AuthRepository>()),
  );

  // Settings Data Source
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(),
  );

  // Settings Repository
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<SettingsLocalDataSource>()),
  );

  // Settings Cubit
  getIt.registerFactory(
    () => SettingsCubit(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: ApiConstants.hadithApiBase,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
      ),
    )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true)),
    instanceName: 'hadithDio',
  );
  // Hadith Repository
  getIt.registerLazySingleton<HadithRepository>(
    () => HadithRepositoryImpl(dio: getIt<Dio>(instanceName: 'hadithDio')),
  );
}
