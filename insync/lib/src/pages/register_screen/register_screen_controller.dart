import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/backend/api_requests/api_requests.dart';
import 'package:insync/src/backend/api_requests/api_response.dart';
import 'package:insync/src/utils/auth/auth_service.dart';
import 'package:insync/src/utils/mixin/set_state_mixin.dart';
import 'package:insync/src/utils/nav/app_routes.dart';
import 'package:insync/src/utils/storage/storage.dart';
import 'package:insync/src/utils/storage/storage_keys.dart';
import 'package:insync/src/utils/storage/storage_provider.dart';

class RegisterScreenController extends ChangeNotifier with SetStateMixin {
  RegisterScreenController({
    required this.context,
    required this.storage,
  });

  final BuildContext context;
  final Storage storage;

  bool isLoading = false;
  String? errorMessage;

  String _getDeviceTimezone() {
    try {
      // Usa a variável de ambiente TZ ou nome do timezone do sistema
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux)) {
        // Para mobile/desktop, tenta obter da variável de ambiente
        final envTimezone = Platform.environment['TZ'];
        if (envTimezone != null && envTimezone.isNotEmpty) {
          return envTimezone;
        }
      }

      // Fallback: usa o offset para mapear para timezones IANA comuns
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes % 60;

      // Mapeamento de offsets para os timezones IANA mais comuns
      final offsetKey = '${hours}_$minutes';
      final timezoneMap = {
        '-3_0': 'America/Sao_Paulo',    // BRT/BRST
        '-5_0': 'America/New_York',     // EST/EDT
        '-6_0': 'America/Chicago',      // CST/CDT
        '-7_0': 'America/Denver',       // MST/MDT
        '-8_0': 'America/Los_Angeles',  // PST/PDT
        '0_0': 'Europe/London',         // GMT/BST
        '1_0': 'Europe/Paris',          // CET/CEST
        '2_0': 'Europe/Athens',         // EET/EEST
        '3_0': 'Europe/Moscow',         // MSK
        '5_30': 'Asia/Kolkata',         // IST
        '8_0': 'Asia/Shanghai',         // CST
        '9_0': 'Asia/Tokyo',            // JST
        '10_0': 'Australia/Sydney',     // AEST/AEDT
        '12_0': 'Pacific/Auckland',     // NZST/NZDT
      };

      return timezoneMap[offsetKey] ?? 'Etc/GMT${hours >= 0 ? '+' : ''}${-hours}';
    } catch (e) {
      debugPrint('Error getting timezone: $e');
      return 'UTC';
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 1. Registra no Auth (MS-Auth)
      final authResponse = await ApiRequests.auth.register(
        email: email,
        password: password,
      );

      if (authResponse is ErrorApiResponse) {
        final error = (authResponse as ErrorApiResponse).errorMessage;
        setState(() {
          isLoading = false;
          errorMessage = error;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final registerData = (authResponse as SuccessApiResponse).data;

      // 2. Criar user-resource com a lista de recursos
      final userResourceResponse = await ApiRequests.auth.createUserResource(
        userId: registerData.userId,
      );

      if (userResourceResponse is ErrorApiResponse) {
        debugPrint('Error creating user-resource: ${(userResourceResponse as ErrorApiResponse).errorMessage}');
      }

      // 3. Login to get token
      final loginResponse = await ApiRequests.auth.login(
        email: email,
        password: password,
      );

      if (loginResponse is ErrorApiResponse) {
        final error = (loginResponse as ErrorApiResponse).errorMessage;
        setState(() {
          isLoading = false;
          errorMessage = 'Account created, but error logging in: $error';
        });
        return;
      }

      final loginData = (loginResponse as SuccessApiResponse).data;

      // Save token
      final expiresAt = DateTime.now().add(Duration(seconds: loginData.expiresIn));
      await AuthService().saveAuthToken(loginData.token, expiresAt);

      // 4. Create user in InSync
      final timezone = _getDeviceTimezone();
      final insyncResponse = await ApiRequests.insync.createUser(
        name: name,
        email: email,
        timezone: timezone,
      );

      if (insyncResponse is ErrorApiResponse) {
        final error = (insyncResponse as ErrorApiResponse).errorMessage;
        debugPrint('Error creating user in InSync: $error');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning: $error'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // 5. Save user data to storage
      await storage.save(AppStorageKey.userId.key, loginData.userId);
      await storage.save(AppStorageKey.userName.key, name);
      await storage.save(AppStorageKey.email.key, email);

      setState(() => isLoading = false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

final registerScreenControllerProvider =
    ChangeNotifierProvider.family<RegisterScreenController, BuildContext>(
  (ref, context) {
    final storage = ref.watch(storageManagerProvider);
    return RegisterScreenController(
      context: context,
      storage: storage,
    );
  },
);
