class ConteudoSchema {
  ConteudoSchema({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.criadoEm,
    this.totalQuestionarios,
    this.totalPerguntas,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String? criadoEm;
  final int? totalQuestionarios;
  final int? totalPerguntas;

  factory ConteudoSchema.fromJson(Map<String, dynamic> json) {
    return ConteudoSchema(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      criadoEm: json['criado_em']?.toString(),
      totalQuestionarios: json['total_questionarios'] as int?,
      totalPerguntas: json['total_perguntas'] as int?,
    );
  }
}
