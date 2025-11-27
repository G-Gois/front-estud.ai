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

class LoginScreenController extends ChangeNotifier with SetStateMixin {
  LoginScreenController({
    required this.context,
    required this.storage,
  });

  final BuildContext context;
  final Storage storage;

  bool isLoading = false;
  String? errorMessage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiRequests.auth.login(
        email: email,
        password: password,
      );

      if (response is SuccessApiResponse) {
        final loginData = (response as SuccessApiResponse).data;

        // Calculate expiration date based on expiresIn (seconds)
        final expiresAt = DateTime.now().add(Duration(seconds: loginData.expiresIn));

        // Save token
        await AuthService().saveAuthToken(
          loginData.token,
          expiresAt,
        );

        // Fetch complete user data
        final userResponse = await ApiRequests.auth.readUser(userId: loginData.userId);

        String userName = email; // Fallback
        if (userResponse is SuccessApiResponse) {
          final userData = (userResponse as SuccessApiResponse).data;
          userName = userData['login'] ?? email;
        }

        // Save user data
        await storage.save(AppStorageKey.userId.key, loginData.userId);
        await storage.save(AppStorageKey.userName.key, userName);
        await storage.save(AppStorageKey.email.key, email);

        setState(() => isLoading = false);

        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      } else if (response is ErrorApiResponse) {
        final error = (response as ErrorApiResponse).errorMessage;
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

  Future<void> recoverPassword({required String email}) async {
    try {
      final response = await ApiRequests.auth.recoverPassword(email: email);

      if (response is SuccessApiResponse) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A new password has been sent to your email!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else if (response is ErrorApiResponse) {
        final error = (response).errorMessage;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

final loginScreenControllerProvider =
    ChangeNotifierProvider.family<LoginScreenController, BuildContext>(
  (ref, context) {
    final storage = ref.watch(storageManagerProvider);
    return LoginScreenController(
      context: context,
      storage: storage,
    );
  },
);
