import 'package:flutter_test/flutter_test.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_fluxkit_demo/router/ss_app_redirect.dart';

void main() {
  const api = SSEnvConfig(apiBaseUrl: 'http://localhost/api/v1');

  test('non-mock unauthenticated user may open all shop tabs', () {
    for (final path in ['/', '/category', '/cart', '/profile', '/product/p1']) {
      expect(
        ssResolveAppRedirect(
          config: api,
          authInitialized: true,
          isAuthenticated: false,
          matchedLocation: path,
        ),
        isNull,
      );
    }
  });

  test('non-mock dev routes require login', () {
    expect(
      ssResolveAppRedirect(
        config: api,
        authInitialized: true,
        isAuthenticated: false,
        matchedLocation: '/dev',
      ),
      '/login',
    );
    expect(
      ssResolveAppRedirect(
        config: api,
        authInitialized: true,
        isAuthenticated: false,
        matchedLocation: '/dev/feed',
      ),
      '/login',
    );
  });

  test('mock mode skips redirect', () {
    expect(
      ssResolveAppRedirect(
        config: const SSEnvConfig(
          apiBaseUrl: 'http://localhost/api/v1',
          useMock: true,
        ),
        authInitialized: true,
        isAuthenticated: false,
        matchedLocation: '/dev',
      ),
      isNull,
    );
  });
}
