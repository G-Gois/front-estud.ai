import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/backend/api_requests/api_requests.dart';
import 'package:insync/src/backend/api_requests/api_response.dart';
import 'package:insync/src/backend/api_requests/models/api_daily_feed_model.dart';
import 'package:insync/src/backend/api_requests/models/api_mood_tracker_model.dart';
import 'package:insync/src/backend/api_requests/models/api_sleep_tracker_model.dart';
import 'package:insync/src/core/exntesions/build_context_extension.dart';
import 'package:insync/src/shared_widgets/input/calendar_picker/calendar_picker_widget.dart';
import 'package:insync/src/utils/auth/auth_service.dart';
import 'package:insync/src/utils/mixin/set_state_mixin.dart';
import 'package:insync/src/utils/nav/modern_slide_route.dart';
import 'package:insync/src/utils/storage/storage.dart';
import 'package:insync/src/utils/storage/storage_keys.dart';
import 'package:insync/src/utils/storage/storage_provider.dart';
import 'package:insync/src/pages/welcome_screen/welcome_screen.dart';

class HomeScreenController extends ChangeNotifier with SetStateMixin {
  HomeScreenController({
    required this.context,
    required this.storage,
    DateTime? initialSelectedDate,
  }) {
    selectedDate = initialSelectedDate;
  }

  final BuildContext context;
  final Storage storage;

  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  String userName = '';
  String userEmail = '';

  // Daily Feed data
  ApiDailyFeedModel? dailyFeed;

  // Date selection
  DateTime? selectedDate;

  // Seleção do mood e sono do DIA ATUAL (pro usuário não conseguir alterar enquanto envia a req)
  int? selectedMoodToday;
  int? selectedSleepHoursToday;

  DateTime? lastSelectedMoodDate;
  DateTime? lastSelectedSleepDate;

  bool get hasSleepToday => dailyFeed?.sleepTracker != null;
  bool get hasMoodToday => dailyFeed?.moodTracker != null;

  // Track which habits are being updated
  final Set<String> _updatingHabits = {};

  // Track which habits were just toggled (para animar entrada)
  final Set<String> _recentlyToggledHabits = {};

  bool isHabitUpdating(String habitOccurrenceId) {
    return _updatingHabits.contains(habitOccurrenceId);
  }

  bool shouldAnimateEntrance(String habitOccurrenceId) {
    return _recentlyToggledHabits.contains(habitOccurrenceId);
  }

  Future<void> loadUserData() async {
    userName = await storage.get<String>(AppStorageKey.userName.key) ?? '';
    userEmail = await storage.get<String>(AppStorageKey.email.key) ?? '';
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    loadDailyFeed();
  }

  void clearSelectedDate() {
    setState(() {
      selectedDate = null;
    });
    loadDailyFeed();
  }

  bool get isToday {
    if (selectedDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    return selectedDay.isAtSameMomentAs(today);
  }

  bool get isTomorrow {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    return selectedDay.isAtSameMomentAs(tomorrow);
  }

  String getFormattedDate() {
    if (selectedDate == null) return 'Your Day';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    final difference = selectedDay.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == -1) return 'Yesterday';
    if (difference == 1) return 'Tomorrow';
    if (difference == -2) return '2 Days Ago';
    if (difference == 2) return 'In 2 Days';

    return '${selectedDate!.day}/${selectedDate!.month}';
  }

  Future<void> loadDailyFeed() async {
    setState(() {
      hasError = false;
      errorMessage = null;
    });

    try {
      final response = await ApiRequests.dailyFeed.get(date: selectedDate);

      if (response is SuccessApiResponse) {
        setState(() {
          hasError = false;
          errorMessage = null;
          dailyFeed = response.data;
        });
        return;
      }

      if (response is ErrorApiResponse) {
        setState(() {
          hasError = true;
          errorMessage = response.errorMessage;
          selectedMoodToday = null;
        });
        return;
      }

      setState(() {
        hasError = true;
        errorMessage = 'Unknown error occurred';
        selectedMoodToday = null;
        dailyFeed = null;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        selectedMoodToday = null;
        selectedSleepHoursToday = null;
        dailyFeed = null;
      });
    }
  }

  Future<void> loadHabits() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;

      final sameMoodDay = lastSelectedMoodDate != null &&
          lastSelectedMoodDate!.year == selectedDate?.year &&
          lastSelectedMoodDate!.month == selectedDate?.month &&
          lastSelectedMoodDate!.day == selectedDate?.day;

