import 'ss_env_config.dart';

/// Global holder for environment configuration (set once at app startup).
class SSEnv {
  SSEnv._();

  static SSEnvConfig? _config;

  static SSEnvConfig get config {
    final c = _config;
    if (c == null) {
      throw StateError('SSEnv.init must be called before accessing config.');
    }
    return c;
  }

  static bool get isInitialized => _config != null;

  static void init(SSEnvConfig config) {
    _config = config;
  }

  static void reset() {
    _config = null;
  }
}
