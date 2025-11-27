class ApiSleepTrackerModel {
  final String id;
  final int sleepQuality;
  final DateTime date;
  final String? note;

  ApiSleepTrackerModel({
    required this.id,
    required this.sleepQuality,
    required this.date,
    this.note,
  });

  factory ApiSleepTrackerModel.fromJson(Map<String, dynamic> json) {
    return ApiSleepTrackerModel(
      id: json['id'] as String,
      sleepQuality: json['sleepQuality'] as int,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}

class ApiSleepTrackerCreateModel {
  final int sleepQuality;
  final DateTime date;
  final String? note;

  ApiSleepTrackerCreateModel({
    required this.sleepQuality,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    String formattedDate = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return {
      'hoursSlept': sleepQuality,
      'notes': note ?? '',
      'date': formattedDate,
    };
  }
}
