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
          content: Text('Cadastro concluído'),
          backgroundColor: AppColors.success,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 400 : 360),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: const Icon(
                          LucideIcons.userPlus,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Criar conta',
                        style: context.textTheme.displayMedium?.copyWith(
                          color: AppColors.textMain,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Preencha seus dados abaixo.',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Inputs
                  AppTextField(
                    label: 'Nome completo',
                    hintText: 'Maria Souza',
                    controller: _nomeController,
                    validator: (v) => Validators.required(
                      v,
                      field: 'Nome completo',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'E-mail',
                    hintText: 'voce@estud.ai',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Senha',
                    hintText: '••••••••',
                    controller: _senhaController,
                    obscureText: true,
                    validator: (v) => Validators.minLength(
                      v,
                      6,
                      field: 'Senha',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Data de nascimento',
                    hintText: 'YYYY-MM-DD',
                    controller: _dataController,
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Actions
                  PrimaryButton(
                    label: 'CRIAR CONTA',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
