import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/util/logger.dart';

const cacheDuration = Duration(days: 7);

Future<HttpResponseBean<Map>> postJson({
  required String path,
  Dio? dio,
  Map headers = const {},
  Map? data,
  bool cache = false,
  bool forceRefresh = false,
  Duration? duration,
  CancelToken? cancelToken,
  ResponseType responseType = ResponseType.json,
  Duration receiveTimeOut = const Duration(seconds: 30),
  ProgressCallback? onReceiveProgress,
}) async {
  try {
    Options cacheOptions = buildCacheOptions(
      duration: duration ?? cacheDuration,
      forceRefresh: !cache || (forceRefresh),
    );
    Options options = cacheOptions.copyWith(
      headers: {
        ...headers,
        // 'Content-Type': 'application/json',
      },
      responseType: responseType,
      receiveTimeout: receiveTimeOut,
    );
    var response = await (dio ?? DioHelper().dio).post(
      path,
      options: options,
      data: data,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    return HttpResponseBean.fromDio(response);
  } catch (e, stackTrack) {
    logger.e(e);
    logger.e(stackTrack);
    return HttpResponseBean.error(e);
  }
}

Future<HttpResponseBean> postForm({
  required String path,
  Dio? dio,
  Map headers = const {},
  required Map<String, dynamic> data,
  CancelToken? cancelToken,
}) async {
  try {
    FormData formData = FormData.fromMap(data);
    Options cacheOptions = buildCacheOptions(
      duration: cacheDuration,
      forceRefresh: true,
    );
    Options options = cacheOptions.copyWith(
      headers: {
        ...headers,
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
      },
    );
    var response = await (dio ?? DioHelper().dio).post(
      path,
      options: options,
      data: formData, //data.keys.map((k) => '$k=${data[k]}').join('&'),
    );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

/// bytes or file need one
Future<HttpResponseBean> postMultipart(
  String path, {
  Dio? dio,
  List<int>? bytes,
  String? file,
  String? filename,
  ProgressCallback? onSendProgress,
  CancelToken? cancelToken,
}) async {
//  var formData = FormData.fromMap({
//    "type": "giff",
//    "file": MultipartFile.fromBytes(bytes, filename: "upload.txt"),
//  });

  var formData = FormData();
  var fileEntry;
  if (file != null) {
    fileEntry = MapEntry('file', MultipartFile.fromFileSync(file));
  } else {
    fileEntry = MapEntry("file", MultipartFile.fromBytes(bytes!, filename: filename ?? "upload.txt"));
  }
  formData.files.add(fileEntry);
  try {
    Options cacheOptions = buildCacheOptions(
      duration: cacheDuration,
      forceRefresh: true,
    );
    Options options = cacheOptions.copyWith();
    var resp = await (dio ?? DioHelper().dio).post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      options: options,
//      onReceiveProgress: (count, total) {
//        print('reciving count:${count}, total$total');
//      },
    );
    return HttpResponseBean.fromDio(resp);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

Future<HttpResponseBean> get({
  required String path,
  Dio? dio,
  Map headers = const {},
  Map? params,
  bool cache = false,
  bool forceRefresh = false,
  ResponseType? responseType,
  CancelToken? cancelToken,
}) async {
  try {
    Options cacheOptions = buildCacheOptions(
      duration: cacheDuration,
      forceRefresh: !cache || (forceRefresh),
    );
    Options options = cacheOptions.copyWith(
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
      responseType: responseType,
    );
    var response = await (dio ?? DioHelper().dio).get(path, options: options, cancelToken: cancelToken);
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

Future<HttpResponseBean> put({
  required String path,
  Dio? dio,
  Map headers = const {},
  required Map data,
  CancelToken? cancelToken,
}) async {
  try {
    var response = await (dio ?? DioHelper().dio).put(
      path,
      options: Options(headers: {...headers}),
      data: data,
      cancelToken: cancelToken,
    );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

Future<HttpResponseBean> putJson({
  required String path,
  Dio? dio,
  Map headers = const {},
  required Map data,
  CancelToken? cancelToken,
}) async {
  try {
    Options cacheOptions = buildCacheOptions(
      duration: cacheDuration,
      forceRefresh: true,
    );
    Options options = cacheOptions.copyWith(
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
    );
    var response = await (dio ?? DioHelper().dio).put(
      path,
      options: options,
      data: json.encode(data),
      cancelToken: cancelToken,
    );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

Future<HttpResponseBean> putForm({
  required String path,
  Dio? dio,
  Map headers = const {},
  required Map<String, dynamic> data,
  CancelToken? cancelToken,
}) async {
  try {
    FormData formData = FormData.fromMap(data);
    var response = await (dio ?? DioHelper().dio).put(
      path,
      options: Options(headers: {
        ...headers,
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
      }),
      data: formData, //data.keys.map((k) => '$k=${data[k]}').join('&'),
      cancelToken: cancelToken,
    );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

Future<HttpResponseBean> delete({
  required String path,
  Dio? dio,
  Map headers = const {},
  Map? data,
  CancelToken? cancelToken,
}) async {
  try {
    var response = await (dio ?? DioHelper().dio).delete(
      path,
      options: Options(headers: {...headers}),
      data: data,
      cancelToken: cancelToken,
    );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}

Future<HttpResponseBean> download({
  required String url,
  required String savePath,
  Dio? dio,
  Map headers = const {},
  CancelToken? cancelToken,
  ProgressCallback? progress,
}) async {
  try {
    Options options = buildNoCacheOptions().copyWith(
      headers: {...headers},
    );
    var response = await (dio ?? DioHelper().dio).download(
      url,
      savePath,
      options: options,
      onReceiveProgress: progress,
      cancelToken: cancelToken,
    );
    return HttpResponseBean.fromDio(response);
  } catch (e) {
    return HttpResponseBean.error(e);
  }
}
