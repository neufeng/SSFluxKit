import 'package:flutter_test/flutter_test.dart';
import 'package:ss_core/ss_core.dart';

void main() {
  test('defaultApiBaseUrlForPlatform uses default host when unset', () {
    expect(
      SSEnvConfig.defaultApiBaseUrlForPlatform(),
      SSEnvConfig.defaultAppApiBaseUrl,
    );
    expect(SSEnvConfig.defaultApiHost, 'api.example.cn');
    expect(
      SSEnvConfig.defaultAppApiBaseUrl,
      'http://api.example.cn/api/v1',
    );
    expect(
      SSEnvConfig.defaultAdminApiBaseUrl,
      'http://api.example.cn/admin/v1',
    );
  });

  test('fromEnvironment picks default base URL', () {
    final config = SSEnvConfig.fromEnvironment();
    expect(config.apiBaseUrl, 'http://api.example.cn/api/v1');
    expect(config.httpProxy, isEmpty);
  });

  test('normalizeHttpProxy trims whitespace', () {
    expect(SSEnvConfig.normalizeHttpProxy(' 10.0.0.1:8888 '), '10.0.0.1:8888');
    expect(SSEnvConfig.normalizeHttpProxy(''), '');
  });
}
