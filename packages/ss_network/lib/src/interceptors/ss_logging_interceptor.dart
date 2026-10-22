import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';

class SSLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    SSLogger.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    SSLogger.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    SSLogger.w('✗ ${err.requestOptions.method} ${err.requestOptions.uri}');
    handler.next(err);
  }
}
