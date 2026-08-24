import 'package:dio/dio.dart';

class ApiException {
  static String getError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection Timeout";

      case DioExceptionType.sendTimeout:
        return "Send Timeout";

      case DioExceptionType.receiveTimeout:
        return "Receive Timeout";

      case DioExceptionType.connectionError:
        return "No Internet Connection";

      case DioExceptionType.badResponse:
        return e.response?.data["message"] ??
            "Something went wrong";

      default:
        return "Something went wrong";
    }
  }
}