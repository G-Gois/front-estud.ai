import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insync/src/pages/home_screen/home_screen_controller.dart';
import 'package:insync/src/pages/home_screen/widgets/home_drawer_widget.dart';
import 'package:insync/src/pages/home_screen/widgets/home_register_card_animation_widget.dart';
import 'package:insync/src/pages/home_screen/widgets/home_register_mood_widget.dart';
import 'package:insync/src/pages/home_screen/widgets/home_register_sleep_widget.dart';
import 'package:insync/src/pages/home_screen/widgets/home_registered_mood_widget.dart';
import 'package:insync/src/pages/home_screen/widgets/home_registered_sleep_widget.dart';
import 'package:insync/src/pages/home_screen/widgets/habit_occurrence_card.dart';
import 'package:insync/src/utils/nav/app_routes.dart';
import 'package:insync/src/utils/theme/theme_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.selectedDate});

  final DateTime? selectedDate;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeScreenController get controller =>
      ref.watch(homeScreenControllerProvider((context: context, selectedDate: widget.selectedDate)));

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeNotifier = ref.watch(themeNotifierProvider);
    final brightness = theme.brightness;
    final isLightMode = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            if (isLightMode) ...[
              SvgPicture.asset(
                'lib/assets/icon_black.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
            ] else ...[
              Image.asset(
                'lib/assets/icon_inSync.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
            ],
            const Text('inSync', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () {
              themeNotifier.toggleTheme();
            },
            icon: Icon(
              themeNotifier.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: themeNotifier.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: HomeDrawerWidget(
        username: controller.userName.trim(),
        email: controller.userEmail,
        onLogout: controller.logout,
        onReloadPage: controller.loadHabits,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).pushNamed(AppRoutes.habitCreate);
          controller.loadHabits();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit'),
        elevation: 4,
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
                    'Loading your habits...',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.hasError) {
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
                      controller.errorMessage ?? 'Error loading habits',
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
                        onPressed: controller.loadHabits,
                        child: const Text('Try Again'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final dailyFeed = controller.dailyFeed;
          final hasHabits = (dailyFeed?.habitOccurrences ?? []).isNotEmpty;
          final todayDisappeared = controller.selectedMoodToday != null && controller.selectedSleepHoursToday != null;
          final todayWasSelected = controller.hasSleepToday && controller.hasMoodToday;

          if (((todayWasSelected && todayDisappeared) || controller.isTomorrow) && !hasHabits) {
            final brightness = Theme.of(context).brightness;
            final isLightMode = brightness == Brightness.light;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isLightMode ? colorScheme.surface : colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: isLightMode
                          ? SvgPicture.asset(
                              'lib/assets/icon_black.svg',
                              width: 80,
                              height: 80,
                            )
                          : Image.asset(
                              'lib/assets/icon_inSync.png',
                              width: 80,
                              height: 80,
                            ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'No habits for tommorrow',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create your first habit and start\nbuilding better routines today!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).pushNamed(AppRoutes.habitCreate);
                        controller.loadHabits();
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create First Habit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadHabits,
            color: colorScheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Row(
                      children: [
                        Text(
                          controller.getFormattedDate(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Date picker button
                        GestureDetector(
                          onTap: () => controller.openCalendarPicker(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        // Reset to today button (only show when date is selected)
                        if (!controller.isToday) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: controller.clearSelectedDate,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.today,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Builder(
                        builder: (context) {
                          if (controller.isTomorrow || controller.hasMoodToday && controller.isToday) {
                            return const SizedBox.shrink();
                          }

                          final moodScore = dailyFeed?.moodTracker?['moodScore'];
                          if (moodScore != null && controller.selectedMoodToday == null) {
                            return HomeRegisteredMoodWidget(moodScore: moodScore);
                          }
                          return HomeRegisterCardAnimationWidget(
                            shouldHide: controller.hasMoodToday && controller.selectedMoodToday != null,
                            child: HomeRegisterMoodWidget(
                              date: controller.selectedDate ?? DateTime.now(),
                              selectedMood: controller.selectedMoodToday,
                              onMoodSelected: (moodIndex) => controller.selectMood(moodIndex),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          if (controller.isTomorrow || controller.hasSleepToday && controller.isToday) {
                            return const SizedBox.shrink();
                          }

                          final sleepHours = dailyFeed?.sleepTracker?['hoursSlept'] as double?;
                          if (sleepHours != null && controller.selectedSleepHoursToday == null) {
                            return HomeRegisteredSleepWidget(sleepHours: sleepHours.round().toInt());
                          }

                          return HomeRegisterCardAnimationWidget(
                            shouldHide: controller.hasSleepToday && controller.selectedSleepHoursToday == null,
                            child: HomeRegisterSleepWidget(
                              date: controller.selectedDate ?? DateTime.now(),
                              selectedHours: controller.selectedSleepHoursToday,
                              onSleepHoursSelected: (hours) => controller.selectSleepHours(hours),
                            ),
                          );
                        },
                      ),

                      // Habit Occurrences - Separated by status
                      if ((dailyFeed?.habitOccurrences ?? []).isNotEmpty) ...[
                        // Pending (done = false)
                        ...() {
                          final pending = dailyFeed?.habitOccurrences.where((o) => !o.done).toList();

                          if (pending == null || pending.isEmpty) return <Widget>[];

                          return <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'PENDING',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${pending.length} habit${pending.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...pending.map((occurrence) {
                              return HabitOccurrenceCard(
                                key: ValueKey('${occurrence.habitOccurrenceId}_pending'),
                                occurrence: occurrence,
                                isUpdating: controller.isHabitUpdating(occurrence.habitOccurrenceId),
                                animateEntrance: controller.shouldAnimateEntrance(occurrence.habitOccurrenceId),
                                onToggle: () {
                                  controller.toggleHabitOccurrence(
                                    occurrence.habitOccurrenceId,
                                    occurrence.done,
                                  );
                                },
                              );
                            }),
                          ];
                        }(),

                        // Completed (done = true)
                        ...() {
                          final completed = dailyFeed?.habitOccurrences.where((o) => o.done).toList();

                          if (completed == null || completed.isEmpty) return <Widget>[];

                          return <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 24, bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'COMPLETED',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.secondary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${completed.length} habit${completed.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...completed.map((occurrence) {
                              return HabitOccurrenceCard(
                                key: ValueKey('${occurrence.habitOccurrenceId}_completed'),
                                occurrence: occurrence,
                                isUpdating: controller.isHabitUpdating(occurrence.habitOccurrenceId),
                                animateEntrance: controller.shouldAnimateEntrance(occurrence.habitOccurrenceId),
                                onToggle: () {
                                  controller.toggleHabitOccurrence(
                                    occurrence.habitOccurrenceId,
                                    occurrence.done,
                                  );
                                },
                              );
                            }),
                          ];
                        }(),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
