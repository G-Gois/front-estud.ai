import 'package:get_it/get_it.dart';
import 'package:insync/src/utils/storage/storage.dart';

final locator = GetIt.instance;

void setupLocator(Storage storage) {
  locator.registerSingleton<Storage>(storage);
}
