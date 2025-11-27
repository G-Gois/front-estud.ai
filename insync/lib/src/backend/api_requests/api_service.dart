import 'package:dio/dio.dart';
import 'package:insync/src/backend/api_requests/api_response.dart';
import 'package:insync/src/utils/auth/auth_service.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<ApiResponse<T>> sendRequest<T>({
    required String endpoint,
    required String method,
    required T Function(dynamic) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        data: data,
        queryParameters: queryParams,
        options: Options(
          method: method,
          headers: headers,
        ),
      );

      try {
        final parsedData = fromJson(response.data);
        return SuccessApiResponse<T>(
          data: parsedData,
          statusCode: response.statusCode ?? 200,
        );
      } catch (parsingError) {
        // Detailed parsing error log
        print('❌ Parsing error on endpoint: $endpoint');
        print('📦 Data type received: ${response.data.runtimeType}');
        print('📋 Raw data: ${response.data}');
        print('🔥 Error: $parsingError');

        return ErrorApiResponse<T>(
          isSuccess: true,
          statusCode: response.statusCode ?? 200,
          errorMessage: _parseParsingErrorMessage(parsingError),
        );
      }
    } on DioException catch (apiError) {
      // If receives 401, remove token
      if (apiError.response?.statusCode == 401) {
        await AuthService().removeAuthToken();
      }

      return ErrorApiResponse<T>(
        statusCode: apiError.response?.statusCode ?? 500,
        errorMessage: _extractErrorMessage(apiError),
      );
    } catch (error) {
      return ErrorApiResponse<T>(
        statusCode: 500,
        errorMessage: 'Unknown error: $error',
      );
    }
  }

  String _parseParsingErrorMessage(dynamic error) {
    return 'Error processing response: ${error.toString()}';
  }

  String _extractErrorMessage(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? 'Server error';
      }
      return data.toString();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout exceeded';
      case DioExceptionType.badResponse:
        return 'Invalid server response';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error. Check your internet';
      default:
        return 'Unknown error';
    }
  }
}
