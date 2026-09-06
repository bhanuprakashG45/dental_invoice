import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:invoice/core/local_storage/user_local_storage.dart';

class DioInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await UserLocalStorage.getAccessToken();

    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    debugPrint('${options.method} ${options.uri}');
    debugPrint('Body: ${options.data}');

    debugPrint(
      'Authorization: ${accessToken != null && accessToken.isNotEmpty ? 'Bearer ***' : 'Not available'}',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('${response.statusCode} ${response.requestOptions.uri}');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(err.message);
    debugPrint('URL: ${err.requestOptions.uri}');

    handler.next(err);
  }
}
