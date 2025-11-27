import 'package:flutter/material.dart';

class BaseTitleCard extends StatelessWidget {
  const BaseTitleCard({
    super.key,
    required this.colorScheme,
    required this.title,
    this.rightText,
    this.customTitleColor,
    this.customBorderColor,
    required this.child,
  });

  final Color? customTitleColor;
  final Color? customBorderColor;
  final ColorScheme colorScheme;
  final String title;
  final String? rightText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: customBorderColor ?? colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: customTitleColor ?? colorScheme.onSurface,
                  ),
                ),
              ),
              if (rightText != null) ...[
                const SizedBox(width: 8),
                Text(
                  rightText!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: customTitleColor ?? colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          child
        ],
      ),
    );
  }
}
