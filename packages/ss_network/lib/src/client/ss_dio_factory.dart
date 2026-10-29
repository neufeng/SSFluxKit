import 'package:dio/dio.dart';

import 'ss_dio_http_proxy_stub.dart'
    if (dart.library.io) 'ss_dio_http_proxy_io.dart' as ss_http_proxy;

/// Shared Dio construction for SSFluxKit (timeouts, headers, debug proxy).
class SSDioFactory {
  SSDioFactory._();

  static Dio create({
    required String baseUrl,
    String httpProxy = '',
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    ss_http_proxy.applySsHttpProxy(dio, httpProxy);
    return dio;
  }
}
