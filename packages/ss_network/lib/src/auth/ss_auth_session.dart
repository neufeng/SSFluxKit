import 'ss_token_storage.dart';

/// In-memory session mirror with persistent token storage.
class SSAuthSession {
  SSAuthSession(this._storage);

  final SSTokenStorage _storage;

  String? _accessToken;
  String? _refreshToken;
  bool _loaded = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get isAuthenticated =>
      _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }
    _accessToken = await _storage.readAccessToken();
    _refreshToken = await _storage.readRefreshToken();
    _loaded = true;
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _loaded = true;
    await _storage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _loaded = true;
    await _storage.clear();
  }
}
