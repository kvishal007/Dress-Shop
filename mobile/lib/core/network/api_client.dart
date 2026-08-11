import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../errors/failure.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Dio get instance => _dio;

  Failure handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    if (error.response != null) {
      final data = error.response?.data;
      final statusCode = error.response?.statusCode;
      final message = (data is Map && data.containsKey('message'))
          ? data['message']
          : 'An unexpected server error occurred';

      if (statusCode == 401) {
        return AuthFailure(message, statusCode: statusCode);
      }

      return ServerFailure(message, statusCode: statusCode);
    }

    return ServerFailure(error.message ?? 'Unknown network error');
  }
}
