import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final _storage = const FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _tokenTypeKey = 'token_type';
  static const _usernameKey = 'global_username';

  Future<void> saveToken(String token, String tokenType) async {
    await _storage.write(key: _accessTokenKey, value: token);
    await _storage.write(key: _tokenTypeKey, value: tokenType);
  }

  Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  Future<String?> getTokenType() async {
    return await _storage.read(key: _tokenTypeKey);
  }

  Future<void> deleteAllTokens() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _tokenTypeKey);
  }
}
