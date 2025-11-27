import 'package:flutter/material.dart';
import 'package:insync/src/backend/api_requests/models/api_insights_model.dart';
import 'package:insync/src/core/constants/app_colors.dart';
import 'package:insync/src/shared_widgets/card/base_card.dart';
import 'package:insync/src/utils/nav/app_routes.dart';
import 'package:intl/intl.dart';

class InsightsProductiveDayDetailsWidget extends StatelessWidget {
  const InsightsProductiveDayDetailsWidget({
    super.key,
    required this.dayInfo,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;
  final ApiInsightsProductiveDayModel dayInfo;

  Color getRegularColor(BuildContext context) {
    final donePercentage = dayInfo.donePercentage;
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

  Color getMediumColor(BuildContext context) {
    final donePercentage = dayInfo.donePercentage;
    if (donePercentage > 90) {
      return AppColors.getMediumGradient(context, 4);
    } else if (donePercentage > 75) {
      return AppColors.getMediumGradient(context, 3);
    } else if (donePercentage > 50) {
      return AppColors.getMediumGradient(context, 2);
    } else if (donePercentage > 25) {
      return AppColors.getMediumGradient(context, 1);
    } else {
      return AppColors.getMediumGradient(context, 0);
    }
  }

  Color getBoldColor(BuildContext context) {
    final donePercentage = dayInfo.donePercentage;
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

  IconData getMoodIcon() {
    final moodScore = dayInfo.mood;
    switch (moodScore) {
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
        return Icons.sentiment_neutral_outlined;
    }
  }

  Color getMoodColor(BuildContext context) {
    final moodScore = dayInfo.mood ?? 2;
    return AppColors.getBoldGradient(context, moodScore);
  }

  String getFormattedDate() {
    final date = dayInfo.date;
    return DateFormat('MMMM d, y').format(date);
  }

  String getFormattedHours() {
    final hours = dayInfo.sleepHours;
    if (hours == null) return 'N/A';
    final minutes = (hours * 60).round();
    final hrs = minutes / 60;
    final mins = minutes % 60;
    return '${hrs.toStringAsFixed(0)}h ${mins.toStringAsFixed(0)}m';
  }

  String getFormattedPercentage() {
    final done = dayInfo.donePercentage;
    return '$done%';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushReplacementNamed(AppRoutes.home, arguments: dayInfo.date);
      },
      child: BaseCard(
        colorScheme: colorScheme,
        customBorderColor: getRegularColor(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getFormattedDate(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: getBoldColor(context),
                  ),
                ),
                Icon(
                  getMoodIcon(),
                  color: getMoodColor(context),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sleep",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: getMediumColor(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          getFormattedHours(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: getBoldColor(context),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Habits",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: getMediumColor(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          getFormattedPercentage(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: getBoldColor(context),
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: dayInfo.donePercentage,
                          color: getBoldColor(context),
                          backgroundColor: getRegularColor(context).withValues(alpha: 0.2),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
