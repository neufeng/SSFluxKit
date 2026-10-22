/// Runtime environment configuration for SSFluxKit apps.
class SSEnvConfig {
  const SSEnvConfig({
    required this.apiBaseUrl,
    this.enableHttpLogging = true,
    this.appName = 'SSFluxKit',
  });

  /// REST API base URL (no trailing slash). Override via `--dart-define=SS_API_BASE_URL=...`.
  final String apiBaseUrl;

  final bool enableHttpLogging;
  final String appName;

  static const String _baseUrlDefine = String.fromEnvironment(
    'SS_API_BASE_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  factory SSEnvConfig.fromEnvironment() {
    return SSEnvConfig(apiBaseUrl: _baseUrlDefine);
  }
}
