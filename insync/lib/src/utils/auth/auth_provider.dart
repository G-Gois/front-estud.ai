import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/utils/auth/auth_service.dart';

final authNotifierProvider = ChangeNotifierProvider<AuthService>(
  (ref) => AuthService(),
);
