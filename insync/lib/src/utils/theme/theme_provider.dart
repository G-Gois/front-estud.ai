import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/utils/storage/storage.dart';
import 'package:insync/src/utils/storage/storage_keys.dart';
import 'package:insync/src/core/service_locator.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = true; // Dark mode por padrão
  final Storage _storage = locator<Storage>();

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await _storage.get(AppStorageKey.themeMode.key);
    if (savedTheme != null) {
      _isDarkMode = savedTheme == 'dark';
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.save(
      AppStorageKey.themeMode.key,
      _isDarkMode ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _storage.save(
        AppStorageKey.themeMode.key,
        _isDarkMode ? 'dark' : 'light',
      );
      notifyListeners();
    }
  }
}

final themeNotifierProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier();
});
