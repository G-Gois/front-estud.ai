class ApiDailyFeedModel {
  final dynamic moodTracker; // Pode ser String ou Map (objeto)
  final dynamic sleepTracker; // Pode ser String ou Map (objeto)
  final List<ApiHabitOccurrenceModel> habitOccurrences;

  ApiDailyFeedModel({
    this.moodTracker,
    this.sleepTracker,
    required this.habitOccurrences,
  });

  factory ApiDailyFeedModel.fromJson(Map<String, dynamic> json) {
    return ApiDailyFeedModel(
      moodTracker: json['moodTracker'],
      sleepTracker: json['sleepTracker'],
      habitOccurrences: (json['habitOccurrences'] as List)
          .map((item) => ApiHabitOccurrenceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ApiHabitOccurrenceModel {
  final String habitOccurrenceId;
  final String habitId;
  final String habitName;
  final String? habitDescription;
  final String habitColor;
  final bool done;
  final DateTime scheduledDate;

  ApiHabitOccurrenceModel({
    required this.habitOccurrenceId,
    required this.habitId,
    required this.habitName,
    this.habitDescription,
    required this.habitColor,
    required this.done,
    required this.scheduledDate,
  });

  factory ApiHabitOccurrenceModel.fromJson(Map<String, dynamic> json) {
    return ApiHabitOccurrenceModel(
      habitOccurrenceId: json['habitOccurrenceId'] as String,
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      habitDescription: json['habitDescription'] as String?,
      habitColor: json['habitColor'] as String,
      done: json['done'] as bool,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
    );
  }

  ApiHabitOccurrenceModel copyWith({
    String? habitOccurrenceId,
    String? habitId,
    String? habitName,
    String? habitDescription,
    String? habitColor,
    bool? done,
    DateTime? scheduledDate,
  }) {
    return ApiHabitOccurrenceModel(
      habitOccurrenceId: habitOccurrenceId ?? this.habitOccurrenceId,
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      habitDescription: habitDescription ?? this.habitDescription,
      habitColor: habitColor ?? this.habitColor,
      done: done ?? this.done,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }
}

class ApiUpdateOccurrenceModel {
  final String habitOccurrenceId;
  final bool done;
  final String? notes;

  ApiUpdateOccurrenceModel({
    required this.habitOccurrenceId,
    required this.done,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'habitOccurrenceId': habitOccurrenceId,
      'done': done,
      if (notes != null) 'notes': notes,
    };
  }
}
