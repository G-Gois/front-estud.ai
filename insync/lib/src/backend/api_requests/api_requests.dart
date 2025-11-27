import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:insync/src/backend/api_requests/api_response.dart';
import 'package:insync/src/backend/api_requests/api_service.dart';
import 'package:insync/src/backend/api_requests/models/api_habit_log_model.dart';
import 'package:insync/src/backend/api_requests/models/api_habit_model.dart';
import 'package:insync/src/backend/api_requests/models/api_insights_model.dart';
import 'package:insync/src/backend/api_requests/models/api_login_model.dart';
import 'package:insync/src/backend/api_requests/models/api_register_model.dart';
import 'package:insync/src/backend/api_requests/models/api_daily_feed_model.dart';
import 'package:insync/src/backend/api_requests/models/api_mood_tracker_model.dart';
import 'package:insync/src/backend/api_requests/models/api_sleep_tracker_model.dart';
import 'package:insync/src/utils/auth/auth_service.dart';

class ApiRequests {
  const ApiRequests._();

  static final auth = _Auth();
  static final insync = _InSync();
  static final habits = _Habits();
  static final habitLogs = _HabitLogs();
  static final dailyFeed = _DailyFeed();
  static final moodTracker = _MoodTracker();
  static final sleepTracker = _SleepTracker();
  static final insights = _Insights();
}

