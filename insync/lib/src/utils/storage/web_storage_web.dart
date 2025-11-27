import 'dart:html' as html;
import 'package:insync/src/utils/storage/i_platform_storage.dart';

class WebStorage implements IPlatformStorage {
  late html.Storage _localStorage;

  @override
  Future<void> init() async {
    _localStorage = html.window.localStorage;
  }

  @override
  Future<bool> write(String key, String value) async {
    try {
      _localStorage[key] = value;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return _localStorage[key];
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(String key) async {
    try {
      _localStorage.remove(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      _localStorage.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _localStorage.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}

IPlatformStorage getPlatformStorage() => WebStorage();
