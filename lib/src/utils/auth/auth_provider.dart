import 'package:estud_ai/src/core/service_locator.dart';
import 'package:estud_ai/src/utils/auth/auth_repository.dart';
import 'package:estud_ai/src/utils/auth/auth_state.dart';
import 'package:estud_ai/src/utils/auth/auth_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/api_requests/api_client.dart';
import '../storage/storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: serviceLocator.get<ApiClient>(),
    storage: serviceLocator.get<StorageService>(),
  );
});

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthSessionNotifier(repository);
});

class AuthSessionNotifier extends StateNotifier<AuthState> {
  AuthSessionNotifier(this.repository) : super(AuthState.initial());

  final AuthRepository repository;

  Future<AuthResult?> restore() async {
    final result = await repository.restoreSession();
    if (result != null) {
      state = state.copyWith(user: result.user, token: result.token);
    }
    return result;
  }

  Future<AuthResult?> login(String email, String senha) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await repository.login(email: email, senha: senha);
    state = state.copyWith(isLoading: false);

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      state = state.copyWith(user: data.user, token: data.token);
      return data;
    }
    state = state.copyWith(
      error: response.message ?? 'Erro ao fazer login',
    );
    return null;
  }

  Future<AuthResult?> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    String? dataNascimento,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await repository.register(
      nomeCompleto: nomeCompleto,
      email: email,
      senha: senha,
      dataNascimento: dataNascimento,
    );
    state = state.copyWith(isLoading: false);

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      state = state.copyWith(user: data.user, token: data.token);
      return data;
    }
    state = state.copyWith(
      error: response.message ?? 'Erro ao registrar',
    );
    return null;
  }

  Future<void> logout() async {
    await repository.logout();
    state = AuthState.initial();
  }
}
