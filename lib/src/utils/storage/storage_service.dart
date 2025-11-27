import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fachada simples para armazenamento local (seguro e não seguro).
class StorageService {
  StorageService({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;
  late SharedPreferences _preferences;
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    _isReady = true;
  }

  String? read(String key, {String? defaultValue}) {
    return _preferences.getString(key) ?? defaultValue;
  }

  Future<void> write(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<void> delete(String key) async {
    await _preferences.remove(key);
    await _secureStorage.delete(key: key);
  }

  Future<void> clear() async {
    await _preferences.clear();
    await _secureStorage.deleteAll();
  }

  Future<String?> readSecure(String key) {
    return _secureStorage.read(key: key);
  }

  Future<void> writeSecure(String key, String value) {
    return _secureStorage.write(key: key, value: value);
  }
}
