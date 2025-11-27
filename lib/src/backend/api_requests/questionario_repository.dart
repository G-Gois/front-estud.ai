import 'package:estud_ai/src/backend/api_requests/api_client.dart';
import 'package:estud_ai/src/backend/api_requests/api_response.dart';
import 'package:estud_ai/src/backend/api_requests/endpoints.dart';
import 'package:estud_ai/src/backend/schema/questionario_schema.dart';

class QuestionarioRepository {
  QuestionarioRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<ApiResponse<List<QuestionarioSchema>>> listar() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.listarQuestionarios,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>? ?? [];
      final list = data
          .map((e) => QuestionarioSchema.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse<List<QuestionarioSchema>>(
        statusCode: response.statusCode,
        data: list,
        message: response.message,
      );
    }

    return ApiResponse<List<QuestionarioSchema>>(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<QuestionarioSchema>> porConteudo(String conteudoId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.questionarioByConteudo(conteudoId),
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse<QuestionarioSchema>(
        statusCode: response.statusCode,
        data: QuestionarioSchema.fromJson(data),
        message: response.message,
      );
    }

    return ApiResponse<QuestionarioSchema>(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<QuestionarioSchema>> porId(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.questionarioById(id),
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse<QuestionarioSchema>(
        statusCode: response.statusCode,
        data: QuestionarioSchema.fromJson(data),
        message: response.message,
      );
    }

    return ApiResponse<QuestionarioSchema>(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> porIdCompleto(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.questionarioById(id),
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse<Map<String, dynamic>>(
        statusCode: response.statusCode,
        data: data,
        message: response.message,
      );
    }

    return ApiResponse<Map<String, dynamic>>(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> finalizar({
    required String questionarioId,
    required List<Map<String, dynamic>> respostas,
  }) {
    return apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.finalizarQuestionario(questionarioId),
      body: {'respostas': respostas},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resumo(String questionarioId) {
    return apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.resumoQuestionario(questionarioId),
    );
  }
}
