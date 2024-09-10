import 'package:dio/dio.dart';

class HttpError {
  String message;
  int code;
  Object? error;
  DioExceptionType? type;

  HttpError(this.code, this.message, {this.type, this.error});

  @override
  String toString() {
    return '$code: ${message}';
  }
}
