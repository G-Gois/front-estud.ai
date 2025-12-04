import 'package:estud_ai/src/backend/api_requests/api_client.dart';
import 'package:estud_ai/src/core/service_locator.dart';
import 'package:estud_ai/src/core/theme/app_theme.dart';
import 'package:estud_ai/src/pages/login/login_screen.dart';
import 'package:estud_ai/src/utils/storage/storage_service.dart';
import 'package:estud_ai/src/utils/storage/storage_keys.dart';
import 'package:estud_ai/src/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storageService = StorageService();
  await storageService.init();

  final apiClient = ApiClient(baseUrl: dotenv.env['API_BASE_URL'] ?? '');
  final savedToken = storageService.read(StorageKeys.authToken);
  if (savedToken != null && savedToken.isNotEmpty) {
    apiClient.setAuthToken(savedToken);
  }
  setupLocator(apiClient: apiClient, storageService: storageService);

  runApp(const ProviderScope(child: EstudAiApp()));
}

class EstudAiApp extends ConsumerWidget {
  const EstudAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Estud.ai',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData.dark(useMaterial3: true),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
      home: const LoginScreen(),
    );
  }
}
