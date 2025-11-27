import 'package:estud_ai/src/utils/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'login_state.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController({
    required this.authSessionNotifier,
  }) : super(LoginState.initial());

  final AuthSessionNotifier authSessionNotifier;

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  void toggleRememberMe(bool? value) {
    state = state.copyWith(rememberMe: value ?? false);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> submit() async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true, error: null);

    final result = await authSessionNotifier.login(
      state.email,
      state.password,
    );

    state = state.copyWith(
      isLoading: false,
      error: result == null ? 'Login invalido' : null,
    );

    return result != null;
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  final auth = ref.read(authSessionProvider.notifier);
  return LoginController(authSessionNotifier: auth);
});
