import 'package:flutter/material.dart';
import 'package:insync/src/core/constants/app_colors.dart';
import 'package:insync/src/shared_widgets/card/base_icon_card.dart';

class InsightsAverageMoodWidget extends StatelessWidget {
  const InsightsAverageMoodWidget({super.key, required this.colorScheme, required this.moodScore});

  final ColorScheme colorScheme;
  final int? moodScore;

  @override
  Widget build(BuildContext context) {
    final boldColor = AppColors.getBoldGradient(context, moodScore ?? 2);
    final regularColor = AppColors.getRegularGradient(context, moodScore ?? 2);
    final mediumColor = AppColors.getMediumGradient(context, moodScore ?? 2);

    return BaseIconCard(
      colorScheme: colorScheme,
      customTitleColor: boldColor,
      customBorderColor: regularColor,
      iconData: Icons.mood,
      title: 'Average Mood',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          5,
          (index) {
            final isThis = moodScore == index;
            return Container(
              width: isThis ? 48 : 40,
              height: isThis ? 48 : 40,
              decoration: BoxDecoration(
                color: isThis ? mediumColor : colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isThis ? mediumColor : colorScheme.primary.withValues(alpha: 0.3),
                  width: isThis ? 2 : 1,
                ),
              ),
              child: Center(
                child: Icon(
                  _getMoodIcon(index),
                  size: isThis ? 28 : 24,
                  color: isThis ? colorScheme.onPrimary : colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getMoodIcon(int index) {
    switch (index) {
      case 0:
        return Icons.sentiment_very_dissatisfied_outlined;
      case 1:
        return Icons.sentiment_dissatisfied_outlined;
      case 2:
        return Icons.sentiment_neutral_outlined;
      case 3:
        return Icons.sentiment_satisfied_outlined;
      case 4:
        return Icons.sentiment_very_satisfied_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
