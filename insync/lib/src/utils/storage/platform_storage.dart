import 'package:flutter/foundation.dart';
import 'package:insync/src/utils/storage/i_platform_storage.dart';
import 'package:insync/src/utils/storage/mobile_storage.dart';
import 'package:insync/src/utils/storage/web_storage_stub.dart'
    if (dart.library.html) 'package:insync/src/utils/storage/web_storage_web.dart';

class PlatformStorage implements IPlatformStorage {
  late final IPlatformStorage _storage;

  PlatformStorage() {
    if (kIsWeb) {
      _storage = getPlatformStorage();
    } else {
      _storage = MobileStorage();
    }
  }

  @override
  Future<void> init() => _storage.init();

  @override
  Future<bool> write(String key, String value) => _storage.write(key, value);

  @override
  Future<String?> read(String key) => _storage.read(key);

  @override
  Future<bool> delete(String key) => _storage.delete(key);

  @override
  Future<bool> clear() => _storage.clear();

  @override
  Future<bool> containsKey(String key) => _storage.containsKey(key);
}
