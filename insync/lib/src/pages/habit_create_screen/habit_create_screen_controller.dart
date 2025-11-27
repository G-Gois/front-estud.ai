import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/backend/api_requests/api_requests.dart';
import 'package:insync/src/backend/api_requests/api_response.dart';
import 'package:insync/src/backend/api_requests/models/api_habit_model.dart';
import 'package:insync/src/utils/mixin/set_state_mixin.dart';
import 'package:insync/src/utils/storage/storage.dart';
import 'package:insync/src/utils/storage/storage_provider.dart';

class HabitCreateScreenController extends ChangeNotifier with SetStateMixin {
  HabitCreateScreenController({
    required this.context,
    required this.storage,
  });

  final BuildContext context;
  final Storage storage;

  bool isLoading = false;
  String selectedFrequency = 'daily';
  Set<int> selectedDaysOfWeek = {1, 2, 3, 4, 5, 6, 7};
  String selectedColor = '#A8DADC';

  void setFrequency(String frequency) {
    setState(() {
      selectedFrequency = frequency;
      if (frequency == 'daily') {
        selectedDaysOfWeek = {1, 2, 3, 4, 5, 6, 7};
      } else {
        selectedDaysOfWeek = {};
      }
    });
  }

  void toggleDayOfWeek(int day) {
    setState(() {
      if (selectedDaysOfWeek.contains(day)) {
        selectedDaysOfWeek.remove(day);
      } else {
        selectedDaysOfWeek.add(day);
      }
    });
  }

  void setColor(String color) {
    setState(() => selectedColor = color);
  }

  String _convertColorToRGB(String hexColor) {
    final color = Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    return '${color.red},${color.green},${color.blue}';
  }

  String _getStartDate() {
    final now = DateTime.now();
    DateTime startDate;

    if (selectedFrequency == 'daily') {
      startDate = DateTime(now.year, now.month, now.day);
    } else {
      // For weekly, finds the first date that matches one of the selected days
      final sortedDays = selectedDaysOfWeek.toList()..sort();
      if (sortedDays.isEmpty) {
        startDate = DateTime(now.year, now.month, now.day);
      } else {
        DateTime? foundDate;
        for (int i = 0; i < 7; i++) {
          final checkDate = now.add(Duration(days: i));
          if (sortedDays.contains(checkDate.weekday)) {
            foundDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
            break;
          }
        }
        startDate = foundDate ?? DateTime(now.year, now.month, now.day);
      }
    }

    return startDate.toIso8601String();
  }

  Future<void> createHabit({
    required String name,
    String? description,
  }) async {
    if (selectedFrequency == 'weekly' && selectedDaysOfWeek.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day of the week'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      final habit = ApiHabitCreateModel(
        title: name,
        description: description,
        daysOfWeek: selectedDaysOfWeek.toList()..sort(),
        active: true,
        colorTag: _convertColorToRGB(selectedColor),
        startDate: _getStartDate(),
        endDate: null,
      );

      final response = await ApiRequests.habits.create(habit);

      if (response is SuccessApiResponse) {
        setState(() => isLoading = false);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habit created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else if (response is ErrorApiResponse) {
        final error = (response as ErrorApiResponse).errorMessage;
        setState(() => isLoading = false);

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
      setState(() => isLoading = false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

final habitCreateScreenControllerProvider =
    ChangeNotifierProvider.family<HabitCreateScreenController, BuildContext>(
  (ref, context) {
    final storage = ref.watch(storageManagerProvider);
    return HabitCreateScreenController(
      context: context,
      storage: storage,
    );
  },
);
