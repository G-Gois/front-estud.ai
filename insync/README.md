# InSync

Aplicativo InSync - Sincronização e gestão

## 🚀 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada
└── src/
    ├── backend/             # Camada de API e modelos
    │   ├── api_requests/    # Requisições e serviços
    │   │   ├── api_requests.dart
    │   │   ├── api_response.dart
    │   │   ├── api_service.dart
    │   │   ├── device_utils.dart
    │   │   └── models/      # Modelos de API
    │   └── schema/          # Schemas adicionais
    │
    ├── core/               # Configurações centrais
    │   ├── constants/      # Constantes (cores, sizing, strings, assets, textstyle)
    │   ├── localization/   # Sistema de i18n
    │   ├── theme/         # Tema do app
    │   └── service_locator.dart
    │
    ├── pages/             # Telas do app
    │   ├── splash_screen/
    │   ├── welcome_screen/
    │   ├── login_screen/
    │   └── [outras_screens]/
    │
    ├── shared_widgets/    # Widgets reutilizáveis globais
    │   ├── button/
    │   ├── card/
    │   ├── loading/
    │   ├── gap/
    │   └── [outros]/
    │
    ├── shared_local_widgets/ # Widgets compartilhados localmente
    │
    ├── utils/            # Utilitários
    │   ├── auth/        # Autenticação
    │   ├── nav/         # Navegação
    │   ├── storage/     # Sistema de storage
    │   ├── formatter/   # Formatadores
    │   ├── type/        # Enums e tipos
    │   └── mixin/       # Mixins utilitários
    │
    └── struct/          # Estruturas de dados auxiliares
```

## 📦 Tecnologias Utilizadas

- **Flutter SDK**: ^3.5.1
- **State Management**: Riverpod
- **API**: Dio
- **Storage**:
  - flutter_secure_storage (mobile)
  - SharedPreferences
  - LocalStorage (web)
- **DI**: GetIt
- **UI**: Google Fonts, Lucide Icons, Lottie
- **Charts**: FL Chart

## 🏗️ Padrões de Código

### Models
```dart
class ApiExampleModel {
  final String id;
  final String name;

  ApiExampleModel({
    required this.id,
    required this.name,
  });

  factory ApiExampleModel.fromJson(Map<String, dynamic> json) {
    return ApiExampleModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
```

### Controllers (Riverpod + ChangeNotifier)
```dart
class ExampleController extends ChangeNotifier with SetStateMixin {
  ExampleController({required this.context, required this.storage});

  final BuildContext context;
  final Storage storage;

  bool isLoading = false;

  void setState(VoidCallback update) {
    update();
    notifyListeners();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    // ... lógica
    setState(() => isLoading = false);
  }
}

final exampleControllerProvider =
    ChangeNotifierProvider.family<ExampleController, BuildContext>(
  (ref, context) {
    final storage = ref.watch(storageManagerProvider);
    return ExampleController(context: context, storage: storage);
  },
);
```

### Telas (ConsumerStatefulWidget)
```dart
class ExampleScreen extends ConsumerStatefulWidget {
  const ExampleScreen({super.key});

  @override
  ConsumerState<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends ConsumerState<ExampleScreen> {
  ExampleController get controller =>
      ref.watch(exampleControllerProvider(context));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.isLoading
          ? LoadingIndicator()
          : ContentWidget(),
    );
  }
}
```

## 🔐 Sistema de Autenticação

- AuthService singleton com timer automático (valida token a cada 5s)
- Storage seguro com criptografia (mobile)
- Provider Riverpod para reatividade
- Logout automático em caso de token expirado

## 💾 Sistema de Storage

3 tipos de storage:
- **Secure**: Criptografado (tokens, senhas)
- **Regular**: SharedPreferences normal
- **Temp**: Temporário com prefixo `temp_`

```dart
// Exemplo de uso
await storage.saveSecure('token', token);
final token = await storage.getSecure<String>('token');
```

## 🎨 Design System

- **Cores**: `AppColors` (primary, secondary, success, error, etc)
- **Tamanhos**: `AppSizing` (padding, spacing, border radius)
- **Textos**: `AppTextStyle` (h1-h5, body, button, caption)
- **Strings**: `AppStrings` (organizadas por feature)
- **Assets**: `AppAssets` (paths organizados)

## 🚦 Como Começar

1. Instalar dependências:
```bash
flutter pub get
```

2. Configurar .env:
```
API_BASE_URL=https://sua-api.com
```

3. Rodar o app:
```bash
flutter run
```

## 📝 Nomenclatura

- Screens: `screen_name_screen.dart`
- Controllers: `screen_name_screen_controller.dart`
- Models: `api_resource_operation_model.dart`
- Widgets: `widget_name.dart`
- Services: `service_name_service.dart`

## 🔄 Próximos Passos

- [ ] Implementar API de login
- [ ] Criar tela de home
- [ ] Adicionar mais widgets compartilhados
- [ ] Implementar sistema de notificações
- [ ] Adicionar testes unitários

---

Desenvolvido com ❤️ usando Flutter
