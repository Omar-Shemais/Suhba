import 'package:dio/dio.dart';
import 'package:islamic_app/core/constants/api_constants.dart';
import '../models/hadith_model.dart';

abstract class HadithRepository {
  Future<HadithResponse> getHadiths({
    String? book,
    int page = 1,
    int limit = 20,
  });

  Future<List<HadithModel>> searchHadiths({
    String? arabicQuery,
    String? englishQuery,
  });
}

class HadithRepositoryImpl implements HadithRepository {
  final Dio dio;
  static const String baseUrl = ApiConstants.hadithApiBase;
  static const String apiKey = ApiConstants.hadithApiKey;

  HadithRepositoryImpl({required this.dio});

  @override
  Future<HadithResponse> getHadiths({
    String? book,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'apiKey': apiKey,
        'page': page.toString(),
        'limit': limit.toString(),
        if (book != null && book != 'all') 'book': book,
      };

      final response = await dio.get(
        '$baseUrl/hadiths/',
        queryParameters: queryParams,
      );

      return HadithResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // رسائل خطأ مخصصة حسب نوع الخطأ
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('انتهت مهلة الاتصال. تحقق من الإنترنت');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('استغرق الخادم وقتاً طويلاً للرد');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('تحقق من اتصالك بالإنترنت');
      } else if (e.response?.statusCode == 404) {
        throw Exception('الصفحة غير موجودة');
      } else if (e.response?.statusCode == 500) {
        throw Exception('خطأ في الخادم، حاول مرة أخرى');
      } else {
        throw Exception('فشل تحميل الأحاديث');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }

  @override
  Future<List<HadithModel>> searchHadiths({
    String? arabicQuery,
    String? englishQuery,
  }) async {
    try {
      // بناء الـ query parameters بالأسماء الصحيحة من الـ API
      final queryParams = <String, dynamic>{'apiKey': apiKey, 'limit': '50'};

      if (arabicQuery != null && arabicQuery.isNotEmpty) {
        queryParams['hadithArabic'] = arabicQuery;
      }

      // إضافة English search إذا موجود
      if (englishQuery != null && englishQuery.isNotEmpty) {
        queryParams['hadithEnglish'] = englishQuery;
      }

      // التحقق من وجود على الأقل query واحد
      if (!queryParams.containsKey('hadithArabic') &&
          !queryParams.containsKey('hadithEnglish')) {
        return []; // لو مفيش أي query، ارجع قائمة فاضية
      }

      final response = await dio.get(
        '$baseUrl/hadiths/',
        queryParameters: queryParams,
      );

      // استخدام نفس الطريقة اللي في HadithResponse.fromJson
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // ✅ التحقق من status 404 (لما مفيش نتائج)
        if (data['status'] == 404 || data['message'] == 'Hadiths not found.') {
          return []; // إرجاع قائمة فاضية بدل exception
        }

        // التعامل مع الـ structure: hadiths -> data -> [array]
        if (data.containsKey('hadiths') && data['hadiths'] is Map) {
          final hadithsMap = data['hadiths'] as Map<String, dynamic>;
          final hadithsList = (hadithsMap['data'] as List<dynamic>?) ?? [];

          return hadithsList
              .map((h) => HadithModel.fromJson(h as Map<String, dynamic>))
              .toList();
        }
        // fallback: إذا كان hadiths مباشرة array
        else if (data.containsKey('hadiths') && data['hadiths'] is List) {
          final hadithsList = data['hadiths'] as List<dynamic>;

          return hadithsList
              .map((h) => HadithModel.fromJson(h as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      }
      // إذا كان الـ response مباشرة List
      else if (response.data is List) {
        final hadithsList = response.data as List<dynamic>;

        return hadithsList
            .map((h) => HadithModel.fromJson(h as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unknown response type: ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      // ✅ التعامل مع 404 من Dio Exception
      if (e.response?.statusCode == 404) {
        return []; // إرجاع قائمة فاضية بدل exception
      }

      // رسائل خطأ مخصصة للبحث
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('انتهت مهلة الاتصال أثناء البحث');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('تحقق من اتصالك بالإنترنت');
      } else {
        throw Exception('فشل البحث، حاول مرة أخرى');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء البحث');
    }
  }
}
