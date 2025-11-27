import 'package:insync/src/utils/storage/storage_service.dart';
import 'package:insync/src/utils/storage/storage_types.dart';

/// Facade for StorageService
class Storage {
  final StorageService _service;

  Storage(this._service);

  // Secure Storage
  Future<bool> saveSecure<T>(String key, T value) {
    return _service.saveData<T>(
      key: key,
      value: value,
      type: StorageType.secure,
    );
  }

  Future<T?> getSecure<T>(String key) {
    return _service.getData<T>(
      key: key,
      type: StorageType.secure,
    );
  }

  Future<bool> removeSecure(String key) {
    return _service.removeData(
      key: key,
      type: StorageType.secure,
    );
  }

  // Regular Storage
  Future<bool> save<T>(String key, T value) {
    return _service.saveData<T>(
      key: key,
      value: value,
      type: StorageType.regular,
    );
  }

  Future<T?> get<T>(String key) {
    return _service.getData<T>(
      key: key,
      type: StorageType.regular,
    );
  }

  Future<bool> remove(String key) {
    return _service.removeData(
      key: key,
      type: StorageType.regular,
    );
  }

  // Temp Storage
  Future<bool> saveTemp<T>(String key, T value) {
    return _service.saveData<T>(
      key: key,
      value: value,
      type: StorageType.temp,
    );
  }

  Future<T?> getTemp<T>(String key) {
    return _service.getData<T>(
      key: key,
      type: StorageType.temp,
    );
  }

  Future<bool> removeTemp(String key) {
    return _service.removeData(
      key: key,
      type: StorageType.temp,
    );
  }

  // Utility methods
  Future<bool> clearAll() => _service.clearAll();
  Future<bool> clearTemp() => _service.clearTemp();
}
