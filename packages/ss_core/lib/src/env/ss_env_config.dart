import 'package:flutter/foundation.dart';

/// Runtime environment configuration for SSFluxKit apps.
class SSEnvConfig {
  const SSEnvConfig({
    required this.apiBaseUrl,
    this.enableHttpLogging = true,
    this.appName = 'SSFluxKit',
    this.useMock = false,
    this.demoUserEmail = 'demo@ssflux.local',
    this.demoUserPassword = 'DemoUser123!',
  });

  /// REST API base URL including `/api/v1`, no trailing slash.
  final String apiBaseUrl;

  final bool enableHttpLogging;
  final String appName;

  /// When true, use in-memory mock data and skip real auth/API.
  final bool useMock;

  final String demoUserEmail;
  final String demoUserPassword;

  static const String _baseUrlDefine = String.fromEnvironment('SS_API_BASE_URL');

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
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api/v1';
      default:
        return 'http://localhost:8080/api/v1';
    }
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

  factory SSEnvConfig.fromEnvironment() {
    return SSEnvConfig(
      apiBaseUrl: defaultApiBaseUrlForPlatform(),
      useMock: _useMockDefine,
      demoUserEmail: _demoEmailDefine,
      demoUserPassword: _demoPasswordDefine,
    );
  }
}
