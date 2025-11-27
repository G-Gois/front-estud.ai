import 'package:flutter/material.dart';
import 'package:insync/src/core/constants/app_colors.dart';
import 'package:insync/src/shared_widgets/card/base_icon_card.dart';

class InsightsAverageSleepAndHabitsWidget extends StatelessWidget {
  const InsightsAverageSleepAndHabitsWidget({
    super.key,
    required this.colorScheme,
    required this.avgSleepHours,
    required this.habitsPercentage,
  });

  final ColorScheme colorScheme;
  final double avgSleepHours;
  final double habitsPercentage;

  String getFormattedHabitsPercentage() {
    if (habitsPercentage <= 0) {
      return '0%';
    }

    final percentage = habitsPercentage.round();
    return '$percentage%';
  }

  String getFormattedSleepHours() {
    if (avgSleepHours <= 0) {
      return '0h 0m';
    }

    final totalMinutes = (avgSleepHours * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Color getSleepHoursBoldColor(BuildContext context) {
    if (avgSleepHours >= 8) {
      return AppColors.getBoldGradient(context, 4);
    } else if (avgSleepHours >= 6) {
      return AppColors.getBoldGradient(context, 3);
    } else if (avgSleepHours >= 4) {
      return AppColors.getBoldGradient(context, 2);
    } else {
      return AppColors.getBoldGradient(context, 0);
    }
  }

  Color getSleepHoursRegularColor(BuildContext context) {
    if (avgSleepHours >= 8) {
      return AppColors.getRegularGradient(context, 4);
    } else if (avgSleepHours >= 6) {
      return AppColors.getRegularGradient(context, 3);
    } else if (avgSleepHours >= 4) {
      return AppColors.getRegularGradient(context, 2);
    } else {
      return AppColors.getRegularGradient(context, 0);
    }
  }

  Color getHabitsPercentageBoldColor(BuildContext context) {
    if (habitsPercentage >= 85) {
      return AppColors.getBoldGradient(context, 4);
    } else if (habitsPercentage >= 60) {
      return AppColors.getBoldGradient(context, 3);
    } else if (habitsPercentage >= 40) {
      return AppColors.getBoldGradient(context, 2);
    } else if (habitsPercentage >= 20) {
      return AppColors.getBoldGradient(context, 1);
    } else {
      return AppColors.getBoldGradient(context, 0);
    }
  }

  Color getHabitsPercentageRegularColor(BuildContext context) {
    if (habitsPercentage >= 85) {
      return AppColors.getRegularGradient(context, 4);
    } else if (habitsPercentage >= 60) {
      return AppColors.getRegularGradient(context, 3);
    } else if (habitsPercentage >= 40) {
      return AppColors.getRegularGradient(context, 2);
    } else if (habitsPercentage >= 20) {
      return AppColors.getRegularGradient(context, 1);
    } else {
      return AppColors.getRegularGradient(context, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: BaseIconCard(
              colorScheme: colorScheme,
              customTitleColor: getSleepHoursBoldColor(context),
              customBorderColor: getSleepHoursRegularColor(context),
              iconData: Icons.bedtime_outlined,
              title: 'Sleep',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    getFormattedSleepHours(),
                    style: TextStyle(
                      fontSize: 24,
                      color: getSleepHoursBoldColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Average sleep hours',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BaseIconCard(
              colorScheme: colorScheme,
              iconData: Icons.bar_chart_rounded,
              title: 'Habits',
              customBorderColor: getHabitsPercentageRegularColor(context),
              customTitleColor: getHabitsPercentageBoldColor(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    getFormattedHabitsPercentage(),
                    style: TextStyle(
                      fontSize: 24,
                      color: getHabitsPercentageBoldColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Average habits completion',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
