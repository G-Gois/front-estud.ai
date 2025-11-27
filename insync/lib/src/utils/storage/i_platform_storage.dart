abstract class IPlatformStorage {
  Future<void> init();
  Future<bool> write(String key, String value);
  Future<String?> read(String key);
  Future<bool> delete(String key);
  Future<bool> clear();
  Future<bool> containsKey(String key);
}
