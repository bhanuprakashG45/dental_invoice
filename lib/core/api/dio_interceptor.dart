import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      "Accept": "application/json",
      "Content-Type": "application/json",
    });

    debugPrint("${options.method} ${options.uri}");
    debugPrint("Body: ${options.data}");

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint("${response.statusCode} ${response.requestOptions.uri}");

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint("${err.message}");
    debugPrint("URL: ${err.requestOptions.uri}");

    handler.next(err);
  }
}
