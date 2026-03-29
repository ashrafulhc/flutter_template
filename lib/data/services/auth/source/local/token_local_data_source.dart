import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';
const _expiresAtKey = 'expires_at';

@lazySingleton
class TokenLocalDataSource {
  final FlutterSecureStorage _storage;

  const TokenLocalDataSource(this._storage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _expiresAtKey, value: expiresAt.toIso8601String()),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<DateTime?> getExpiresAt() async {
    final value = await _storage.read(key: _expiresAtKey);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresAtKey),
    ]);
  }
}
