class ApiEndpoints {
  ApiEndpoints._();

  // Base segments
  static const String api = '/api';
  static const String auth = '$api/auth';
  static const String conteudos = '$api/conteudos';
  static const String questionarios = '$api/questionarios';

  // Auth
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String me = '$auth/me';

  // Conteudos
  static const String criarConteudo = conteudos;
  static String conteudoById(String id) => '$conteudos/$id';
  static String novoQuestionario(String id) => '$conteudos/$id/novo-questionario';

  // Questionarios
  static const String listarQuestionarios = questionarios;
  static String questionarioByConteudo(String conteudoId) =>
      '$questionarios/conteudo/$conteudoId';
  static String questionarioById(String id) => '$questionarios/$id';
  static String finalizarQuestionario(String id) => '$questionarios/$id/finalizar';
  static String resumoQuestionario(String id) => '$questionarios/$id/resumo';
}
