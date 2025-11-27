abstract class ApiResponse<T> {
  final int statusCode;
  final bool isSuccess;

  ApiResponse({
    required this.statusCode,
    required this.isSuccess,
  });

  // Getters to facilitate access
  T? get data => this is SuccessApiResponse<T>
      ? (this as SuccessApiResponse<T>).data
      : null;

  String? get errorMessage => this is ErrorApiResponse<T>
      ? (this as ErrorApiResponse<T>).errorMessage
      : null;
}

class SuccessApiResponse<T> extends ApiResponse<T> {
  @override
  final T data;

  SuccessApiResponse({
    required this.data,
    required super.statusCode,
  }) : super(
          isSuccess: true,
        );
}

class ErrorApiResponse<T> extends ApiResponse<T> {
  @override
  final String errorMessage;

  ErrorApiResponse({
    required this.errorMessage,
    required super.statusCode,
    super.isSuccess = false,
  });
}
