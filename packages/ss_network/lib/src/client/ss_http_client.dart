import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';

import '../interceptors/ss_auth_interceptor.dart';
import '../interceptors/ss_logging_interceptor.dart';
import '../interceptors/ss_retry_interceptor.dart';

/// Configurable Dio-based HTTP client with SS interceptors.
class SSHttpClient {
  SSHttpClient({
    required String baseUrl,
    Dio? dio,
    String? Function()? authTokenProvider,
    bool enableLogging = true,
    int maxRetries = 2,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: {'Accept': 'application/json'},
              ),
            ) {
    _dio.interceptors.addAll([
      SSAuthInterceptor(tokenProvider: authTokenProvider),
      if (enableLogging) SSLoggingInterceptor(),
      SSRetryInterceptor(dio: _dio, maxRetries: maxRetries),
    ]);
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<SSResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (parser != null) {
        return SSSuccess(parser(data));
      }
      return SSSuccess(data as T);
    } on DioException catch (e, st) {
      SSLogger.e('GET $path failed', e, st);
      return SSFailure(_mapDioError(e));
    } catch (e, st) {
      SSLogger.e('GET $path failed', e, st);
      return SSFailure(SSUnknownError(e.toString(), e));
    }
  }

  Future<SSResult<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      final body = response.data;
      if (parser != null) {
        return SSSuccess(parser(body));
      }
      return SSSuccess(body as T);
    } on DioException catch (e, st) {
      SSLogger.e('POST $path failed', e, st);
      return SSFailure(_mapDioError(e));
    } catch (e, st) {
      SSLogger.e('POST $path failed', e, st);
      return SSFailure(SSUnknownError(e.toString(), e));
    }
  }

  SSAppError _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return SSUnauthorizedError(e.message ?? '未授权');
    }
    if (status == 404) {
      return SSNotFoundError();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return SSNetworkError('请求超时', cause: e, statusCode: status);
    }
    if (e.type == DioExceptionType.connectionError) {
      return SSNetworkError('网络不可用', cause: e, statusCode: status);
    }
    return SSNetworkError(
      e.message ?? '网络请求失败',
      cause: e,
      statusCode: status,
    );
  }
}
