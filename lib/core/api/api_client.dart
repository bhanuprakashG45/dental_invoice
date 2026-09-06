import 'package:dio/dio.dart';
import 'package:invoice/core/api/api_endpoints.dart';
import 'package:invoice/core/api/dio_interceptor.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json,
    ),
  )..interceptors.add(DioInterceptor());

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    final response = await dio.get(path, queryParameters: queryParameters);

    return parser(response.data as Map<String, dynamic>);
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    final response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );

    return parser(response.data as Map<String, dynamic>);
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    final response = await dio.put(path, data: data);

    return parser(response.data as Map<String, dynamic>);
  }

  Future<T> delete<T>(
    String path, {
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    final response = await dio.delete(path);

    return parser(response.data as Map<String, dynamic>);
  }
}
