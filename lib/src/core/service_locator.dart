import 'package:estud_ai/src/backend/api_requests/api_client.dart';
import 'package:estud_ai/src/utils/storage/storage_service.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

void setupLocator({
  required ApiClient apiClient,
  required StorageService storageService,
}) {
  if (!serviceLocator.isRegistered<ApiClient>()) {
    serviceLocator.registerSingleton<ApiClient>(apiClient);
  }

  if (!serviceLocator.isRegistered<StorageService>()) {
    serviceLocator.registerSingleton<StorageService>(storageService);
  }
}
