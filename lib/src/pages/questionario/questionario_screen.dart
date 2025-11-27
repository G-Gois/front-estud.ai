import 'package:estud_ai/src/backend/api_requests/repository_provider.dart';
import 'package:estud_ai/src/backend/schema/questionario_schema.dart';
import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/pages/questionario/resumo_questionario_screen.dart';
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
      appBar: AppBar(
        title: const Text('Questionario'),
      ),
      body: SafeArea(
        child: asyncQuest.when(
          data: (data) {
            final schema = data['schema'] as QuestionarioSchema;
            final raw = data['raw'] as Map<String, dynamic>? ?? {};
            final perguntas =
                (raw['perguntas'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
            if (perguntas.isEmpty) {
              return const Center(child: Text('Nenhuma pergunta neste questionario'));
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

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGreenLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Pergunta ${currentIndex + 1}/${perguntas.length}',
                          style: context.textTheme.labelMedium,
                        ),
                      ),
                      const Spacer(),
                      if (schema.modo != null)
                        Text(
                          schema.modo!,
                          style: context.textTheme.labelMedium,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    pergunta['enunciado']?.toString() ?? '',
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...opcoes.map(
                    (op) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: RadioListTile<String>(
                        value: op['id']?.toString() ?? '',
                        groupValue: selectedOption,
                        onChanged: showFeedback
                            ? null
                            : (value) => setState(() => selectedOption = value),
                        title: Text(
                          op['texto']?.toString() ?? op['texto_opcao']?.toString() ?? '',
                        ),
                      ),
                    ),
                  ),
                  if (showFeedback)
                    SurfaceCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                acertou ? LucideIcons.checkCircle : LucideIcons.xCircle,
                                color: acertou ? AppColors.accentGreen : AppColors.error,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                acertou ? 'Resposta correta' : 'Resposta errada',
                                style: context.textTheme.titleSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Correta: ${correta['texto'] ?? correta['texto_opcao'] ?? ''}',
                            style: context.textTheme.bodyMedium,
                          ),
                          if (pergunta['explicacao'] != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Explicacao:',
                              style: context.textTheme.titleSmall,
                            ),
                            Text(
                              pergunta['explicacao']?.toString() ?? '',
                              style: context.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: isFinishing
                        ? null
                        : () => _handleAction(perguntas, pergunta),
                    child: Text(
                      isFinishing
                          ? 'Finalizando...'
                          : _isLast(perguntas)
                              ? (showFeedback ? 'Finalizar' : 'Confirmar')
                              : (showFeedback ? 'Proxima' : 'Confirmar'),
                    ),
                  ),
                ],
              ),
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
            content: Text('Selecione uma opcao'),
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
