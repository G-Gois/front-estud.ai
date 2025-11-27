import 'package:flutter/material.dart';

class AppSwitchWidget extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  final Color? customColor;

  const AppSwitchWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final customColorAlpha = customColor?.withValues(alpha: 0.2);

    final pretoCasoAtivo = value ? customColorAlpha ?? Colors.black : Colors.white;
    final brancoCasoAtivo = value ? customColorAlpha ?? Colors.white : Colors.black;

    final Color thumbColor = customColor ?? (isDarkMode ? pretoCasoAtivo : brancoCasoAtivo);
    final Color trackColor = isDarkMode ? brancoCasoAtivo : pretoCasoAtivo;
    final Color trackBorderColor = customColor ?? (isDarkMode ? Colors.white : Colors.black);

    return Transform.scale(
      scale: 0.9,
      child: Switch(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          return thumbColor;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          return trackColor;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
          return trackBorderColor;
        }),
      ),
    );
  }
}
