part of 'login_controller.dart';

class LoginState {
  const LoginState({
    required this.email,
    required this.password,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isLoading,
    this.error,
  });

  factory LoginState.initial() {
    return const LoginState(
      email: '',
      password: '',
      rememberMe: true,
      obscurePassword: true,
      isLoading: false,
    );
  }

  final String email;
  final String password;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isLoading;
  final String? error;

  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? obscurePassword,
    bool? isLoading,
    String? error,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
