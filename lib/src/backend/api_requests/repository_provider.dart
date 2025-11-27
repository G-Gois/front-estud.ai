import 'package:estud_ai/src/backend/api_requests/content_repository.dart';
import 'package:estud_ai/src/backend/api_requests/questionario_repository.dart';
import 'package:estud_ai/src/core/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(apiClient: serviceLocator.get<ApiClient>());
});

final questionarioRepositoryProvider =
    Provider<QuestionarioRepository>((ref) {
  return QuestionarioRepository(apiClient: serviceLocator.get<ApiClient>());
});
