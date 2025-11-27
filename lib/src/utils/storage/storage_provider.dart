import 'package:estud_ai/src/utils/storage/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';

final storageProvider = Provider<StorageService>((ref) {
  return serviceLocator.get<StorageService>();
});
