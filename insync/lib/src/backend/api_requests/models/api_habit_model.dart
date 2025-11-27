class ApiHabitModel {
  final String id;
  final String name;
  final String? description;
  final bool active;
  final String? colorTag;
  final List<int> daysOfWeek;
  final String? startDate;
  final String? endDate;
  final DateTime createdAt;
  final String personId;

  ApiHabitModel({
    required this.id,
    required this.name,
    this.description,
    required this.active,
    this.colorTag,
    required this.daysOfWeek,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.personId,
  });

  ApiHabitModel copyWith({
    String? name,
    String? description,
    bool? active,
    String? colorTag,
    List<int>? daysOfWeek,
    String? startDate,
    String? endDate,
  }) {
    return ApiHabitModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      active: active ?? this.active,
      colorTag: colorTag ?? this.colorTag,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt,
      personId: personId,
    );
  }

  String get color {
    if (colorTag == null || colorTag!.isEmpty) return '#A8DADC';
    final parts = colorTag!.split(',');
    if (parts.length != 3) return '#A8DADC';
    try {
      final r = int.parse(parts[0].trim());
      final g = int.parse(parts[1].trim());
      final b = int.parse(parts[2].trim());
      return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
    } catch (e) {
      return '#A8DADC';
    }
  }

  String get frequency {
    if (daysOfWeek.length == 7) return 'daily';
    return 'weekly';
  }

  factory ApiHabitModel.fromJson(Map<String, dynamic> json) {
    List<int> parseDaysOfWeek(dynamic value) {
      if (value == null) return [1, 2, 3, 4, 5, 6, 7];
      if (value is List) {
        return value.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 1).toList();
      }
      return [1, 2, 3, 4, 5, 6, 7];
    }

    return ApiHabitModel(
      id: json['habitId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      active: json['active'] == true,
      colorTag: json['colorTag']?.toString(),
      daysOfWeek: parseDaysOfWeek(json['daysOfWeek']),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      personId: json['personId']?.toString() ?? '',
    );
  }
}

class ApiHabitCreateModel {
  final String title;
  final String? description;
  final List<int> daysOfWeek;
  final bool active;
  final String colorTag;
  final String startDate;
  final String? endDate;

  ApiHabitCreateModel({
    required this.title,
    this.description,
    required this.daysOfWeek,
    required this.active,
    required this.colorTag,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'daysOfWeek': daysOfWeek,
      'active': active,
      'colorTag': colorTag,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class ApiHabitUpdateModel {
  final String habitId;
  final String title;
  final String? description;
  final bool active;
  final String colorTag;
  final List<int> daysOfWeek;
  final String startDate;
  final String? endDate;

  ApiHabitUpdateModel({
    required this.habitId,
    required this.title,
    this.description,
    required this.active,
    required this.colorTag,
    required this.daysOfWeek,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'title': title,
      'description': description,
      'active': active,
      'colorTag': colorTag,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  ApiHabitUpdateModel copyWith({
    String? title,
    String? description,
    bool? active,
    String? colorTag,
    List<int>? daysOfWeek,
    String? startDate,
    String? endDate,
  }) {
    return ApiHabitUpdateModel(
      habitId: habitId,
      title: title ?? this.title,
      description: description ?? this.description,
      active: active ?? this.active,
      colorTag: colorTag ?? this.colorTag,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class ApiHabitListModel {
  final List<ApiHabitModel> habits;
  final int total;

  ApiHabitListModel({
    required this.habits,
    required this.total,
  });

  factory ApiHabitListModel.fromJson(Map<String, dynamic> json) {
    return ApiHabitListModel(
      habits: (json['habits'] as List).map((item) => ApiHabitModel.fromJson(item as Map<String, dynamic>)).toList(),
      total: json['total'] as int,
    );
  }
}
