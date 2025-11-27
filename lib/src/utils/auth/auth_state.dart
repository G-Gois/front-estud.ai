import 'package:estud_ai/src/backend/schema/user_schema.dart';

class AuthState {
  const AuthState({
    required this.user,
    required this.token,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      user: null,
      token: null,
      isLoading: false,
      error: null,
    );
  }

  final UserSchema? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    UserSchema? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
