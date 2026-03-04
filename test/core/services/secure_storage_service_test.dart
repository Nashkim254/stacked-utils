import 'package:app_kit/app_kit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// ── In-memory mock ────────────────────────────────────────────────────────────

class _MockSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data[key];

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data.remove(key);

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data.clear();

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      Map.of(_data);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

SecureStorageService _makeService() =>
    SecureStorageService(_MockSecureStorage());

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('SecureStorageService', () {
    test('write then read returns the stored value', () async {
      final svc = _makeService();
      await svc.write('token', 'abc123');
      expect(await svc.read('token'), 'abc123');
    });

    test('read on missing key returns null', () async {
      final svc = _makeService();
      expect(await svc.read('missing'), isNull);
    });

    test('delete removes the value', () async {
      final svc = _makeService();
      await svc.write('token', 'abc123');
      await svc.delete('token');
      expect(await svc.read('token'), isNull);
    });

    test('deleteAll clears everything', () async {
      final svc = _makeService();
      await svc.write('a', '1');
      await svc.write('b', '2');
      await svc.deleteAll();
      expect(await svc.read('a'), isNull);
      expect(await svc.read('b'), isNull);
    });

    test('has returns true when key exists', () async {
      final svc = _makeService();
      await svc.write('token', 'abc123');
      expect(await svc.has('token'), isTrue);
    });

    test('has returns false when key does not exist', () async {
      final svc = _makeService();
      expect(await svc.has('absent'), isFalse);
    });

    test('writeIfAbsent does not overwrite an existing value', () async {
      final svc = _makeService();
      await svc.write('token', 'original');
      await svc.writeIfAbsent('token', 'overwrite');
      expect(await svc.read('token'), 'original');
    });

    test('writeIfAbsent writes when key is absent', () async {
      final svc = _makeService();
      await svc.writeIfAbsent('token', 'first');
      expect(await svc.read('token'), 'first');
    });
  });
}
