import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';

/// cache 为空的时候刷新下数据
class EmptyRetryInterceptor extends Interceptor {
  static final String RETRY_KEY = '_cache_retry';

  late Dio dio;

  EmptyRetryInterceptor({required this.dio}) {}

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    var requestOptions = response.requestOptions;
    if (_isEmptyResponse(response)) {
      print('refresh data: ${response.requestOptions.path}');
      var refreshOptions = buildCacheOptions(forceRefresh: true);
      var _requestOptions = requestOptions.copyWith(extra: refreshOptions.extra);
      var _resp = await dio.fetch(_requestOptions); //.then((value) => handler.resolve(value));
      handler.resolve(_resp);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }

  bool _isEmptyResponse(Response response) {
    bool isEmpty = false;
    try {
      var _json = response.data is String ? json.decode(response.data) : response.data;
      if (_json is Map) {
        var keys = _json.keys.filter((k) => k != 'header').toList();
        if (keys.length == 0) {
          isEmpty = true;
        } else if (keys.length == 1) {
          isEmpty = _json.values.first == null || _json.values.first.length == 0;
        } else if (keys.contains('data')) {
          isEmpty = _json['data'] == null || _json['data'].length == 0;
        } else {
          isEmpty = keys.any((k) => (_json[k] == null || _json[k] is Map || _json[k] is List) && _json[k].length == 0);
        }
      } else if (_json is List) {
        isEmpty = _json.length == 0;
      }
    } catch (e) {
      print(e);
    }
    return isEmpty && response.statusCode == 304;
  }
}
