import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';

import '../auth/ss_auth_api.dart';
import '../auth/ss_auth_session.dart';
typedef SSAccountDisabledHandler = Future<void> Function();

/// Attaches Bearer token and performs single-flight refresh on 401.
class SSTokenRefreshInterceptor extends QueuedInterceptor {
  SSTokenRefreshInterceptor({
    required this.session,
    required this.authApi,
    required this.dio,
    this.onAccountDisabled,
  });

  final SSAuthSession session;
  final SSAuthApi authApi;
  final Dio dio;
  final SSAccountDisabledHandler? onAccountDisabled;

  Completer<void>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await session.ensureLoaded();
    final token = session.accessToken;
    if (token != null &&
        token.isNotEmpty &&
        !options.path.contains('/auth/login') &&
        !options.path.contains('/auth/refresh')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final body = err.response?.data;
    if (body is Map<String, dynamic> &&
        body['code'] == 'ACCOUNT_DISABLED') {
      await session.clear();
      await onAccountDisabled?.call();
      handler.next(err);
      return;
    }

    if (status != 401 || _isAuthPath(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    if (err.requestOptions.extra['ss_auth_retry'] == true) {
      handler.next(err);
      return;
    }

    try {
      await _refreshTokensSingleFlight();
      final response = await _retry(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } catch (e) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  bool _isAuthPath(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/register');
  }

  Future<void> _refreshTokensSingleFlight() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<void>();
    try {
      await session.ensureLoaded();
      final refresh = session.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.badResponse,
          message: '无 refresh token',
        );
      }
      final result = await authApi.refresh(refreshToken: refresh);
      await result.when(
        success: (tokens) async {
          await session.setTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
        },
        failure: (error) {
          if (error is SSAccountDisabledError) {
            throw DioException(
              requestOptions: RequestOptions(path: '/auth/refresh'),
              response: Response(
                requestOptions: RequestOptions(path: '/auth/refresh'),
                statusCode: 403,
                data: {'code': 'ACCOUNT_DISABLED', 'message': error.message},
              ),
              type: DioExceptionType.badResponse,
            );
          }
          throw DioException(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            type: DioExceptionType.badResponse,
            message: error.message,
          );
        },
      );
      _refreshCompleter!.complete();
    } catch (e, st) {
      _refreshCompleter!.completeError(e, st);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final newOptions = options.copyWith(
      extra: Map<String, dynamic>.from(options.extra)..['ss_auth_retry'] = true,
    );
    await session.ensureLoaded();
    final token = session.accessToken;
    if (token != null) {
      newOptions.headers['Authorization'] = 'Bearer $token';
    }
    return dio.fetch<dynamic>(newOptions);
  }
}
