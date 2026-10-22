import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

/// Live server integration — run with:
/// `SS_RUN_INTEGRATION=true flutter test test/ss_real_api_integration_test.dart`
void main() {
  final run = Platform.environment['SS_RUN_INTEGRATION'] == 'true';
  final baseUrl = Platform.environment['SS_API_BASE_URL'] ??
      'http://localhost:8080/api/v1';
  final adminBase = baseUrl.replaceFirst('/api/v1', '/admin/v1');

  test(
    'SSFluxServer live API flow',
    () async {
      SharedPreferences.setMockInitialValues({});
      SSEnv.init(SSEnvConfig(apiBaseUrl: baseUrl, useMock: false));

      final storage =
          SSPreferencesTokenStorage(await SharedPreferences.getInstance());
      final session = SSAuthSession(storage);
      final publicDio = Dio(BaseOptions(baseUrl: baseUrl));
      final authApi = SSAuthApi(publicDio);

      const demoEmail = 'demo@ssflux.local';
      const demoPassword = 'DemoUser123!';
      const adminEmail = 'admin@ssflux.local';
      const adminPassword = 'DemoAdmin123!';

      final login = await authApi.login(
        email: demoEmail,
        password: demoPassword,
      );
      expect(login.isSuccess, isTrue, reason: 'login failed — is server up?');
      final tokens = login.dataOrNull!;
      await session.setTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      final factory = SSApiClientFactory(
        baseUrl: baseUrl,
        session: session,
        authApi: authApi,
      );
      final client = factory.createAuthorizedClient();

      final feed = await client.get<Map<String, dynamic>>(
        '/feed',
        queryParameters: {'limit': 5},
        parser: (j) => j as Map<String, dynamic>,
      );
      expect(feed.isSuccess, isTrue);
      expect(feed.dataOrNull!['items'], isA<List<dynamic>>());

      final items = feed.dataOrNull!['items'] as List<dynamic>;
      if (items.isNotEmpty) {
        final id = (items.first as Map<String, dynamic>)['id'];
        final detail = await client.get<Map<String, dynamic>>(
          '/feed/$id',
          parser: (j) => j as Map<String, dynamic>,
        );
        expect(detail.isSuccess, isTrue);
      }

      final refresh = await authApi.refresh(
        refreshToken: session.refreshToken!,
      );
      expect(refresh.isSuccess, isTrue);
      await session.setTokens(
        accessToken: refresh.dataOrNull!.accessToken,
        refreshToken: refresh.dataOrNull!.refreshToken,
      );

      final admin = SSAdminApi(adminBaseUrl: adminBase);
      expect(
        (await admin.login(email: adminEmail, password: adminPassword))
            .isSuccess,
        isTrue,
      );
      final userId = tokens.user?.id;
      expect(userId, isNotNull);
      expect(
        (await admin.patchUser(userId: userId!, disabled: true)).isSuccess,
        isTrue,
      );

      final disabledRefresh = await authApi.refresh(
        refreshToken: session.refreshToken!,
      );
      expect(disabledRefresh.isFailure, isTrue);
      expect(disabledRefresh.errorOrNull, isA<SSAccountDisabledError>());

      await admin.patchUser(userId: userId, disabled: false);
    },
    skip: run ? false : 'Set SS_RUN_INTEGRATION=true and start SSFluxServer',
  );
}
