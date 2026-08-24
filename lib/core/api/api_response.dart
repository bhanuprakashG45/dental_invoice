class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(
      success: true,
      message: "",
      data: data,
    );
  }

  factory ApiResponse.failure(String message) {
    return ApiResponse(
      success: false,
      message: message,
    );
  }
}