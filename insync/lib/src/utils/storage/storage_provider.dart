import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/utils/storage/storage.dart';
import 'package:insync/src/utils/storage/storage_service.dart';

final storageProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageProvider deve ser sobrescrito no main');
});

final storageManagerProvider = Provider<Storage>((ref) {
  final service = ref.watch(storageProvider);
  return Storage(service);
});
