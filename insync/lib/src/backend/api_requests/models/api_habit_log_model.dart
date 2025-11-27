class ApiHabitLogModel {
  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final String? notes;
  final DateTime createdAt;

  ApiHabitLogModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.notes,
    required this.createdAt,
  });

  factory ApiHabitLogModel.fromJson(Map<String, dynamic> json) {
    return ApiHabitLogModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ApiHabitLogCreateModel {
  final String habitId;
  final DateTime date;
  final bool completed;
  final String? notes;

  ApiHabitLogCreateModel({
    required this.habitId,
    required this.date,
    required this.completed,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'date': date.toIso8601String(),
      'completed': completed,
      'notes': notes,
    };
  }
}
