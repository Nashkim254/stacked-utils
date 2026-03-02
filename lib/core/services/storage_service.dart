import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for typed key-value storage.
///
/// Register as a singleton in your locator:
/// ```dart
/// final storage = await StorageService.init();
/// locator.registerSingleton<StorageService>(storage);
/// ```
class StorageService {
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // ── Write ───────────────────────────────────────────────────────────────

  Future<void> saveString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> saveBool(String key, bool value) => _prefs.setBool(key, value);

  Future<void> saveInt(String key, int value) => _prefs.setInt(key, value);

  Future<void> saveDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  Future<void> saveStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  // ── Read ────────────────────────────────────────────────────────────────

  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);
  double? getDouble(String key) => _prefs.getDouble(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  bool has(String key) => _prefs.containsKey(key);

  // ── Delete ──────────────────────────────────────────────────────────────

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clearAll() => _prefs.clear();

  /// Clear only the keys matching [prefix].
  Future<void> clearPrefix(String prefix) async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