// Helper to get headers with authentication
Future<Map<String, String>> getAuthHeaders() async {
  final token = await AuthService().getAuthToken();
  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

class _Auth {
  final apiService = ApiService(
    Dio(BaseOptions(baseUrl: dotenv.env['AUTH_API_URL'] ?? '')),
  );

  static String get apiKey => dotenv.env['AUTH_API_KEY'] ?? '';
  static String get resourceName => 'insync-app';

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      };

  // Token - Create Token (Login)
  Future<ApiResponse<ApiLoginModel>> login({
    required String email,
    required String password,
  }) async {
    return apiService.sendRequest<ApiLoginModel>(
      endpoint: '/auth/token',
      method: 'POST',
      fromJson: (data) => ApiLoginModel.fromJson(data),
      data: {
        'login': email,
        'password': password,
        'resourceName': resourceName,
      },
      headers: _defaultHeaders,
    );
  }

  // Token - Validate Token
  Future<ApiResponse<void>> validateToken({
    required String token,
  }) async {
    return apiService.sendRequest<void>(
      endpoint: '/auth/token',
      method: 'GET',
      fromJson: (_) {},
      headers: {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    );
  }

  // User - Create User (Register)
  Future<ApiResponse<ApiRegisterResponseModel>> register({
    required String email,
    required String password,
  }) async {
    return apiService.sendRequest<ApiRegisterResponseModel>(
      endpoint: '/auth/user',
      method: 'POST',
      fromJson: (data) => ApiRegisterResponseModel.fromJson(data),
      data: {
        'login': email,
        'email': email,
        'password': password,
        'status': true,
      },
      headers: _defaultHeaders,
    );
  }

  // User - Read User
  Future<ApiResponse<Map<String, dynamic>>> readUser({
    required String userId,
  }) async {
    return apiService.sendRequest<Map<String, dynamic>>(
      endpoint: '/auth/user/$userId',
      method: 'GET',
      fromJson: (data) => data as Map<String, dynamic>,
      headers: _defaultHeaders,
    );
  }

  // User - Update User Password
  Future<ApiResponse<void>> updatePassword({
    required String userId,
    required String password,
  }) async {
    return apiService.sendRequest<void>(
      endpoint: '/auth/user/$userId/reset-password',
      method: 'PATCH',
      fromJson: (_) {},
      data: {
        'password': password,
      },
      headers: _defaultHeaders,
    );
  }

  // User - Recover Password
  Future<ApiResponse<void>> recoverPassword({
    required String email,
  }) async {
    return apiService.sendRequest<void>(
      endpoint: '/auth/user/$email/recover-password',
      method: 'POST',
      fromJson: (_) {},
      headers: _defaultHeaders,
    );
  }

  // User - Delete User
  Future<ApiResponse<void>> deleteUser({
    required String userId,
  }) async {
    return apiService.sendRequest<void>(
      endpoint: '/auth/user/$userId',
      method: 'DELETE',
      fromJson: (_) {},
      headers: _defaultHeaders,
    );
  }

  // UserResource - Create UserResource with Resource List
  Future<ApiResponse<Map<String, dynamic>>> createUserResource({
    required String userId,
  }) async {
    return apiService.sendRequest<Map<String, dynamic>>(
      endpoint: '/auth/user-resource/with-resource-list',
      method: 'POST',
      fromJson: (data) => data as Map<String, dynamic>,
      data: {
        'userId': userId,
        'resourceNames': [resourceName],
      },
      headers: _defaultHeaders,
    );
  }
}

class _InSync {
  final apiService = ApiService(
    Dio(BaseOptions(baseUrl: dotenv.env['INSYNC_API_URL'] ?? '')),
  );

  Future<ApiResponse<Map<String, dynamic>>> createUser({
    required String name,
    required String email,
    String? deviceId,
    String timezone = '-3',
  }) async {
    return apiService.sendRequest<Map<String, dynamic>>(
      endpoint: '/insync/v1/person',
      method: 'POST',
      fromJson: (data) => data as Map<String, dynamic>,
      data: {
        'deviceId': deviceId ?? '000000000000',
        'name': name,
        'email': email,
        'timezone': timezone,
      },
      headers: await getAuthHeaders(),
    );
  }
}

class _Habits {
  final apiService = ApiService(
    Dio(BaseOptions(baseUrl: dotenv.env['INSYNC_API_URL'] ?? '')),
  );

  Future<ApiResponse<ApiHabitListModel>> list() async {
    return apiService.sendRequest<ApiHabitListModel>(
      endpoint: '/insync/v1/habit/read-all',
      method: 'GET',
      fromJson: (data) {
        // If API returns a list directly
        if (data is List) {
          return ApiHabitListModel(
            habits: data.map((item) => ApiHabitModel.fromJson(item as Map<String, dynamic>)).toList(),
            total: data.length,
          );
        }
        // If it returns an object with habits and total
        return ApiHabitListModel.fromJson(data as Map<String, dynamic>);
      },
      headers: await getAuthHeaders(),
    );
  }

  Future<ApiResponse<ApiHabitModel>> get(String id) async {
    return apiService.sendRequest<ApiHabitModel>(
      endpoint: '/insync/v1/habit/$id',
      method: 'GET',
      fromJson: (data) => ApiHabitModel.fromJson(data as Map<String, dynamic>),
      headers: await getAuthHeaders(),
    );
  }

  Future<ApiResponse<ApiHabitModel>> create(
    ApiHabitCreateModel habit,
  ) async {
    return apiService.sendRequest<ApiHabitModel>(
      endpoint: '/insync/v1/habit',
      method: 'POST',
      fromJson: (data) => ApiHabitModel.fromJson(data as Map<String, dynamic>),
      data: habit.toJson(),
      headers: await getAuthHeaders(),
    );
  }

  Future<ApiResponse<ApiHabitModel>> update(
    String id,
    ApiHabitUpdateModel habit,
  ) async {
    return apiService.sendRequest<ApiHabitModel>(
      endpoint: '/insync/v1/habit',
      method: 'PUT',
      fromJson: (data) => ApiHabitModel.fromJson(data as Map<String, dynamic>),
      data: habit.toJson(),
      headers: await getAuthHeaders(),
    );
  }

  Future<ApiResponse<void>> delete(String id) async {
    return apiService.sendRequest<void>(
      endpoint: '/insync/v1/habit/$id',
      method: 'DELETE',
      fromJson: (_) {},
      headers: await getAuthHeaders(),
    );
  }
}

class _HabitLogs {
  final apiService = ApiService(
    Dio(BaseOptions(baseUrl: dotenv.env['INSYNC_API_URL'] ?? '')),
  );

  Future<ApiResponse<ApiHabitLogModel>> create(
    ApiHabitLogCreateModel log,
  ) async {
    return apiService.sendRequest<ApiHabitLogModel>(
      endpoint: '/insync/v1/habit-logs',
      method: 'POST',
      fromJson: (data) => ApiHabitLogModel.fromJson(data as Map<String, dynamic>),
      data: log.toJson(),
      headers: await getAuthHeaders(),
    );
  }

  Future<ApiResponse<List<ApiHabitLogModel>>> getByHabit(
    String habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'habitId': habitId,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };

    return apiService.sendRequest<List<ApiHabitLogModel>>(
      endpoint: '/insync/v1/habit-logs',
      method: 'GET',
      fromJson: (data) =>
          (data as List).map((item) => ApiHabitLogModel.fromJson(item as Map<String, dynamic>)).toList(),
      queryParams: queryParams,
      headers: await getAuthHeaders(),
    );
  }
}

class _DailyFeed {
  final apiService = ApiService(
    Dio(BaseOptions(baseUrl: dotenv.env['INSYNC_API_URL'] ?? '')),
  );

