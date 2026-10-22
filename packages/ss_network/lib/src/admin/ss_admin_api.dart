import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';

import '../errors/ss_api_error_mapper.dart';
import '../models/ss_user.dart';

/// Minimal admin client for integration tests / tooling (not used in App UI).
class SSAdminApi {
  SSAdminApi({required String adminBaseUrl, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: adminBaseUrl,
                headers: {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;
  String? _accessToken;

  Future<SSResult<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      _accessToken = response.data!['accessToken'] as String;
      return const SSSuccess(null);
    } on DioException catch (e) {
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    }
  }

  Future<SSResult<SSUser>> patchUser({
    required int userId,
    required bool disabled,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/users/$userId',
        data: {'disabled': disabled},
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );
      return SSSuccess(SSUser.fromJson(response.data!));
    } on DioException catch (e) {
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    }
  }

}
