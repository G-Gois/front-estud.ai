import 'package:estud_ai/src/backend/api_requests/api_client.dart';
import 'package:estud_ai/src/backend/api_requests/api_response.dart';
import 'package:estud_ai/src/backend/api_requests/endpoints.dart';
import 'package:estud_ai/src/backend/schema/conteudo_schema.dart';

class ContentRepository {
  ContentRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<ApiResponse<Map<String, dynamic>>> criarConteudo(String input) async {
    return apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.criarConteudo,
      body: {'input': input},
      mapper: (raw) {
        if (raw is Map<String, dynamic>) {
          return (raw['data'] as Map<String, dynamic>?) ?? {};
        }
        return <String, dynamic>{};
      },
    );
  }

  Future<ApiResponse<List<ConteudoSchema>>> listar() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.conteudos,
    );

    if (response.isSuccess && response.data != null) {
      final list = (response.data!['data'] as List<dynamic>? ?? [])
          .map((e) => ConteudoSchema.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse<List<ConteudoSchema>>(
        statusCode: response.statusCode,
        data: list,
        message: response.message,
      );
    }

    return ApiResponse<List<ConteudoSchema>>(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> obterCompleto(String conteudoId) {
    return apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.conteudoById(conteudoId),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> gerarNovoQuestionario(
    String conteudoId, {
    bool progressao = true,
  }) {
    return apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.novoQuestionario(conteudoId),
      body: {'progressao': progressao},
    );
  }
}
