class ApiMoodTrackerModel {
  final String id;
  final int moodLevel;
  final DateTime date;
  final String? note;

  ApiMoodTrackerModel({
    required this.id,
    required this.moodLevel,
    required this.date,
    this.note,
  });

  factory ApiMoodTrackerModel.fromJson(Map<String, dynamic> json) {
    return ApiMoodTrackerModel(
      id: json['id'] as String,
      moodLevel: json['moodLevel'] as int,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}

class ApiMoodTrackerCreateModel {
  final int moodLevel;
  final String? note;
  final DateTime date;

  ApiMoodTrackerCreateModel({
    required this.moodLevel,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    String formattedDate = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return {
      'moodScore': moodLevel,
      'notes': note ?? '',
      'date': formattedDate,
    };
  }
}