      final sameSleepDay = lastSelectedSleepDate != null &&
          lastSelectedSleepDate!.year == selectedDate?.year &&
          lastSelectedSleepDate!.month == selectedDate?.month &&
          lastSelectedSleepDate!.day == selectedDate?.day;

      selectedMoodToday = sameMoodDay ? selectedMoodToday : null;
      selectedSleepHoursToday = sameSleepDay ? selectedSleepHoursToday : null;
    });

    await loadUserData();
    await loadDailyFeed();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> toggleHabitOccurrence(String habitOccurrenceId, bool currentStatus) async {
    // Don't allow toggling if already updating
    if (_updatingHabits.contains(habitOccurrenceId)) {
      return;
    }

    // Add to updating set
    setState(() {
      _updatingHabits.add(habitOccurrenceId);
    });

    try {
      final occurrence = ApiUpdateOccurrenceModel(
        habitOccurrenceId: habitOccurrenceId,
        done: !currentStatus,
      );

      final response = await ApiRequests.dailyFeed.updateOccurrenceList([occurrence]);

      if (response is SuccessApiResponse) {
        // Marca como recém-toggleado para animar entrada
        _recentlyToggledHabits.add(habitOccurrenceId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(!currentStatus ? 'Habit completed!' : 'Habit unchecked'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        await loadDailyFeed();

        // Remove após um tempo para não animar próximo load
        Future.delayed(const Duration(seconds: 1), () {
          _recentlyToggledHabits.remove(habitOccurrenceId);
        });
      } else if (response is ErrorApiResponse) {
        final error = (response as ErrorApiResponse).errorMessage;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Remove from updating set
      setState(() {
        _updatingHabits.remove(habitOccurrenceId);
      });
    }
  }

  Future<void> selectMood(int moodIndex) async {
    final selectedDate = this.selectedDate ?? DateTime.now();

    setState(() {
      selectedMoodToday = moodIndex;
      lastSelectedMoodDate = selectedDate;
    });

    try {
      final mood = ApiMoodTrackerCreateModel(moodLevel: moodIndex, date: selectedDate);
      final response = await ApiRequests.moodTracker.create(mood);

      if (response is SuccessApiResponse) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mood registered!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (response is ErrorApiResponse) {
        final error = response.errorMessage ?? 'Unknown error';
        if (context.mounted) {
          setState(() {
            selectedMoodToday = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      await loadDailyFeed();
    } catch (e) {
      if (context.mounted) {
        setState(() {
          selectedMoodToday = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> selectSleepHours(int hours) async {
    final selectedDate = this.selectedDate ?? DateTime.now();

    setState(() {
      selectedSleepHoursToday = hours;
      lastSelectedSleepDate = selectedDate;
    });

    try {
      final sleep = ApiSleepTrackerCreateModel(sleepQuality: hours, date: selectedDate);
      final response = await ApiRequests.sleepTracker.create(sleep);

      if (response is SuccessApiResponse) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sleep quality registered!'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        await loadDailyFeed();
      } else if (response is ErrorApiResponse) {
        final error = response.errorMessage ?? 'Unknown error';
        if (context.mounted) {
          setState(() {
            selectedSleepHoursToday = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          selectedSleepHoursToday = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    // MS-Auth doesn't have a logout endpoint, just remove the token locally
    await AuthService().removeAuthToken();
    await storage.clearAll();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        ModernSlideRoute(child: const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void openCalendarPicker(BuildContext context) {
    final colorScheme = context.colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CalendarPickerWidget(
        colorScheme: colorScheme,
        selectedDate: selectedDate,
        maxDate: DateTime.now().add(const Duration(days: 1)),
        minDate: DateTime(2025, 1, 1),
        pickerTitle: 'Select Date',
        onDateSelected: (date) {
          final now = DateTime.now();
          final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

          if (isToday) {
            clearSelectedDate();
          } else {
            setSelectedDate(date);
          }
        },
      ),
    );
  }
}

final homeScreenControllerProvider =
    ChangeNotifierProvider.family<HomeScreenController, ({BuildContext context, DateTime? selectedDate})>(
  (ref, params) {
    final storage = ref.watch(storageManagerProvider);
    return HomeScreenController(
      context: params.context,
      storage: storage,
      initialSelectedDate: params.selectedDate,
    );
  },
);
