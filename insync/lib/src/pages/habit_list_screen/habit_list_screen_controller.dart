import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/backend/api_requests/api_requests.dart';
import 'package:insync/src/backend/api_requests/api_response.dart';
import 'package:insync/src/backend/api_requests/models/api_habit_model.dart';
import 'package:insync/src/utils/mixin/set_state_mixin.dart';
import 'package:insync/src/utils/storage/storage.dart';
import 'package:insync/src/utils/storage/storage_provider.dart';

class HabitListScreenController extends ChangeNotifier with SetStateMixin {
  HabitListScreenController({
    required this.context,
    required this.storage,
  });

  final BuildContext context;
  final Storage storage;

  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  List<ApiHabitModel> habits = [];

  Future<void> loadHabits() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    try {
      final response = await ApiRequests.habits.list();

      if (response is SuccessApiResponse<ApiHabitListModel>) {
        setState(() {
          habits = response.data.habits;
          isLoading = false;
        });
      } else if (response is ErrorApiResponse) {
        final error = response.errorMessage ?? 'Unknown error';
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = error;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      final response = await ApiRequests.habits.delete(habitId);

      if (response is SuccessApiResponse) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habit deleted!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        await loadHabits();
      } else if (response is ErrorApiResponse) {
        final error = response.errorMessage;
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
    }
  }

  Future<void> toggleHabitActiveStatus(String habitId, bool isActive) async {
    final index = habits.indexWhere((habit) => habit.id == habitId);
    if (index == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There was an error updating the habit status.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final originalHabit = habits[index];

    setState(() {
      final updatedHabit = originalHabit.copyWith(active: isActive);
      habits[index] = updatedHabit;
    });

    try {
      final ApiHabitUpdateModel updatedHabit = ApiHabitUpdateModel(
        description: originalHabit.description,
        active: isActive,
        colorTag: originalHabit.colorTag ?? "",
        habitId: originalHabit.id,
        daysOfWeek: originalHabit.daysOfWeek,
        startDate: originalHabit.startDate ?? "",
        title: originalHabit.name,
        endDate: originalHabit.endDate,
      );

      final response = await ApiRequests.habits.update(originalHabit.id, updatedHabit);

      if (response is SuccessApiResponse) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Habit ${isActive ? 'activated' : 'deactivated'} successfully!'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (response is ErrorApiResponse) {
        final error = response.errorMessage ?? 'Unknown error';
        setState(() {
          habits[index] = originalHabit;
        });

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
        setState(() {
          habits[index] = originalHabit;
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
}

final habitListScreenControllerProvider = ChangeNotifierProvider.family<HabitListScreenController, BuildContext>(
  (ref, context) {
    final storage = ref.watch(storageManagerProvider);
    return HabitListScreenController(
      context: context,
      storage: storage,
    );
  },
);
