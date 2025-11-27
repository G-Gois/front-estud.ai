import 'package:flutter/material.dart';
import 'package:insync/src/core/constants/app_colors.dart';
import 'package:insync/src/shared_widgets/card/base_title_card.dart';

class InsightsHabitDetailsWidget extends StatelessWidget {
  const InsightsHabitDetailsWidget({
    super.key,
    required this.colorScheme,
    required this.title,
    required this.totalQuantity,
    required this.doneQuantity,
    required this.donePercentage,
  });

  final ColorScheme colorScheme;
  final String title;
  final int totalQuantity;
  final int doneQuantity;
  final double donePercentage;

  Color getBoldColor(BuildContext context) {
    if (donePercentage > 90) {
      return AppColors.getBoldGradient(context, 4);
    } else if (donePercentage > 75) {
      return AppColors.getBoldGradient(context, 3);
    } else if (donePercentage > 50) {
      return AppColors.getBoldGradient(context, 2);
    } else if (donePercentage > 25) {
      return AppColors.getBoldGradient(context, 1);
    } else {
      return AppColors.getBoldGradient(context, 0);
    }
  }

  Color getRegularColor(BuildContext context) {
    if (donePercentage > 90) {
      return AppColors.getRegularGradient(context, 4);
    } else if (donePercentage > 75) {
      return AppColors.getRegularGradient(context, 3);
    } else if (donePercentage > 50) {
      return AppColors.getRegularGradient(context, 2);
    } else if (donePercentage > 25) {
      return AppColors.getRegularGradient(context, 1);
    } else {
      return AppColors.getRegularGradient(context, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseTitleCard(
      colorScheme: colorScheme,
      title: title,
      customBorderColor: getRegularColor(context),
      customTitleColor: getBoldColor(context),
      rightText: '$donePercentage%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: doneQuantity / (totalQuantity == 0 ? 1 : totalQuantity),
            color: getBoldColor(context),
            backgroundColor: getRegularColor(context).withValues(alpha: 0.2),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Text(
            'Total done: $doneQuantity of $totalQuantity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
