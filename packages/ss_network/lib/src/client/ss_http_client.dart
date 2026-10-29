import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';

import '../errors/ss_api_error_mapper.dart';
import 'ss_dio_factory.dart';

/// Configurable Dio-based HTTP client.
class SSHttpClient {
  SSHttpClient({
    required String baseUrl,
    Dio? dio,
    bool enableLogging = true,
    int maxRetries = 2,
    String httpProxy = '',
  }) : _dio = dio ??
            SSDioFactory.create(baseUrl: baseUrl, httpProxy: httpProxy);

  SSHttpClient.fromDio(this._dio);

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
      return SSFailure(SSApiErrorMapper.fromDioException(e));
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
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    } catch (e, st) {
      SSLogger.e('POST $path failed', e, st);
      return SSFailure(SSUnknownError(e.toString(), e));
    }
  }

  Future<SSResult<T>> putBytes<T>(
    String url,
    List<int> bytes, {
    required String contentType,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        url,
        data: bytes,
        options: Options(
          headers: {'Content-Type': contentType},
          extra: {'ss_auth_retry': true},
        ),
      );
      if (parser != null) {
        return SSSuccess(parser(response.data));
      }
      return SSSuccess(response.data as T);
    } on DioException catch (e, st) {
      SSLogger.e('PUT upload failed', e, st);
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    }
  }
}
