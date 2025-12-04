import 'package:estud_ai/src/backend/api_requests/repository_provider.dart';
import 'package:estud_ai/src/backend/schema/conteudo_schema.dart';
import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:estud_ai/src/pages/content/content_detail_screen.dart';
import 'package:estud_ai/src/shared_widgets/buttons/primary_button.dart';
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
    final isWide = context.screenSize.width > 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(conteudosProvider.future),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estud.ai',
                              style: context.textTheme.displayMedium?.copyWith(
                                color: AppColors.textMain,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Seus conteúdos',
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _showCreate(context, ref),
                          icon: const Icon(LucideIcons.plus, size: 28),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.textMain,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
              asyncConteudos.when(
                data: (list) {
                  if (list.isEmpty) {
                    return SliverFillRemaining(
                      child: _EmptyState(onCreate: () => _showCreate(context, ref)),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisSpacing: AppSpacing.lg,
                        crossAxisSpacing: AppSpacing.lg,
                        mainAxisExtent: 180,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final c = list[index];
                          return _ConteudoCard(
                            conteudo: c,
                            onTap: () => Navigator.push(
                              context,
                              SlideUpRoute(
                                page: ContentDetailScreen(conteudoId: c.id),
                              ),
                            ),
                          );
                        },
                        childCount: list.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Erro ao carregar',
                          style: context.textTheme.titleMedium,
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
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreate(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final isLoadingNotifier = ValueNotifier<bool>(false);
    final repo = ref.read(contentRepositoryProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (_) {
        return ValueListenableBuilder<bool>(
          valueListenable: isLoadingNotifier,
          builder: (context, isLoading, _) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                top: AppSpacing.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Novo conteúdo',
                    style: context.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'O que você quer aprender hoje?',
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: controller,
                            maxLines: 3,
                            enabled: !isLoading,
                            style: context.textTheme.bodyLarge,
                            decoration: const InputDecoration(
                              hintText: 'Ex: Resumo sobre a Revolução Francesa...',
                              filled: true,
                              fillColor: AppColors.backgroundSoft,
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (controller.text.length < 10)
                                Text(
                                  'Mínimo 10 caracteres',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: AppColors.error,
                                  ),
                                )
                              else
                                const SizedBox(),
                              Text(
                                '${controller.text.length} / 10',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: controller.text.length < 10
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? null
                          : () async {
                              final text = controller.text.trim();
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);

                              if (text.length < 10) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Descreva com mais detalhes (mínimo 10 caracteres).'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              isLoadingNotifier.value = true;

                              final res = await repo.criarConteudo(text);

                              if (!context.mounted) return;
                              isLoadingNotifier.value = false;

                              if (res.isSuccess) {
                                navigator.pop(); // Close only on success
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Conteúdo criado'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                ref.invalidate(conteudosProvider);

                                final newId = res.data?['id']?.toString();
                                if (newId != null) {
                                  navigator.push(
                                    SlideUpRoute(
                                      page: ContentDetailScreen(conteudoId: newId),
                                    ),
                                  );
                                }
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(res.message ?? 'Erro ao criar'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                      label: 'CRIAR CONTEÚDO',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    isLoadingNotifier.dispose();
    controller.dispose();
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
      child: Hero(
        tag: 'conteudo_${conteudo.id}',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderSoft),
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSoft,
                        borderRadius: BorderRadius.zero,
                      ),
                      child: const Icon(LucideIcons.bookOpen, size: 20, color: AppColors.textMain),
                    ),
                    const Spacer(),
                    const Icon(LucideIcons.arrowUpRight, size: 20, color: AppColors.textSecondary),
                  ],
                ),
                const Spacer(),
                Text(
                  conteudo.titulo.isEmpty ? 'Sem título' : conteudo.titulo,
                  style: context.textTheme.titleLarge?.copyWith(height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  conteudo.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone grande com fundo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.backgroundSoft,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                LucideIcons.bookOpen,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Título
            Text(
              'Nada por aqui ainda',
              style: context.textTheme.displaySmall?.copyWith(
                color: AppColors.textMain,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Descrição
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                'Comece criando seu primeiro conteúdo de estudo.\nA IA vai te ajudar a aprender de forma personalizada.',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Botão
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: PrimaryButton(
                onPressed: onCreate,
                label: 'CRIAR PRIMEIRO CONTEÚDO',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Dica
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.lightbulb,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dica: Seja específico sobre o que quer aprender',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
