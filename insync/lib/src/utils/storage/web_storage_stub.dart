import 'package:insync/src/utils/storage/i_platform_storage.dart';

class WebStorage implements IPlatformStorage {
  @override
  Future<void> init() async {
    throw UnsupportedError('Web storage stub - use web_storage_web.dart');
  }

  @override
  Future<bool> write(String key, String value) async {
    throw UnsupportedError('Web storage stub - use web_storage_web.dart');
  }

  @override
  Future<String?> read(String key) async {
    throw UnsupportedError('Web storage stub - use web_storage_web.dart');
  }

  @override
  Future<bool> delete(String key) async {
    throw UnsupportedError('Web storage stub - use web_storage_web.dart');
  }

  @override
  Future<bool> clear() async {
    throw UnsupportedError('Web storage stub - use web_storage_web.dart');
  }

  @override
  Future<bool> containsKey(String key) async {
    throw UnsupportedError('Web storage stub - use web_storage_web.dart');
  }
}

IPlatformStorage getPlatformStorage() => WebStorage();
