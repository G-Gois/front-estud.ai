import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:insync/src/utils/storage/i_platform_storage.dart';
import 'package:insync/src/utils/storage/platform_storage.dart';
import 'package:insync/src/utils/storage/storage_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late final IPlatformStorage _platformStorage;
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _platformStorage = PlatformStorage();
    await _platformStorage.init();
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> saveData<T>({
    required String key,
    required T value,
    required StorageType type,
  }) async {
    try {
      final String stringValue;

      if (value is String) {
        stringValue = value;
      } else if (value is num || value is bool) {
        stringValue = value.toString();
      } else {
        stringValue = jsonEncode(value);
      }

      switch (type) {
        case StorageType.secure:
          // flutter_secure_storage já faz criptografia automaticamente
          return await _platformStorage.write(key, stringValue);

        case StorageType.regular:
          return await _prefs.setString(key, stringValue);

        case StorageType.temp:
          return await _prefs.setString('temp_$key', stringValue);
      }
    } catch (e) {
      debugPrint('Save error: $e');
      return false;
    }
  }

  Future<T?> getData<T>({
    required String key,
    required StorageType type,
  }) async {
    try {
      String? stringValue;

      switch (type) {
        case StorageType.secure:
          // flutter_secure_storage já faz descriptografia automaticamente
          stringValue = await _platformStorage.read(key);
          break;

        case StorageType.regular:
          stringValue = _prefs.getString(key);
          break;

        case StorageType.temp:
          stringValue = _prefs.getString('temp_$key');
          break;
      }

      if (stringValue == null) return null;

      // Type conversion
      if (T == String) return stringValue as T;
      if (T == int) return int.tryParse(stringValue) as T?;
      if (T == double) return double.tryParse(stringValue) as T?;
      if (T == bool) return (stringValue.toLowerCase() == 'true') as T;

      // Try to parse as JSON
      try {
        return jsonDecode(stringValue) as T;
      } catch (e) {
        return stringValue as T;
      }
    } catch (e) {
      debugPrint('Get error: $e');
      return null;
    }
  }

  Future<bool> removeData({
    required String key,
    required StorageType type,
  }) async {
    try {
      switch (type) {
        case StorageType.secure:
          return await _platformStorage.delete(key);
        case StorageType.regular:
          return await _prefs.remove(key);
        case StorageType.temp:
          return await _prefs.remove('temp_$key');
      }
    } catch (e) {
      debugPrint('Remove error: $e');
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      await _platformStorage.clear();
      await _prefs.clear();
      return true;
    } catch (e) {
      debugPrint('Clear all error: $e');
      return false;
    }
  }

  Future<bool> clearTemp() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('temp_')) {
          await _prefs.remove(key);
        }
      }
      return true;
    } catch (e) {
      debugPrint('Clear temp error: $e');
      return false;
    }
  }
}
