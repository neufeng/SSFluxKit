/// Runtime environment configuration for SSFluxKit apps.
class SSEnvConfig {
  const SSEnvConfig({
    required this.apiBaseUrl,
    this.enableHttpLogging = true,
    this.appName = 'SSFluxKit',
    this.useMock = false,
    this.demoUserEmail = 'demo@ssflux.local',
    this.demoUserPassword = 'DemoUser123!',
    this.httpProxy = '',
  });

  /// Default App API base when [SS_API_BASE_URL] is unset.
  ///
  /// Matches Charles Map Local host `api.ssflux.com` (HTTP). Override with
  /// `--dart-define=SS_API_BASE_URL=...` for a real backend (e.g. local SSFluxServer).
  static const String defaultAppApiBaseUrl = 'http://api.ssflux.com/api/v1';

  /// REST API base URL including `/api/v1`, no trailing slash.
  final String apiBaseUrl;

  final bool enableHttpLogging;
  final String appName;

  /// When true, use in-memory mock data and skip real auth/API.
  final bool useMock;

  final String demoUserEmail;
  final String demoUserPassword;

  /// Debug-only HTTP proxy as `host:port` (e.g. Charles on the dev machine).
  ///
  /// Set via `--dart-define=SS_HTTP_PROXY=10.0.0.5:8888`. Empty means direct
  /// connection (default). Does not read system Wi‑Fi proxy on device.
  final String httpProxy;

  static const String _baseUrlDefine = String.fromEnvironment('SS_API_BASE_URL');

  static const String _httpProxyDefine = String.fromEnvironment('SS_HTTP_PROXY');

  static const bool _useMockDefine = bool.fromEnvironment(
    'SS_USE_MOCK',
    defaultValue: false,
  );

  static const String _demoEmailDefine = String.fromEnvironment(
    'SS_DEMO_USER_EMAIL',
    defaultValue: 'demo@ssflux.local',
  );

  static const String _demoPasswordDefine = String.fromEnvironment(
    'SS_DEMO_USER_PASSWORD',
    defaultValue: 'DemoUser123!',
  );

  static String defaultApiBaseUrlForPlatform() {
    if (_baseUrlDefine.isNotEmpty) {
      return _normalizeBaseUrl(_baseUrlDefine);
    }
    return defaultAppApiBaseUrl;
  }

  static String _normalizeBaseUrl(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (!u.endsWith('/api/v1')) {
      if (u.endsWith('/api')) {
        u = '$u/v1';
      } else if (!u.contains('/api/v1')) {
        u = '$u/api/v1';
      }
    }
    return u;
  }

  /// Normalizes [SS_HTTP_PROXY] define value (`host:port`); empty → no proxy.
  static String normalizeHttpProxy(String raw) => raw.trim();

  factory SSEnvConfig.fromEnvironment() {
    return SSEnvConfig(
      apiBaseUrl: defaultApiBaseUrlForPlatform(),
      useMock: _useMockDefine,
      demoUserEmail: _demoEmailDefine,
      demoUserPassword: _demoPasswordDefine,
      httpProxy: normalizeHttpProxy(_httpProxyDefine),
    );
  }
}
