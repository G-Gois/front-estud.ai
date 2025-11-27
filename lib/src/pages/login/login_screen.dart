import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/pages/login/login_controller.dart';
import 'package:estud_ai/src/pages/register/register_screen.dart';
import 'package:estud_ai/src/shared_widgets/buttons/ghost_button.dart';
import 'package:estud_ai/src/shared_widgets/buttons/primary_button.dart';
import 'package:estud_ai/src/shared_widgets/inputs/app_text_field.dart';
import 'package:estud_ai/src/shared_widgets/layout/surface_card.dart';
import 'package:estud_ai/src/utils/form/validators.dart';
import 'package:estud_ai/src/pages/home/home_screen.dart';
import 'package:estud_ai/src/utils/nav/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final notifier = ref.read(loginControllerProvider.notifier);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await notifier.submit();

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        SlideUpRoute(page: const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final notifier = ref.read(loginControllerProvider.notifier);
    final isWide = context.screenSize.width > 720;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                          LucideIcons.sparkles,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Estud.ai',
                        style: context.textTheme.displayMedium?.copyWith(
                          color: AppColors.textMain,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Entre para continuar.',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Inputs
                  AppTextField(
                    label: 'E-mail',
                    hintText: 'nome@exemplo.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    onChanged: notifier.updateEmail,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Senha',
                    hintText: '••••••••',
                    controller: _passwordController,
                    obscureText: state.obscurePassword,
                    textInputAction: TextInputAction.done,
                    validator: (value) => Validators.minLength(
                      value,
                      6,
                      field: 'Senha',
                    ),
                    onChanged: notifier.updatePassword,
                    suffix: IconButton(
                      onPressed: notifier.togglePasswordVisibility,
                      icon: Icon(
                        state.obscurePassword
                            ? LucideIcons.eye
                            : LucideIcons.eyeOff,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Actions
                  PrimaryButton(
                    label: 'ENTRAR',
                    isLoading: state.isLoading,
                    onPressed: _handleSubmit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GhostButton(
                    label: 'CRIAR CONTA',
                    onPressed: () async {
                      final created = await Navigator.push<bool>(
                        context,
                        SlideUpRoute(page: const RegisterScreen()),
                      );
                      if (!context.mounted) return;
                      if (created == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conta criada, faça login'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  ),

                  // Error Feedback
                  if (state.error != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.error),
                          borderRadius: BorderRadius.zero,
                        ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.alertCircle,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'E-mail ou senha inválidos',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
