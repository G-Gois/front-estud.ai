import 'dart:convert';

import 'package:estud_ai/src/backend/api_requests/api_client.dart';
import 'package:estud_ai/src/backend/api_requests/endpoints.dart';
import 'package:estud_ai/src/backend/api_requests/api_response.dart';
import 'package:estud_ai/src/backend/schema/user_schema.dart';
import 'package:estud_ai/src/utils/auth/auth_result.dart';
import 'package:estud_ai/src/utils/storage/storage_keys.dart';
import 'package:estud_ai/src/utils/storage/storage_service.dart';

class AuthRepository {
  AuthRepository({
    required this.apiClient,
    required this.storage,
  });

  final ApiClient apiClient;
  final StorageService storage;

  Future<ApiResponse<AuthResult>> login({
    required String email,
    required String senha,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      body: {
        'email': email,
        'senha': senha,
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] ?? {};
      final token = data['token']?.toString() ?? '';
      final userJson = data['usuario'] as Map<String, dynamic>? ?? {};
      final user = UserSchema.fromJson(userJson);
      await _persistSession(token, user);
      return ApiResponse<AuthResult>(
        statusCode: response.statusCode,
        data: AuthResult(token: token, user: user),
        message: response.message,
      );
    }

    return ApiResponse<AuthResult>(
      statusCode: response.statusCode,
      message: response.message ?? 'Erro ao fazer login',
    );
  }

  Future<ApiResponse<AuthResult>> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    String? dataNascimento,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      body: {
        'nome_completo': nomeCompleto,
        'email': email,
        'senha': senha,
        if (dataNascimento != null) 'data_nascimento': dataNascimento,
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] ?? {};
      final token = data['token']?.toString() ?? '';
      final userJson = data['usuario'] as Map<String, dynamic>? ?? {};
      final user = UserSchema.fromJson(userJson);
      await _persistSession(token, user);
      return ApiResponse<AuthResult>(
        statusCode: response.statusCode,
        data: AuthResult(token: token, user: user),
        message: response.message,
      );
    }

    return ApiResponse<AuthResult>(
      statusCode: response.statusCode,
      message: response.message ?? 'Erro ao registrar',
    );
  }

  Future<ApiResponse<UserSchema>> me() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.me,
    );

    if (response.isSuccess && response.data != null) {
      final userJson = response.data!['data'] as Map<String, dynamic>? ?? {};
      final user = UserSchema.fromJson(userJson);
      return ApiResponse<UserSchema>(
        statusCode: response.statusCode,
        data: user,
        message: response.message,
      );
    }

    return ApiResponse<UserSchema>(
      statusCode: response.statusCode,
      message: response.message ?? 'Erro ao obter perfil',
    );
  }

  Future<ApiResponse<void>> updateProfile({
    required Map<String, dynamic> fields,
  }) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.me,
      body: fields,
    );

    return ApiResponse<void>(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<void>> deleteAccount() async {
    final response = await apiClient.delete(ApiEndpoints.me);
    if (response.isSuccess) {
      await logout();
    }
    return ApiResponse<void>(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<void> logout() async {
    apiClient.setAuthToken(null);
    await storage.clear();
  }

  Future<void> _persistSession(String token, UserSchema user) async {
    apiClient.setAuthToken(token);
    await storage.write(StorageKeys.authToken, token);
    await storage.write(StorageKeys.user, jsonEncode(user.toJson()));
  }

  Future<AuthResult?> restoreSession() async {
    final savedToken = storage.read(StorageKeys.authToken);
    final savedUserJson = storage.read(StorageKeys.user);
    if (savedToken == null || savedUserJson == null) return null;
    try {
      final map = jsonDecode(savedUserJson) as Map<String, dynamic>;
      final user = UserSchema.fromJson(map);
      apiClient.setAuthToken(savedToken);
      return AuthResult(token: savedToken, user: user);
    } catch (_) {
      return null;
    }
  }
}
