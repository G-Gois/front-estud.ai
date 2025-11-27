import 'package:estud_ai/src/backend/api_requests/repository_provider.dart';
import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/pages/questionario/questionario_screen.dart';
import 'package:estud_ai/src/shared_widgets/buttons/primary_button.dart';
import 'package:estud_ai/src/utils/nav/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ResumoQuestionarioScreen extends ConsumerStatefulWidget {
  const ResumoQuestionarioScreen({
    super.key,
    required this.summary,
    required this.conteudoId,
  });

  final Map<String, dynamic> summary;
  final String conteudoId;

  @override
  ConsumerState<ResumoQuestionarioScreen> createState() =>
      _ResumoQuestionarioScreenState();
}

class _ResumoQuestionarioScreenState
    extends ConsumerState<ResumoQuestionarioScreen> {
  bool isCreatingNext = false;

  @override
  Widget build(BuildContext context) {
    final resumo = widget.summary['resumo']?.toString() ??
        widget.summary['resumo_questionario']?.toString() ??
        'Resumo não disponível';
    final acertos = widget.summary['acertos'];
    final erros = widget.summary['erros'];
    final total = widget.summary['total_perguntas'];
    final perc = widget.summary['porcentagem_acerto'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Resumo',
          style: context.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (total != null || acertos != null || perc != null) ...[
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        children: [
                          if (total != null)
                            _Badge(
                              label: 'TOTAL: $total',
                            ),
                          if (acertos != null)
                            _Badge(
                              label: 'ACERTOS: $acertos',
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderColor: AppColors.success,
                              textColor: AppColors.success,
                            ),
                          if (erros != null)
                            _Badge(
                              label: 'ERROS: $erros',
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderColor: AppColors.error,
                              textColor: AppColors.error,
                            ),
                          if (perc != null)
                            _Badge(
                              label: '$perc%',
                              color: AppColors.textMain,
                              textColor: Colors.white,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    Text(
                      'Desempenho',
                      style: context.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      resumo,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderSoft)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: isCreatingNext ? null : _continuarEstudando,
                      label: isCreatingNext
                          ? 'GERANDO...'
                          : 'CONTINUAR ESTUDANDO',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderSoft),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('VOLTAR PARA O CONTEÚDO'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continuarEstudando() async {
    if (isCreatingNext) return;
    setState(() => isCreatingNext = true);

    final choice = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Próximo passo',
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                label: 'MODO PROGRESSÃO',
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('MODO FIXAÇÃO'),
              ),
            ],
          ),
        );
      },
    );

    if (choice == null) {
      setState(() => isCreatingNext = false);
      return;
    }

    final repo = ref.read(contentRepositoryProvider);
    final result = await repo.gerarNovoQuestionario(
      widget.conteudoId,
      progressao: choice,
    );

    if (!mounted) return;
    final newId = result.data?['data']?['questionario_id']?.toString();
    setState(() => isCreatingNext = false);

    if (result.isSuccess && newId != null && newId.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        SlideUpRoute(
          page: QuestionarioScreen(
            questionarioId: newId,
            conteudoId: widget.conteudoId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Erro ao gerar questionário'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    this.color,
    this.borderColor,
    this.textColor,
  });

  final String label;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color ?? AppColors.backgroundSoft,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor ?? Colors.transparent),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: textColor ?? AppColors.textMain,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
