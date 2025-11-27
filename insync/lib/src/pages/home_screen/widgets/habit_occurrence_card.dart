import 'package:flutter/material.dart';
import 'package:insync/src/backend/api_requests/models/api_daily_feed_model.dart';

class HabitOccurrenceCard extends StatefulWidget {
  final ApiHabitOccurrenceModel occurrence;
  final VoidCallback? onToggle;
  final bool isUpdating;
  final bool animateEntrance; // Se deve animar a entrada

  const HabitOccurrenceCard({
    super.key,
    required this.occurrence,
    this.onToggle,
    this.isUpdating = false,
    this.animateEntrance = false,
  });

  @override
  State<HabitOccurrenceCard> createState() => _HabitOccurrenceCardState();
}

class _HabitOccurrenceCardState extends State<HabitOccurrenceCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _entranceAnimation;
  bool _isAnimating = false;
  bool _hideCardAfterAnimation = false; // Esconde card após animação de saída

  @override
  void initState() {
    super.initState();

    // Controlador para animação de saída (swipe para esquerda)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Listener para rebuild durante animação (para esconder no momento certo)
    _slideController.addListener(() {
      if (_isAnimating && mounted) {
        setState(() {}); // Force rebuild para checar valor
      }
    });

    // Controlador para animação de entrada (vem da direita)
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: widget.animateEntrance ? 0.0 : 1.0, // Anima apenas se solicitado
    );
    _entranceAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // Se deve animar entrada, executa após o primeiro frame
    if (widget.animateEntrance) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _entranceController.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(HabitOccurrenceCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // NUNCA deve chegar aqui porque a chave muda (_pending vs _completed)
    // Mas se chegar, significa que é o mesmo card que mudou de status
    // Isso não deveria acontecer com as chaves únicas
  }

  @override
  void dispose() {
    _slideController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Color _getColor() {
    try {
      // Try to convert colorTag that comes as "R,G,B"
      final colorTag = widget.occurrence.habitColor;
      if (colorTag.contains(',')) {
        final parts = colorTag.split(',');
        if (parts.length == 3) {
          final r = int.parse(parts[0].trim());
          final g = int.parse(parts[1].trim());
          final b = int.parse(parts[2].trim());
          return Color.fromARGB(255, r, g, b);
        }
      }
      // If it's already in hex format
      if (colorTag.startsWith('#')) {
        return Color(int.parse(colorTag.replaceFirst('#', '0xff')));
      }
      return const Color(0xFFA8DADC);
    } catch (e) {
      return const Color(0xFFA8DADC);
    }
  }

  Future<void> _handleTap() async {
    if (_isAnimating || widget.isUpdating || widget.onToggle == null) return;

    setState(() => _isAnimating = true);

    // Callback ANTES da animação - para iniciar processo de atualização
    widget.onToggle!();

    // Animação de saída (para a esquerda)
    await _slideController.forward();

    // ESCONDE o card IMEDIATAMENTE após animação terminar
    if (mounted) {
      setState(() => _hideCardAfterAnimation = true);
    }

    // IMPORTANTE: Este widget será destruído pelo Flutter pois a chave mudou
    // O card permanece escondido até lá - sem piscar!
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _getColor();
    final canToggle = widget.onToggle != null && !widget.isUpdating;

    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Barra de cor lateral
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.occurrence.habitName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.occurrence.done
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : colorScheme.onSurface,
                    decoration: widget.occurrence.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    letterSpacing: -0.2,
                  ),
                ),
                if (widget.occurrence.habitDescription != null &&
                    widget.occurrence.habitDescription!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.occurrence.habitDescription!,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.occurrence.done
                          ? colorScheme.onSurface.withOpacity(0.3)
                          : colorScheme.onSurface.withOpacity(0.6),
                      decoration: widget.occurrence.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.occurrence.done
                  ? color.withOpacity(0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: widget.occurrence.done
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: color,
                  )
                : null,
          ),
        ],
      ),
    );

    final cardWidget = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canToggle ? _handleTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Opacity(
            opacity: canToggle ? 1.0 : 0.6,
            child: cardContent,
          ),
        ),
      ),
    );

    // Only wrap with Dismissible if can toggle
    if (!canToggle) {
      return cardWidget;
    }

    final background = Container(
      height: 78, // Altura total do card (padding 14*2 + content ~50)
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Icon(
        widget.occurrence.done ? Icons.undo_rounded : Icons.check_rounded,
        color: Colors.white,
        size: 28,
      ),
    );

    // Se o card foi escondido após a animação, não mostra mais
    if (_hideCardAfterAnimation) {
      return const SizedBox.shrink();
    }

    // Se está animando para fora E já está 95% completo, esconde
    if (_isAnimating && _slideController.value >= 0.95) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: Stack(
        children: [
          background,
          SlideTransition(
            position: _isAnimating ? _slideAnimation : _entranceAnimation,
            child: Dismissible(
              key: ValueKey(widget.occurrence.habitOccurrenceId),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                widget.onToggle!();
                return false;
              },
              background: background,
              child: cardWidget,
            ),
          ),
        ],
      ),
    );
  }
}
