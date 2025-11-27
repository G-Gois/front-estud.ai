class ApiResponse<T> {
  ApiResponse({
    required this.statusCode,
    this.data,
    this.message,
  });

  final T? data;
  final int statusCode;
  final String? message;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
