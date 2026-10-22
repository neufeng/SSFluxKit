import 'package:dio/dio.dart';

/// Retries idempotent requests on transient failures.
class SSRetryInterceptor extends Interceptor {
  SSRetryInterceptor({required this.dio, this.maxRetries = 2});

  final Dio dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final retryCount = (options.extra['ss_retry_count'] as int?) ?? 0;

    final shouldRetry = _isRetryable(err) &&
        retryCount < maxRetries &&
        _isIdempotent(options.method);

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    options.extra['ss_retry_count'] = retryCount + 1;
    await Future<void>.delayed(Duration(milliseconds: 300 * (retryCount + 1)));

    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _isIdempotent(String method) {
    return method.toUpperCase() == 'GET' || method.toUpperCase() == 'HEAD';
  }

  bool _isRetryable(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
