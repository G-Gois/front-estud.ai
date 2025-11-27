import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/shared_widgets/buttons/primary_button.dart';
import 'package:estud_ai/src/shared_widgets/inputs/app_text_field.dart';
import 'package:estud_ai/src/utils/auth/auth_provider.dart';
import 'package:estud_ai/src/utils/form/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _senhaController;
  late final TextEditingController _dataController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
    _dataController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = ref.read(authSessionProvider.notifier);
    final authState = ref.read(authSessionProvider);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await auth.register(
      nomeCompleto: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text.trim(),
      dataNascimento: _dataController.text.trim().isEmpty
          ? null
          : _dataController.text.trim(),
    );

    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro concluido'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error ?? 'Erro ao cadastrar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionProvider);
    final isWide = context.screenSize.width > 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 520 : 420),
            child: Card(
              color: AppColors.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppColors.borderSoft),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.userPlus,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Registro',
                            style: context.textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: 'Nome completo',
                        hintText: 'Maria Souza',
                        controller: _nomeController,
                        validator: (v) => Validators.required(
                          v,
                          field: 'Nome completo',
                        ),
                        prefixIcon: const Icon(LucideIcons.user, size: 18),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'E-mail',
                        hintText: 'voce@estud.ai',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        prefixIcon: const Icon(LucideIcons.mail, size: 18),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Senha',
                        hintText: '********',
                        controller: _senhaController,
                        obscureText: true,
                        validator: (v) => Validators.minLength(
                          v,
                          6,
                          field: 'Senha',
                        ),
                        prefixIcon: const Icon(LucideIcons.lock, size: 18),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Data de nascimento (YYYY-MM-DD)',
                        hintText: '1995-05-10',
                        controller: _dataController,
                        keyboardType: TextInputType.datetime,
                        prefixIcon: const Icon(LucideIcons.calendar, size: 18),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: 'Criar conta',
                        isLoading: authState.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
