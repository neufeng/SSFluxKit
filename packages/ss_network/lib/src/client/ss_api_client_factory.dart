import 'package:dio/dio.dart';
import '../auth/ss_auth_api.dart';
import '../auth/ss_auth_session.dart';
import '../interceptors/ss_logging_interceptor.dart';
import '../interceptors/ss_retry_interceptor.dart';
import '../interceptors/ss_token_refresh_interceptor.dart';
import 'ss_dio_factory.dart';
import 'ss_http_client.dart';

class SSApiClientFactory {
  SSApiClientFactory({
    required this.baseUrl,
    required this.session,
    required this.authApi,
    this.onAccountDisabled,
    this.enableLogging = true,
    this.httpProxy = '',
  });

  final String baseUrl;
  final SSAuthSession session;
  final SSAuthApi authApi;
  final Future<void> Function()? onAccountDisabled;
  final bool enableLogging;
  final String httpProxy;

  Dio createPublicDio() {
    return SSDioFactory.create(baseUrl: baseUrl, httpProxy: httpProxy);
  }

  SSHttpClient createAuthorizedClient() {
    final dio = createPublicDio();
    dio.interceptors.addAll([
      SSTokenRefreshInterceptor(
        session: session,
        authApi: authApi,
        dio: dio,
        onAccountDisabled: onAccountDisabled,
      ),
      if (enableLogging) SSLoggingInterceptor(),
      SSRetryInterceptor(dio: dio, maxRetries: 2),
    ]);
    return SSHttpClient.fromDio(dio);
  }
}
