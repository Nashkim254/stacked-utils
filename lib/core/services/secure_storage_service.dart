import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A wrapper around [FlutterSecureStorage] for storing sensitive values
/// (tokens, PINs, credentials) that must not go into SharedPreferences.
///
/// On Android, uses [AndroidOptions(encryptedSharedPreferences: true)].
/// On iOS, values are stored in the Keychain.
///
/// ```dart
/// // Register in your locator:
/// locator.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
///
/// // Usage:
/// await secureStorage.write('access_token', token);
/// final token = await secureStorage.read('access_token');
/// await secureStorage.delete('access_token');
/// ```
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Writes [value] for [key], replacing any existing value.
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  /// Returns the value stored for [key], or `null` if the key does not exist.
  Future<String?> read(String key) => _storage.read(key: key);

  /// Deletes the entry for [key]. A no-op if the key does not exist.
  Future<void> delete(String key) => _storage.delete(key: key);

  /// Deletes all entries from the secure storage.
  Future<void> deleteAll() => _storage.deleteAll();

  /// Returns `true` when [key] has a stored non-null value.
  Future<bool> has(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  /// Returns a copy of all key-value pairs currently in the secure storage.
  Future<Map<String, String>> readAll() => _storage.readAll();

  /// Writes [value] for [key] only if the key is not already present.
  ///
  /// If a value already exists for [key] this method does nothing.
  Future<void> writeIfAbsent(String key, String value) async {
    final existing = await _storage.read(key: key);
    if (existing == null) {
      await _storage.write(key: key, value: value);
    }
  }
}
