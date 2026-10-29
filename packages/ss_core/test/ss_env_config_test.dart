import 'package:flutter_test/flutter_test.dart';
import 'package:ss_core/ss_core.dart';

void main() {
  test('defaultApiBaseUrlForPlatform uses Charles Map Local host when unset', () {
    expect(
      SSEnvConfig.defaultApiBaseUrlForPlatform(),
      SSEnvConfig.defaultAppApiBaseUrl,
    );
    expect(
      SSEnvConfig.defaultAppApiBaseUrl,
      'http://api.ssflux.com/api/v1',
    );
  });

  test('fromEnvironment picks default base URL', () {
    final config = SSEnvConfig.fromEnvironment();
    expect(config.apiBaseUrl, 'http://api.ssflux.com/api/v1');
  });
}
