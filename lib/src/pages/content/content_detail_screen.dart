import 'package:estud_ai/src/backend/api_requests/repository_provider.dart';
import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/pages/questionario/questionario_screen.dart';
import 'package:estud_ai/src/shared_widgets/layout/surface_card.dart';
import 'package:estud_ai/src/utils/nav/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

final conteudoDetalheProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(contentRepositoryProvider);
  final response = await repo.obterCompleto(id);
  if (response.isSuccess && response.data != null) {
    return response.data!;
  }
  throw Exception(response.message ?? 'Erro ao carregar conteudo');
});

class ContentDetailScreen extends ConsumerStatefulWidget {
  const ContentDetailScreen({super.key, required this.conteudoId});

  final String conteudoId;

  @override
  ConsumerState<ContentDetailScreen> createState() =>
      _ContentDetailScreenState();
}

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  final Set<String> _expanded = {};
  bool _isCreatingNext = false;

  @override
  Widget build(BuildContext context) {
    final asyncConteudo = ref.watch(conteudoDetalheProvider(widget.conteudoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conteudo'),
      ),
      body: SafeArea(
        child: asyncConteudo.when(
          data: (data) {
            final conteudo = data['data'] as Map<String, dynamic>? ?? {};
            final titulo = conteudo['titulo']?.toString() ?? 'Conteudo';
            final descricao = conteudo['descricao']?.toString() ?? '';
            final questionarios =
                (conteudo['questionarios'] as List<dynamic>? ?? [])
                    .cast<Map<String, dynamic>>();

            final sorted = [...questionarios];
            sorted.sort(
              (a, b) => (a['ordem'] ?? 0).compareTo(b['ordem'] ?? 0),
            );
            final ultimo = sorted.isNotEmpty ? sorted.last : null;
            final ultimoFinalizado = (ultimo?['finalizado'] ?? false) == true;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      Text(
                        titulo,
                        style: context.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        descricao,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ...sorted.map(
                        (q) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _QuestionarioCard(
                            data: q,
                            conteudoId: widget.conteudoId,
                            expanded: _expanded.contains(
                              q['id']?.toString() ??
                                  q['questionario_id']?.toString() ??
                                  '',
                            ),
                            onToggle: (id) {
                              setState(() {
                                if (_expanded.contains(id)) {
                                  _expanded.remove(id);
                                } else {
                                  _expanded.add(id);
                                }
                              });
                            },
                            onTap: () async {
                              final id = q['id']?.toString() ??
                                  q['questionario_id']?.toString() ??
                                  '';
                              if (id.isEmpty) return;
                              final result = await Navigator.of(context).push<bool>(
                                SlideUpRoute(
                                  page: QuestionarioScreen(
                                    questionarioId: id,
                                    conteudoId: widget.conteudoId,
                                  ),
                                ),
                              );
                              if (result == true) {
                                ref.refresh(conteudoDetalheProvider(widget.conteudoId));
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ultimoFinalizado ? AppSpacing.xxl : 0,
                      ),
                    ],
                  ),
                ),
                if (ultimoFinalizado)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: ElevatedButton.icon(
                        onPressed:
                            _isCreatingNext ? null : _continuarEstudando,
                        icon: _isCreatingNext
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(LucideIcons.trendingUp),
                        label: Text(
                          _isCreatingNext
                              ? 'Gerando...'
                              : 'Continuar estudos',
                        ),
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
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () =>
                      ref.refresh(conteudoDetalheProvider(widget.conteudoId)),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continuarEstudando() async {
    if (_isCreatingNext) return;
    setState(() {
      _isCreatingNext = true;
    });

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

    if (choice == null) return;

    final contentRepo = ref.read(contentRepositoryProvider);
    final result = await contentRepo.gerarNovoQuestionario(
      widget.conteudoId,
      progressao: choice,
    );

    final newId = result.data?['data']?['questionario_id']?.toString();
    if (!mounted) return;

    if (result.isSuccess && newId != null && newId.isNotEmpty) {
      setState(() {
        _isCreatingNext = false;
      });
      Navigator.of(context).push(
        SlideUpRoute(
          page: QuestionarioScreen(
            questionarioId: newId,
            conteudoId: widget.conteudoId,
          ),
        ),
      );
    } else {
      setState(() {
        _isCreatingNext = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Erro ao gerar questionario'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _QuestionarioCard extends StatelessWidget {
  const _QuestionarioCard({
    required this.data,
    required this.conteudoId,
    required this.expanded,
    required this.onToggle,
    required this.onTap,
  });

  final Map<String, dynamic> data;
  final String conteudoId;
  final bool expanded;
  final void Function(String id) onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final finalizado = data['finalizado'] == true;
    final resumo = data['resumo_questionario']?.toString();
    final titulo = data['titulo']?.toString() ?? 'Questionario';
    final descricao = data['descricao']?.toString() ?? '';
    final modo = data['modo']?.toString();
    final ordem = data['ordem']?.toString();
    final id =
        data['id']?.toString() ?? data['questionario_id']?.toString() ?? '';

    return GestureDetector(
      onTap: finalizado ? () => onToggle(id) : onTap,
      child: SurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: finalizado
                        ? AppColors.accentGreen
                        : AppColors.secondaryGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    finalizado ? LucideIcons.check : LucideIcons.loader2,
                    color: finalizado ? Colors.white : AppColors.textMain,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    titulo,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                if (ordem != null)
                  Text(
                    '#$ordem',
                    style: context.textTheme.labelMedium,
                  ),
                IconButton(
                  onPressed: () {
                    if (finalizado) {
                      onToggle(id);
                      return;
                    }
                    onTap();
                  },
                  icon: Icon(
                    finalizado
                        ? (expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown)
                        : LucideIcons.chevronRight,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              descricao,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                if (modo != null)
                  _Badge(
                    icon: LucideIcons.slidersHorizontal,
                    label: modo,
                  ),
                _Badge(
                  icon:
                      finalizado ? LucideIcons.checkCircle : LucideIcons.hourglass,
                  label: finalizado ? 'Finalizado' : 'Em aberto',
                  color: finalizado
                      ? AppColors.accentGreen
                      : AppColors.secondaryGreenLight,
                  darkText: !finalizado,
                ),
              ],
            ),
            if (finalizado && resumo != null) ...[
              const SizedBox(height: AppSpacing.sm),
              if (expanded) ...[
                const Divider(height: 1, color: AppColors.borderSoft),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Resumo',
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  resumo,
                  style: context.textTheme.bodyMedium,
                ),
              ] else
                TextButton(
                  onPressed: () => onToggle(id),
                  child: const Text('Ver resumo'),
                ),
            ],
          ],
        ),
      ),
    );
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
            style: context.textTheme.labelMedium?.copyWith(
              color: darkText ? AppColors.textMain : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
