import 'package:email_validator/email_validator.dart';

class Validators {
  Validators._();

  static String? required(String? value, {String field = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String field = 'Campo'}) {
    if (value == null || value.trim().length < min) {
      return '$field precisa de pelo menos $min caracteres';
    }
    return null;
  }
}
