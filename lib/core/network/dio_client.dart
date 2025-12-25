import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;
  DioClient._(this.dio);

  static DioClient get instance => _instance;
  static final DioClient _instance = _create();

  static DioClient _create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        followRedirects: true,
      ),
    );
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
    return DioClient._(dio);
  }

  static Future<Response> getData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    String? token,
    ProgressCallback? prog,
  }) async {
    final res = await DioClient.instance.dio.get(
      endPoint,
      queryParameters: queryParameters,
      onReceiveProgress: prog,

      options: Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
          'Content-Type': 'application/json',
        },
      ),
    );
    return res;
  }
}
