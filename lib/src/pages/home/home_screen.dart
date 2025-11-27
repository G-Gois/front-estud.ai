import 'package:estud_ai/src/backend/api_requests/repository_provider.dart';
import 'package:estud_ai/src/backend/schema/conteudo_schema.dart';
import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/pages/content/content_detail_screen.dart';
import 'package:estud_ai/src/shared_widgets/layout/surface_card.dart';
import 'package:estud_ai/src/utils/nav/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

final conteudosProvider =
    FutureProvider.autoDispose<List<ConteudoSchema>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  final response = await repo.listar();
  if (response.isSuccess && response.data != null) {
    return response.data!;
  }
  throw Exception(response.message ?? 'Erro ao carregar conteudos');
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConteudos = ref.watch(conteudosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: AppSpacing.xl,
        title: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.secondaryGreenLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 18,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home',
                  style: context.textTheme.titleLarge,
                ),
                Text(
                  'Conteudos recentes',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(conteudosProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xxl + 120,
            ),
            children: [
              asyncConteudos.when(
                data: (list) {
                  if (list.isEmpty) {
                    return _EmptyState(onCreate: () => _showCreate(context, ref));
                  }
                  return Column(
                    children: [
                    ...list.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ConteudoCard(
                          conteudo: c,
                          onTap: () => Navigator.push(
                            context,
                            SlideUpRoute(
                              page: ContentDetailScreen(conteudoId: c.id),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Column(
                    children: [
                      Text(
                        err.toString(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: () => ref.refresh(conteudosProvider),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 96,
          child: Center(
            child: GestureDetector(
              onTap: () => _showCreate(context, ref),
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withValues(alpha: 0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreate(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final repo = ref.read(contentRepositoryProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Novo conteudo',
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Descreva o que voce quer aprender (minimo 50 caracteres).',
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Ex: Revisao de fotossintese com questoes...',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () async {
                  final text = controller.text.trim();
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  if (text.length < 50) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Escreva pelo menos 50 caracteres.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  navigator.pop();
                  final res = await repo.criarConteudo(text);
                  if (res.isSuccess) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Conteudo criado'),
                        backgroundColor: AppColors.accentGreen,
                      ),
                    );
                    ref.invalidate(conteudosProvider);
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(res.message ?? 'Erro ao criar'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                icon: const Icon(LucideIcons.send),
                label: const Text('Enviar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConteudoCard extends StatelessWidget {
  const _ConteudoCard({
    required this.conteudo,
    required this.onTap,
  });

  final ConteudoSchema conteudo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.bookOpen,
                    size: 18,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    conteudo.titulo.isEmpty ? 'Conteudo' : conteudo.titulo,
                    style: context.textTheme.titleMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              conteudo.descricao,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium,
            ),
            if (conteudo.totalQuestionarios != null ||
                conteudo.totalPerguntas != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (conteudo.totalQuestionarios != null)
                    _Tag(
                      icon: LucideIcons.listChecks,
                      label: '${conteudo.totalQuestionarios} questionarios',
                    ),
                  if (conteudo.totalPerguntas != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _Tag(
                      icon: LucideIcons.helpCircle,
                      label: '${conteudo.totalPerguntas} perguntas',
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          LucideIcons.layers,
          size: 48,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Nenhum conteudo ainda',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Crie seu primeiro material e veja os questionarios aparecerem aqui.',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          onPressed: onCreate,
          icon: const Icon(LucideIcons.plus),
          label: const Text('Criar conteudo'),
        ),
      ],
    );
  }
}
