import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';
import 'package:flutter_smart_genome/network/http_response.dart';

Future<HttpResponseBean> fileUpload({
  List<int>? bytes,
  String? file,
  String? filename,
  ProgressCallback? onSendProgress,
}) async {
  var url = '/api/file/upload';
  return postMultipart(url, bytes: bytes, file: file, filename: filename, onSendProgress: onSendProgress);
}