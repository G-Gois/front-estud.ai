import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_response.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
  })  : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl.isEmpty ? 'https://api.estud.ai' : baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
            headers: const {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    if (!kReleaseMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
      );
    }
  }

  final Dio _dio;
  String? _authToken;

  Dio get rawClient => _dio;

  void setAuthToken(String? token) {
    _authToken = token?.trim();
  }

  Map<String, dynamic> _headers([Map<String, dynamic>? extra]) {
    final headers = <String, dynamic>{};
    headers.addAll(extra ?? {});
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? mapper,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: query,
        options: Options(headers: _headers(headers)),
      );
      final data = mapper != null ? mapper(response.data) : response.data as T;
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 500,
        data: data,
        message: response.statusMessage,
      );
    } on DioException catch (error) {
      return ApiResponse<T>(
        statusCode: error.response?.statusCode ?? 500,
        message: _parseError(error),
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? mapper,
  }) async {
    try {
      final response = await _dio.post(
        path,
        queryParameters: query,
        data: body,
        options: Options(headers: _headers(headers)),
      );
      final data = mapper != null ? mapper(response.data) : response.data as T;
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 500,
        data: data,
        message: response.statusMessage,
      );
    } on DioException catch (error) {
      return ApiResponse<T>(
        statusCode: error.response?.statusCode ?? 500,
        message: _parseError(error),
      );
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? mapper,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: body,
        options: Options(headers: _headers(headers)),
      );
      final data = mapper != null ? mapper(response.data) : response.data as T;
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 500,
        data: data,
        message: response.statusMessage,
      );
    } on DioException catch (error) {
      return ApiResponse<T>(
        statusCode: error.response?.statusCode ?? 500,
        message: _parseError(error),
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? headers,
    T Function(dynamic data)? mapper,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        options: Options(headers: _headers(headers)),
      );
      final data = mapper != null ? mapper(response.data) : response.data as T;
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 500,
        data: data,
        message: response.statusMessage,
      );
    } on DioException catch (error) {
      return ApiResponse<T>(
        statusCode: error.response?.statusCode ?? 500,
        message: _parseError(error),
      );
    }
  }

  String? _parseError(DioException error) {
    if (error.response?.data is Map && error.response?.data['message'] != null) {
      return error.response?.data['message']?.toString();
    }
    return error.message;
  }
}
