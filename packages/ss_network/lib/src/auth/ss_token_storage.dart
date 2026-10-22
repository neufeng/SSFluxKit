import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SSTokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clear();
}

/// Mobile/desktop secure storage.
class SSSecureTokenStorage implements SSTokenStorage {
  SSSecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _accessKey = 'ss_access_token';
  static const _refreshKey = 'ss_refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

/// Web / test fallback when secure storage is unavailable.
class SSPreferencesTokenStorage implements SSTokenStorage {
  SSPreferencesTokenStorage(this._prefs);

  static const _accessKey = 'ss_access_token';
  static const _refreshKey = 'ss_refresh_token';

  final SharedPreferences _prefs;

  static Future<SSPreferencesTokenStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SSPreferencesTokenStorage(prefs);
  }

  @override
  Future<String?> readAccessToken() async => _prefs.getString(_accessKey);

  @override
  Future<String?> readRefreshToken() async => _prefs.getString(_refreshKey);

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_accessKey, accessToken);
    await _prefs.setString(_refreshKey, refreshToken);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
  }
}

Future<SSTokenStorage> createSSTokenStorage() async {
  if (kIsWeb) {
    return SSPreferencesTokenStorage.create();
  }
  try {
    return SSSecureTokenStorage();
  } catch (_) {
    return SSPreferencesTokenStorage.create();
  }
}
