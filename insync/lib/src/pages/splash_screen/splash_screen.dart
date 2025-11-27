import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/utils/auth/auth_provider.dart';
import 'package:insync/src/utils/nav/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait a bit to show the splash screen
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    if (!mounted) return;

    final authService = ref.read(authNotifierProvider);

    // Verifica se existe token válido
    final token = await authService.getAuthToken();
    final isAuthenticated = token != null;

    if (!mounted) return;

    if (isAuthenticated) {
      _navigateToHome();
    } else {
      _navigateToWelcome();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _navigateToWelcome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           
            const SizedBox(height: 24),
            Text(
              'inSync',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
