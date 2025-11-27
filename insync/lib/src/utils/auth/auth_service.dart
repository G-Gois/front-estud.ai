import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:insync/src/utils/mixin/set_state_mixin.dart';
import 'package:insync/src/utils/storage/storage_keys.dart';
import 'package:insync/src/utils/storage/storage_service.dart';
import 'package:insync/src/utils/storage/storage_types.dart';

class AuthService extends ChangeNotifier with SetStateMixin {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final StorageService _storageService = StorageService();
  late bool _isAuthenticated;
  Timer? _authTimer;

  AuthService._internal() {
    _isAuthenticated = false;
    _startAuthTimer();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final token = await getAuthToken();
    setState(() => _isAuthenticated = token != null);
  }

  bool get isAuthenticatedNotifier => _isAuthenticated;

  void _startAuthTimer() {
    _authTimer?.cancel();
    _authTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async => await getAuthToken(),
    );
  }

  Future<bool> saveAuthToken(String token, DateTime expiry) async {
    try {
      await _storageService.saveData<String>(
        key: AppStorageKey.token.key,
        value: token,
        type: StorageType.secure,
      );
      await _storageService.saveData<String>(
        key: AppStorageKey.tokenExpiry.key,
        value: expiry.toIso8601String(),
        type: StorageType.secure,
      );
      setState(() => _isAuthenticated = true);
      return true;
    } catch (e) {
      debugPrint('Save token error: $e');
      return false;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final token = await _storageService.getData<String>(
        key: AppStorageKey.token.key,
        type: StorageType.secure,
      );
      final expiryStr = await _storageService.getData<String>(
        key: AppStorageKey.tokenExpiry.key,
        type: StorageType.secure,
      );

      if (token == null || expiryStr == null) {
        setState(() => _isAuthenticated = false);
        return null;
      }

      final expiry = DateTime.parse(expiryStr);
      final isAuthenticated = DateTime.now().isBefore(expiry);

      setState(() => _isAuthenticated = isAuthenticated);

      if (!isAuthenticated) {
        await removeAuthToken();
        return null;
      }

      return token;
    } catch (e) {
      debugPrint('Get token error: $e');
      setState(() => _isAuthenticated = false);
      return null;
    }
  }

  Future<bool> removeAuthToken() async {
    try {
      await _storageService.removeData(
        key: AppStorageKey.token.key,
        type: StorageType.secure,
      );
      await _storageService.removeData(
        key: AppStorageKey.tokenExpiry.key,
        type: StorageType.secure,
      );
      setState(() => _isAuthenticated = false);
      return true;
    } catch (e) {
      debugPrint('Remove token error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _authTimer?.cancel();
    super.dispose();
  }
}
