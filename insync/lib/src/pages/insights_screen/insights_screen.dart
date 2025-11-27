import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/pages/insights_screen/insights_screen_controller.dart';
import 'package:insync/src/pages/insights_screen/widgets/insights_average_mood_widget.dart';
import 'package:insync/src/pages/insights_screen/widgets/insights_average_sleep_and_habits_widget.dart';
import 'package:insync/src/pages/insights_screen/widgets/insights_date_filter_picker_widget.dart';
import 'package:insync/src/pages/insights_screen/widgets/insights_habit_details_widget.dart';
import 'package:insync/src/pages/insights_screen/widgets/insights_productive_day_details_widget.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  InsightsScreenController get controller => ref.watch(insightsScreenControllerProvider(context));

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Insights'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading insights...',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.hasError || controller.insight == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      controller.errorMessage ?? 'Error loading insights',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.loadInsights,
                        child: const Text('Try Again'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadInsights,
            color: colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InsightsDateFilterPickerWidget(
                      selectedOption: controller.selectedDateFilterOption,
                      onOptionSelected: (option) => controller.onDateFilterOptionSelected(option, colorScheme),
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Your overall insights',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      controller.getPersonalizedDateRangeLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InsightsAverageSleepAndHabitsWidget(
                      colorScheme: colorScheme,
                      avgSleepHours: controller.insight?.avgSleepHours ?? 0,
                      habitsPercentage: controller.insight?.doneHabitsPercentage ?? 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InsightsAverageMoodWidget(
                      colorScheme: colorScheme,
                      moodScore: controller.insight!.avgMood,
                    ),
                  ),
                  SizedBox(
                      height: controller.visibleHabitsStats.isEmpty && controller.productiveDays.isEmpty ? 48 : 24),
                  // Seção de habitos
                  if (controller.visibleHabitsStats.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Your habits performance',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.visibleHabitsStats.length,
                      itemBuilder: (context, index) {
                        final habit = controller.visibleHabitsStats[index];
                        final isLast = index == controller.visibleHabitsStats.length - 1;
                        final bottomPadding = isLast ? 0.0 : 8.0;

                        return Padding(
                          padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: bottomPadding),
                          child: InsightsHabitDetailsWidget(
                            colorScheme: colorScheme,
                            title: habit.title,
                            totalQuantity: habit.totalOccurrences,
                            doneQuantity: habit.quantityDone,
                            donePercentage: habit.donePercentage,
                          ),
                        );
                      },
                    ),
                    if (controller.visibleHabitsStats.length < controller.insight!.habitStats.length) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Center(
                          child: TextButton(
                            onPressed: controller.addMoreHabitsStats,
                            child: Text(
                              'Show more',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: controller.productiveDays.isEmpty ? 48 : 24),
                  ],
                  // Seção de dias produtivos
                  if (controller.productiveDays.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Your daily productivity',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.productiveDays.length,
                      itemBuilder: (context, index) {
                        final day = controller.productiveDays[index];
                        final isLast = index == controller.productiveDays.length - 1;
                        final bottomPadding = isLast ? 0.0 : 8.0;

                        return Padding(
                          padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: bottomPadding),
                          child: InsightsProductiveDayDetailsWidget(
                            colorScheme: colorScheme,
                            dayInfo: day,
                          ),
                        );
                      },
                    ),
                    if (controller.productiveDays.length < controller.insight!.mostProductiveDays.length) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Center(
                          child: TextButton(
                            onPressed: controller.addMoreProductiveDays,
                            child: Text(
                              'Show more',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