  Future<ApiResponse<ApiDailyFeedModel>> get({DateTime? date}) async {
    final dateParam = date != null
        ? '?date=${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : '';

    return apiService.sendRequest<ApiDailyFeedModel>(
      endpoint: '/insync/v1/feed$dateParam',
      method: 'GET',
      fromJson: (data) {
        try {
          // Extract data from feed response
          final moodTracker = data['moodTracker'];
          final sleepTracker = data['sleepTracker'];

          // Extract today's habit occurrences
          List<ApiHabitOccurrenceModel> occurrences = [];

          if (data['habits'] != null && data['habits'] is List) {
            final habits = data['habits'] as List;
            for (var habit in habits) {
              DateTime? occDate;
              try {
                occDate = habit['date'] != null ? DateTime.parse(habit['date'].toString()) : null;
              } catch (e) {
                occDate = null;
              }

              if (occDate != null) {
                occurrences.add(ApiHabitOccurrenceModel(
                  habitOccurrenceId: habit['habitOccurrenceId']?.toString() ?? '',
                  habitId: habit['habitId']?.toString() ?? '',
                  habitName: habit['title']?.toString() ?? '',
                  habitDescription: habit['description']?.toString(),
                  habitColor: habit['colorTag']?.toString() ?? '#000000',
                  done: habit['done'] == true,
                  scheduledDate: occDate,
                ));
              }
            }
          }

          return ApiDailyFeedModel(
            moodTracker: moodTracker,
            sleepTracker: sleepTracker,
            habitOccurrences: occurrences,
          );
        } catch (e) {
          // If it fails, return empty
          return ApiDailyFeedModel(
            moodTracker: null,
            sleepTracker: null,
            habitOccurrences: [],
          );
        }
      },
      headers: await getAuthHeaders(),
    );
  }

  Future<ApiResponse<List<ApiHabitOccurrenceModel>>> updateOccurrenceList(
    List<ApiUpdateOccurrenceModel> occurrences,
  ) async {
    return apiService.sendRequest<List<ApiHabitOccurrenceModel>>(
      endpoint: '/insync/v1/habit-occurrence/list',
      method: 'PUT',
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) => ApiHabitOccurrenceModel(
                    habitOccurrenceId: item['habitOccurrenceId']?.toString() ?? '',
                    habitId: item['habitId']?.toString() ?? '',
                    habitName: item['title']?.toString() ?? '',
                    habitDescription: item['description']?.toString(),
                    habitColor: item['colorTag']?.toString() ?? '#000000',
                    done: item['done'] == true,
                    scheduledDate: DateTime.parse(item['date']?.toString() ?? DateTime.now().toIso8601String()),
                  ))
              .toList();
        }
        return [];
      },
      data: occurrences.map((occ) => occ.toJson()).toList(),
      headers: await getAuthHeaders(),
    );
  }
}

class _Insights {
  final apiService = ApiService(
    Dio(BaseOptions(baseUrl: dotenv.env['INSYNC_API_URL'] ?? '')),
  );

  Future<ApiResponse<ApiInsightsModel>> get(DateTime startDate, DateTime endDate) async {
    String formattedStartDate = '${startDate.year.toString().padLeft(4, '0')}-'
        '${startDate.month.toString().padLeft(2, '0')}-'
        '${startDate.day.toString().padLeft(2, '0')}';

    String formattedEndDate = '${endDate.year.toString().padLeft(4, '0')}-'
        '${endDate.month.toString().padLeft(2, '0')}-'
        '${endDate.day.toString().padLeft(2, '0')}';

    final query = 'startDate=$formattedStartDate&endDate=$formattedEndDate';

    return apiService.sendRequest<ApiInsightsModel>(
      endpoint: '/insync/v1/insight?$query',
      method: 'GET',
      fromJson: (data) {
        debugPrint('Insights API Response: $data');
        return ApiInsightsModel.fromJson(data);
      },
      headers: await getAuthHeaders(),
    );
  }
}

class _MoodTracker {
  final apiService = ApiService(
    Dio(BaseOptions(baseUrl: dotenv.env['INSYNC_API_URL'] ?? '')),
  );

  Future<ApiResponse<ApiMoodTrackerModel>> create(
    ApiMoodTrackerCreateModel mood,
  ) async {
    return apiService.sendRequest<ApiMoodTrackerModel>(
      endpoint: '/insync/v1/mood-tracker',
      method: 'POST',
      fromJson: (data) => ApiMoodTrackerModel(
        id: data['id']?.toString() ?? '',
        moodLevel: mood.moodLevel,
        date: DateTime.now(),
        note: mood.note,
      ),
      data: mood.toJson(),
      headers: await getAuthHeaders(),
    );
  }
}

class _SleepTracker {
  final apiService = ApiService(
    Dio(BaseOptions(baseUrl: dotenv.env['INSYNC_API_URL'] ?? '')),
  );

  Future<ApiResponse<ApiSleepTrackerModel>> create(
    ApiSleepTrackerCreateModel sleep,
  ) async {
    return apiService.sendRequest<ApiSleepTrackerModel>(
      endpoint: '/insync/v1/sleep-tracker',
      method: 'POST',
      fromJson: (data) => ApiSleepTrackerModel(
        id: data['id']?.toString() ?? '',
        sleepQuality: sleep.sleepQuality,
        date: DateTime.now(),
        note: sleep.note,
      ),
      data: sleep.toJson(),
      headers: await getAuthHeaders(),
    );
  }
}
