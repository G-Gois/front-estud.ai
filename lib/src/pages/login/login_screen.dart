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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 460 : 420),
              child: SurfaceCard(
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
                              LucideIcons.sparkles,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estud.ai',
                                style: context.textTheme.titleLarge,
                              ),
                              Text(
                                'Entre para continuar',
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: 'E-mail',
                        hintText: 'voce@estud.ai',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        onChanged: notifier.updateEmail,
                        prefixIcon: const Icon(
                          LucideIcons.mail,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Senha',
                        hintText: '********',
                        controller: _passwordController,
                        obscureText: state.obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: (value) => Validators.minLength(
                          value,
                          6,
                          field: 'Senha',
                        ),
                        onChanged: notifier.updatePassword,
                        prefixIcon: const Icon(
                          LucideIcons.lock,
                          size: 18,
                        ),
                        suffix: IconButton(
                          onPressed: notifier.togglePasswordVisibility,
                          icon: Icon(
                            state.obscurePassword
                                ? LucideIcons.eye
                                : LucideIcons.eyeOff,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: 'Entrar',
                        isLoading: state.isLoading,
                        onPressed: _handleSubmit,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GhostButton(
                        label: 'Criar conta',
                        onPressed: () async {
                          final created = await Navigator.push<bool>(
                            context,
                            SlideUpRoute(page: const RegisterScreen()),
                          );
                          if (!context.mounted) return;
                          if (created == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Conta criada, faca login'),
                                backgroundColor: AppColors.accentGreen,
                              ),
                            );
                          }
                        },
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Login invalido',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
