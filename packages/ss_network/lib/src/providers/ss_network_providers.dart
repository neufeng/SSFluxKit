import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';

import '../auth/ss_auth_api.dart';
import '../auth/ss_auth_session.dart';
import '../auth/ss_token_storage.dart';
import '../client/ss_api_client_factory.dart';
import '../client/ss_http_client.dart';

typedef SSAccountDisabledCallback = Future<void> Function();

final ssTokenStorageProvider = Provider<SSTokenStorage>((ref) {
  throw UnimplementedError('Override ssTokenStorageProvider in host app.');
});

final ssAuthSessionProvider = Provider<SSAuthSession>((ref) {
  return SSAuthSession(ref.watch(ssTokenStorageProvider));
});

final ssAccountDisabledHandlerProvider =
    Provider<SSAccountDisabledCallback>((ref) {
  return () async {};
});

final ssAuthApiProvider = Provider<SSAuthApi>((ref) {
  return SSAuthApi(_publicDio(SSEnv.config.apiBaseUrl));
});

final ssHttpClientProvider = Provider<SSHttpClient>((ref) {
  final session = ref.watch(ssAuthSessionProvider);
  final authApi = ref.watch(ssAuthApiProvider);
  final factory = SSApiClientFactory(
    baseUrl: SSEnv.config.apiBaseUrl,
    session: session,
    authApi: authApi,
    onAccountDisabled: () =>
        ref.read(ssAccountDisabledHandlerProvider)(),
    enableLogging: SSEnv.config.enableHttpLogging,
  );
  return factory.createAuthorizedClient();
});

Dio _publicDio(String baseUrl) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
}
