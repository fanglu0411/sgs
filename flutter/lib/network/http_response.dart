import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_smart_genome/network/core/http_error.dart';

class HttpResponseBean<T> {
  late bool success;
  T? body;

  int? statusCode;

  HttpError? error;

  String? get bodyStr => body?.toString();

  HttpResponseBean.fromBody(T body) {
    success = true;
    this.body = body;
    statusCode = 200;
  }

  HttpResponseBean.fromDio(dio.Response response) {
    success = response.statusCode == 200 || response.statusCode == 304;
    body = response.data is String ? _safeJson(response.data) : response.data;
    statusCode = response.statusCode;
    if (!success) {
      error = HttpError(statusCode!, response.data?.toString() ?? 'response error');
    }
  }

  _safeJson(String data) {
    var _data = data.replaceAll("NaN", '"NaN"').replaceAll('Infinity', '0');
    return json.decode(_data);
  }

  HttpResponseBean.fromError(HttpError error) {
    this.error = error;
    success = false;
    statusCode = error.code;
  }

  HttpResponseBean.error(exp) {
    statusCode = -1;
    success = false;
    String message;
    dio.DioExceptionType? errorType;
    if (exp is dio.DioException) {
      errorType = exp.type;
      statusCode = exp.response?.statusCode ?? -1;
      if (exp.error is SocketException) {
        message = 'Connect Server fail, try again later!';
      } else if (exp.type == dio.DioExceptionType.receiveTimeout) {
        message = 'The request took too lang time to receive data!';
      } else {
        message = '${exp.response?.statusMessage ?? exp.message ?? exp.error}';
      }
      error = HttpError(statusCode!, message, type: errorType, error: exp.error);
    } else {
      // error = dio.DioError(requestOptions: null, error: exp);
      message = exp.toString();
      error = HttpError(statusCode!, message, type: errorType, error: exp);
    }
  }

  @override
  String toString() {
    return 'HttpResponseBean{success: $success, bodyStr: $bodyStr, statusCode: $statusCode, error: $error}';
  }
}
