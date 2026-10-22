import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';

import '../errors/ss_api_error_mapper.dart';
import '../models/ss_auth_tokens.dart';
import '../models/ss_user.dart';

/// App auth endpoints (`/auth/*`, `/me`) using a public Dio instance.
class SSAuthApi {
  SSAuthApi(this._dio);

  final Dio _dio;

  Future<SSResult<SSAuthTokens>> login({
    required String email,
    required String password,
  }) async {
    return _post(
      '/auth/login',
      {'email': email, 'password': password},
      SSAuthTokens.fromJson,
    );
  }

  Future<SSResult<SSAuthTokens>> refresh({required String refreshToken}) async {
    return _post(
      '/auth/refresh',
      {'refreshToken': refreshToken},
      SSAuthTokens.fromJson,
    );
  }

  Future<SSResult<void>> logout({required String accessToken}) async {
    try {
      await _dio.post<void>(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return const SSSuccess(null);
    } on DioException catch (e, st) {
      SSLogger.e('logout failed', e, st);
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    }
  }

  Future<SSResult<SSUser>> me({required String accessToken}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return SSSuccess(SSUser.fromJson(response.data!));
    } on DioException catch (e, st) {
      SSLogger.e('me failed', e, st);
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    }
  }

  Future<SSResult<T>> _post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic> json) parser,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return SSSuccess(parser(response.data!));
    } on DioException catch (e, st) {
      SSLogger.e('POST $path failed', e, st);
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    }
  }
}
