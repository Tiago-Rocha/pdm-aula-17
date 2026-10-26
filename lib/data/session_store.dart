import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The refresh token, in the Keychain (iOS) or the Keystore (Android).
/// Never in shared_preferences: it is a password that lasts 30 days.
class SessionStore {
  const SessionStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;
  static const _key = 'refreshToken';

  Future<String?> read() => _storage.read(key: _key);

  Future<void> save(String refreshToken) =>
      _storage.write(key: _key, value: refreshToken);

  Future<void> clear() => _storage.delete(key: _key);
}
