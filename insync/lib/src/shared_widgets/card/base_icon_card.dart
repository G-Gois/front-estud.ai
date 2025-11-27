import 'package:flutter/material.dart';

class BaseIconCard extends StatelessWidget {
  const BaseIconCard({
    super.key,
    required this.colorScheme,
    required this.iconData,
    required this.title,
    this.customBorderColor,
    this.customTitleColor,
    required this.child,
  });

  final ColorScheme colorScheme;
  final Widget child;
  final IconData iconData;
  final String title;
  final Color? customBorderColor;
  final Color? customTitleColor;

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
            children: [
              Icon(
                iconData,
                color: customTitleColor ?? colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: customTitleColor ?? colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child
        ],
      ),
    );
  }
}
