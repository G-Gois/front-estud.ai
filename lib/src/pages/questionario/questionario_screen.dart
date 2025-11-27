import 'package:estud_ai/src/backend/api_requests/repository_provider.dart';
import 'package:estud_ai/src/backend/schema/questionario_schema.dart';
import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/pages/questionario/resumo_questionario_screen.dart';
import 'package:estud_ai/src/shared_widgets/buttons/primary_button.dart';
import 'package:estud_ai/src/shared_widgets/layout/surface_card.dart';
import 'package:estud_ai/src/utils/nav/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

final questionarioProvider =
    FutureProvider.family.autoDispose<Map<String, dynamic>, String>(
        (ref, id) async {
  final repo = ref.watch(questionarioRepositoryProvider);
  final response = await repo.porIdCompleto(id);
  if (response.isSuccess && response.data != null) {
    final raw = response.data!;
    return {
      'schema': QuestionarioSchema.fromJson(raw),
      'raw': raw,
    };
  }
  throw Exception(response.message ?? 'Erro ao carregar questionario');
});

class QuestionarioScreen extends ConsumerStatefulWidget {
  const QuestionarioScreen({
    super.key,
    required this.questionarioId,
    required this.conteudoId,
  });

  final String questionarioId;
  final String conteudoId;

  @override
  ConsumerState<QuestionarioScreen> createState() =>
      _QuestionarioScreenState();
}

class _QuestionarioScreenState extends ConsumerState<QuestionarioScreen> {
  int currentIndex = 0;
  String? selectedOption;
  bool showFeedback = false;
  bool isFinishing = false;
  final List<Map<String, dynamic>> respostas = [];

  @override
  Widget build(BuildContext context) {
    final asyncQuest = ref.watch(questionarioProvider(widget.questionarioId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: asyncQuest.when(
          data: (data) {
            final schema = data['schema'] as QuestionarioSchema;
            final raw = data['raw'] as Map<String, dynamic>? ?? {};
            final perguntas =
                (raw['perguntas'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
            if (perguntas.isEmpty) {
              return const Center(child: Text('Nenhuma pergunta neste questionário'));
            }

            final pergunta = perguntas[currentIndex];
            final opcoes =
                (pergunta['opcoes'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
            final correta = opcoes.firstWhere(
              (o) => (o['correta'] == true),
              orElse: () => {},
            );
            final acertou = showFeedback &&
                correta.isNotEmpty &&
                selectedOption != null &&
                selectedOption == correta['id']?.toString();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textMain,
                                borderRadius: BorderRadius.zero,
                              ),
                              child: Text(
                                '${currentIndex + 1} / ${perguntas.length}',
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (schema.modo != null)
                              Text(
                                schema.modo!.toUpperCase(),
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          pergunta['enunciado']?.toString() ?? '',
                          style: context.textTheme.headlineMedium?.copyWith(
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 48),
                        ...opcoes.map(
                          (op) {
                            final id = op['id']?.toString() ?? '';
                            final isSelected = selectedOption == id;
                            final isCorrect = correta['id']?.toString() == id;
                            
                            Color borderColor = AppColors.borderSoft;
                            Color backgroundColor = Colors.white;
                            
                            if (showFeedback) {
                              if (isCorrect) {
                                borderColor = AppColors.success;
                                backgroundColor = AppColors.success.withValues(alpha: 0.1);
                              } else if (isSelected && !acertou) {
                                borderColor = AppColors.error;
                                backgroundColor = AppColors.error.withValues(alpha: 0.1);
                              }
                            } else if (isSelected) {
                              borderColor = AppColors.textMain;
                              backgroundColor = AppColors.backgroundSoft;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: GestureDetector(
                                onTap: showFeedback
                                    ? null
                                    : () => setState(() => selectedOption = id),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.zero,
                                    border: Border.all(
                                      color: borderColor,
                                      width: isSelected || (showFeedback && (isCorrect || (isSelected && !acertou))) ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          op['texto']?.toString() ?? op['texto_opcao']?.toString() ?? '',
                                          style: context.textTheme.bodyLarge?.copyWith(
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: AppColors.textMain,
                                          ),
                                        ),
                                      ),
                                      if (showFeedback && isCorrect)
                                        const Icon(LucideIcons.checkCircle, color: AppColors.success, size: 20),
                                      if (showFeedback && isSelected && !acertou)
                                        const Icon(LucideIcons.xCircle, color: AppColors.error, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (showFeedback) ...[
                          const SizedBox(height: AppSpacing.xl),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: acertou ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: acertou ? AppColors.success : AppColors.error,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      acertou ? LucideIcons.check : LucideIcons.x,
                                      color: acertou ? AppColors.success : AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      acertou ? 'Correto!' : 'Incorreto',
                                      style: context.textTheme.titleSmall?.copyWith(
                                        color: acertou ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                if (pergunta['explicacao'] != null) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    pergunta['explicacao']?.toString() ?? '',
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.borderSoft)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: isFinishing
                          ? null
                          : () => _handleAction(perguntas, pergunta),
                      label: isFinishing
                          ? 'FINALIZANDO...'
                          : _isLast(perguntas)
                              ? (showFeedback ? 'FINALIZAR' : 'CONFIRMAR')
                              : (showFeedback ? 'PRÓXIMA' : 'CONFIRMAR'),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  err.toString(),
                  style: context.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () =>
                      ref.refresh(questionarioProvider(widget.questionarioId)),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isLast(List perguntas) => currentIndex == perguntas.length - 1;

  Future<void> _handleAction(List perguntas, Map<String, dynamic> pergunta) async {
    if (!showFeedback) {
      if (selectedOption == null || selectedOption!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione uma opção'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      setState(() => showFeedback = true);
      respostas.add({
        'pergunta_id': pergunta['id'] ?? pergunta['pergunta_id'],
        'opcao_id': selectedOption,
      });
      return;
    }

    if (_isLast(perguntas)) {
      await _finalizarQuestionario();
      return;
    }

    setState(() {
      currentIndex += 1;
      selectedOption = null;
      showFeedback = false;
    });
  }

  Future<void> _finalizarQuestionario() async {
    setState(() => isFinishing = true);

    final repo = ref.read(questionarioRepositoryProvider);
    final res = await repo.finalizar(
      questionarioId: widget.questionarioId,
      respostas: respostas,
    );

    if (!mounted) return;
    setState(() => isFinishing = false);

    if (res.isSuccess) {
      final summary = res.data?['data'] as Map<String, dynamic>? ?? {};
      Navigator.of(context).pushReplacement(
        SlideUpRoute(
          page: ResumoQuestionarioScreen(
            summary: summary,
            conteudoId: widget.conteudoId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Erro ao finalizar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
