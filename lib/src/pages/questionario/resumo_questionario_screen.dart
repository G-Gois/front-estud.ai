import 'package:estud_ai/src/backend/api_requests/repository_provider.dart';
import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/pages/questionario/questionario_screen.dart';
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
        'Resumo nao disponivel';
    final acertos = widget.summary['acertos'];
    final erros = widget.summary['erros'];
    final total = widget.summary['total_perguntas'];
    final perc = widget.summary['porcentagem_acerto'];

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (total != null || acertos != null || perc != null) ...[
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (total != null)
                      _Badge(
                        icon: LucideIcons.helpCircle,
                        label: 'Total: $total',
                        color: AppColors.backgroundSoft,
                        darkText: true,
                      ),
                    if (acertos != null)
                      _Badge(
                        icon: LucideIcons.check,
                        label: 'Acertos: $acertos',
                        color: AppColors.accentGreen.withValues(alpha: 0.14),
                        darkText: true,
                      ),
                    if (erros != null)
                      _Badge(
                        icon: LucideIcons.x,
                        label: 'Erros: $erros',
                        color: AppColors.error.withValues(alpha: 0.1),
                        darkText: true,
                      ),
                    if (perc != null)
                      _Badge(
                        icon: LucideIcons.percent,
                        label: '$perc%',
                        color: AppColors.secondaryGreenLight,
                        darkText: true,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    resumo,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Parar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isCreatingNext ? null : _continuarEstudando,
                      child: isCreatingNext
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Continuar estudando'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Proximo questionario',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(LucideIcons.trendingUp),
                label: const Text('Modo progressao'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(ctx).pop(false),
                icon: const Icon(LucideIcons.repeat),
                label: const Text('Modo fixacao'),
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
          content: Text(result.message ?? 'Erro ao gerar questionario'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    this.color,
    this.darkText = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color ?? AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: darkText ? AppColors.textMain : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: darkText ? AppColors.textMain : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
