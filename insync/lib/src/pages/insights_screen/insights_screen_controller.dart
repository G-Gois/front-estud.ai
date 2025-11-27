import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/backend/api_requests/api_requests.dart';
import 'package:insync/src/backend/api_requests/api_response.dart';
import 'package:insync/src/backend/api_requests/models/api_insights_model.dart';
import 'package:insync/src/pages/insights_screen/widgets/insights_date_filter_picker_widget.dart';
import 'package:insync/src/shared_widgets/input/calendar_picker/calendar_range_picker_widget.dart';
import 'package:insync/src/utils/mixin/set_state_mixin.dart';
import 'package:insync/src/utils/storage/storage.dart';
import 'package:insync/src/utils/storage/storage_provider.dart';

class InsightsScreenController extends ChangeNotifier with SetStateMixin {
  InsightsScreenController({
    required this.context,
    required this.storage,
  });

  final BuildContext context;
  final Storage storage;

  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  DateFilterOption selectedDateFilterOption = DateFilterOption.sevenDays;
  DateFilterOption _lastSelectedFilterOption = DateFilterOption.sevenDays;

  ApiInsightsModel? insight;
  List<ApiInsightsHabitStatModel> visibleHabitsStats = [];
  List<ApiInsightsProductiveDayModel> productiveDays = [];

  String getPersonalizedDateRangeLabel() {
    if (selectedDateFilterOption == DateFilterOption.sevenDays) {
      return 'In the last 7 Days';
    } else if (selectedDateFilterOption == DateFilterOption.lastMonth) {
      return 'In the last Month';
    } else {
      return 'From ${getFormattedStartDate()} to ${getFormattedEndDate()}';
    }
  }

  void onDateFilterOptionSelected(DateFilterOption option, ColorScheme colorScheme) {
    DateTime now = DateTime.now();
    if (option == DateFilterOption.personalized) {
      _lastSelectedFilterOption = selectedDateFilterOption;
    }

    setState(() {
      selectedDateFilterOption = option;
    });

    switch (option) {
      case DateFilterOption.sevenDays:
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        loadInsights();
        break;
      case DateFilterOption.lastMonth:
        startDate = DateTime(now.year, now.month - 1, now.day);
        endDate = now;
        loadInsights();
        break;
      case DateFilterOption.personalized:
        openDateRangePicker(colorScheme);
        break;
    }
  }

  void openDateRangePicker(ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CalendarRangePickerWidget(
        pickerTitle: 'Select Date Range',
        selectedEndDate: endDate,
        selectedStartDate: startDate,
        maxDate: DateTime.now().add(const Duration(days: 1)),
        minDate: DateTime(2025, 1, 1),
        onDateSelected: (startDate, endDate) {
          setState(() {
            this.startDate = startDate;
            this.endDate = endDate;
            _lastSelectedFilterOption = DateFilterOption.personalized;
          });
          loadInsights();
        },
        colorScheme: colorScheme,
      ),
    ).then((result) {
      if (result == null) {
        _revertSelectedFilterOption();
      }
    });
  }

  void _revertSelectedFilterOption() {
    setState(() {
      selectedDateFilterOption = _lastSelectedFilterOption;
    });

    DateTime now = DateTime.now();
    switch (_lastSelectedFilterOption) {
      case DateFilterOption.sevenDays:
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        loadInsights();
        break;
      case DateFilterOption.lastMonth:
        startDate = DateTime(now.year, now.month - 1, now.day);
        endDate = now;
        loadInsights();
        break;
      case DateFilterOption.personalized:
        // If previous was also personalized, keep current dates
        break;
    }
  }

  String getFormattedStartDate() {
    return '${startDate.month}/${startDate.day}/${startDate.year}';
  }

  String getFormattedEndDate() {
    return '${endDate.month}/${endDate.day}/${endDate.year}';
  }

  double getSleepHours() {
    if (insight == null || insight!.avgSleepHours == null) {
      return 0.0;
    }
    return insight!.avgSleepHours!;
  }

  double getHabitsPercentage() {
    if (insight == null || insight!.doneHabitsPercentage == null) {
      return 0.0;
    }
    return insight!.doneHabitsPercentage!;
  }

  void addMoreHabitsStats() {
    setState(() {
      final currentLength = visibleHabitsStats.length;
      final totalLength = insight?.habitStats.length ?? 0;
      final itemsToAdd = (totalLength - currentLength) >= 5 ? 5 : (totalLength - currentLength);
      visibleHabitsStats.addAll(
        insight!.habitStats.sublist(currentLength, currentLength + itemsToAdd),
      );
    });
  }

  void addMoreProductiveDays() {
    setState(() {
      final currentLength = productiveDays.length;
      final totalLength = insight?.mostProductiveDays.length ?? 0;
      final itemsToAdd = (totalLength - currentLength) >= 5 ? 5 : (totalLength - currentLength);
      productiveDays.addAll(
        insight!.mostProductiveDays.sublist(currentLength, currentLength + itemsToAdd),
      );
    });
  }

  Future<void> loadInsights() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    try {
      final response = await ApiRequests.insights.get(startDate, endDate);

      if (response is SuccessApiResponse<ApiInsightsModel>) {
        setState(() {
          insight = response.data;
          isLoading = false;
          hasError = false;
          errorMessage = null;

          final habitStats = insight!.habitStats;
          visibleHabitsStats = habitStats.sublist(0, habitStats.length > 5 ? 5 : habitStats.length);

          final productiveDays = insight!.mostProductiveDays;
          this.productiveDays = productiveDays.sublist(0, productiveDays.length > 5 ? 5 : productiveDays.length);
        });
      } else if (response is ErrorApiResponse) {
        final error = response.errorMessage ?? 'Unknown error';
        setState(() {
          insight = null;
          isLoading = false;
          hasError = true;
          errorMessage = error;
          visibleHabitsStats = [];
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
}

final insightsScreenControllerProvider = ChangeNotifierProvider.family<InsightsScreenController, BuildContext>(
  (ref, context) {
    final storage = ref.watch(storageManagerProvider);
    return InsightsScreenController(
      context: context,
      storage: storage,
    );
  },
);
