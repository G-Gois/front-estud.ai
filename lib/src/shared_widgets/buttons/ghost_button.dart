import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textMain,
            letterSpacing: 0.24,
          ),
    );

    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.textMain),
              const SizedBox(width: AppSpacing.sm),
              text,
            ],
          )
        : text;

    final button = OutlinedButton(
      onPressed: onPressed,
      child: child,
    );

    if (!expanded) return button;

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}
