import 'package:dio/dio.dart';

/// Placeholder auth interceptor — attaches Bearer token when provider returns a value.
class SSAuthInterceptor extends Interceptor {
  SSAuthInterceptor({this.tokenProvider});

  final String? Function()? tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
