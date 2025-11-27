class ApiInsightsModel {
  final double? avgSleepHours;
  final int? avgMood;
  final double? doneHabitsPercentage;
  final List<ApiInsightsHabitStatModel> habitStats;
  final List<ApiInsightsProductiveDayModel> mostProductiveDays;

  ApiInsightsModel({
    required this.avgMood,
    required this.avgSleepHours,
    required this.doneHabitsPercentage,
    required this.habitStats,
    required this.mostProductiveDays,
  });

  factory ApiInsightsModel.fromJson(Map<String, dynamic> json) {
    return ApiInsightsModel(
      avgMood: json['avgMood'] as int?,
      avgSleepHours: (json['avgSleepHours'] as num?)?.toDouble(),
      doneHabitsPercentage: (json['doneHabitsPercentage'] as num?)?.toDouble(),
      habitStats: (json['habitStats'] as List<dynamic>)
          .map((e) => ApiInsightsHabitStatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mostProductiveDays: (json['mostProductiveDays'] as List<dynamic>)
          .map((e) => ApiInsightsProductiveDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ApiInsightsHabitStatModel {
  final String title;
  final int totalOccurrences;
  final int quantityDone;
  final double donePercentage;

  ApiInsightsHabitStatModel({
    required this.title,
    required this.totalOccurrences,
    required this.quantityDone,
    required this.donePercentage,
  });

  factory ApiInsightsHabitStatModel.fromJson(Map<String, dynamic> json) {
    return ApiInsightsHabitStatModel(
      title: json['title'] as String,
      totalOccurrences: json['totalOccurrences'] as int,
      quantityDone: json['quantityDone'] as int,
      donePercentage: (json['donePercentage'] as num).toDouble(),
    );
  }
}

class ApiInsightsProductiveDayModel {
  final DateTime date;
  final double donePercentage;
  final int? mood;
  final double? sleepHours;

  ApiInsightsProductiveDayModel({
    required this.date,
    required this.donePercentage,
    this.mood,
    this.sleepHours,
  });

  factory ApiInsightsProductiveDayModel.fromJson(Map<String, dynamic> json) {
    return ApiInsightsProductiveDayModel(
      date: DateTime.parse(json['date'] as String),
      donePercentage: (json['donePercentage'] as num).toDouble(),
      mood: (json['mood'] as num?)?.toDouble().round(),
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
    );
  }
}
