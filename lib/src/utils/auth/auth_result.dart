import 'package:estud_ai/src/backend/schema/user_schema.dart';

class AuthResult {
  AuthResult({
    required this.token,
    required this.user,
  });

  final String token;
  final UserSchema user;
}
