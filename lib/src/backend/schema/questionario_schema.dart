class QuestionarioSchema {
  QuestionarioSchema({
    required this.id,
    required this.conteudoId,
    required this.titulo,
    required this.descricao,
    this.modo,
    this.ordem,
    this.totalPerguntas,
    this.finalizado,
    this.finalizadoEm,
  });

  final String id;
  final String conteudoId;
  final String titulo;
  final String descricao;
  final String? modo;
  final int? ordem;
  final int? totalPerguntas;
  final bool? finalizado;
  final String? finalizadoEm;

  factory QuestionarioSchema.fromJson(Map<String, dynamic> json) {
    return QuestionarioSchema(
      id: json['questionario_id']?.toString() ?? json['id']?.toString() ?? '',
      conteudoId: json['conteudo_id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      modo: json['modo']?.toString(),
      ordem: json['ordem'] as int?,
      totalPerguntas: json['total_perguntas'] as int?,
      finalizado: json['finalizado'] as bool?,
      finalizadoEm: json['finalizado_em']?.toString(),
    );
  }
}
