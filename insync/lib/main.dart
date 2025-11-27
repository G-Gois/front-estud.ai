import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:insync/src/core/service_locator.dart';
import 'package:insync/src/core/theme/app_theme.dart';
import 'package:insync/src/pages/welcome_screen/welcome_screen.dart';
import 'package:insync/src/utils/auth/auth_provider.dart';
import 'package:insync/src/utils/auth/auth_service.dart';
import 'package:insync/src/utils/nav/app_routes.dart';
import 'package:insync/src/utils/nav/modern_slide_route.dart';
import 'package:insync/src/utils/storage/storage_provider.dart';
import 'package:insync/src/utils/storage/storage_service.dart';
import 'package:insync/src/utils/theme/theme_provider.dart';

Future<ProviderContainer> initializeApp() async {
  // Inicializa o Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente
  await dotenv.load(fileName: ".env");

  // Configura orientação
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1a1a1a),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializa o storage
  final storageService = StorageService();
  await storageService.init();

  // Cria o ProviderContainer e sobreescreve o storageProvider
  final container = ProviderContainer(
    overrides: [
      storageProvider.overrideWithValue(storageService),
    ],
  );

  // Pega a instância da fachada Storage
  final storageFacade = container.read(storageManagerProvider);

  // Registra no Service Locator
  setupLocator(storageFacade);

  return container;
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final container = await initializeApp();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends ConsumerState<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _wasAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider);

    // Escuta mudanças no estado de autenticação
    ref.listen<AuthService>(authNotifierProvider, (previous, next) {
      debugPrint(
        'Auth state changed: $_wasAuthenticated -> ${next.isAuthenticatedNotifier}',
      );
      if (_wasAuthenticated && next.isAuthenticatedNotifier == false) {
        debugPrint('User logged out, navigating to welcome screen');
        _navigatorKey.currentState?.pushAndRemoveUntil(
          ModernSlideRoute(child: const WelcomeScreen()),
          (route) => false,
        );
      }

      _wasAuthenticated = next.isAuthenticatedNotifier;
    });

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'InSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
