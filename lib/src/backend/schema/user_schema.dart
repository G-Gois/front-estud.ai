class UserSchema {
  UserSchema({
    required this.id,
    required this.nomeCompleto,
    required this.email,
    this.dataNascimento,
    this.criadoEm,
  });

  final String id;
  final String nomeCompleto;
  final String email;
  final String? dataNascimento;
  final String? criadoEm;

  factory UserSchema.fromJson(Map<String, dynamic> json) {
    return UserSchema(
      id: json['id']?.toString() ?? '',
      nomeCompleto: json['nome_completo']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dataNascimento: json['data_nascimento']?.toString(),
      criadoEm: json['criado_em']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_completo': nomeCompleto,
      'email': email,
      'data_nascimento': dataNascimento,
      'criado_em': criadoEm,
    };
  }
}
