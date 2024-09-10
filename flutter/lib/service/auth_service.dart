import 'package:flutter_smart_genome/network/api/simple_request.dart' as http_util;
import 'package:flutter_smart_genome/network/http_response.dart';

/// 验证token是否存在
Future<HttpResponseBean> validateToken({
  required String host,
  required String token,
}) {
  return http_util.postJson(
    path: '${host}/api/token/validate',
    data: {'token': token},
    cache: false,
  );
}

/// load all token, admin
Future<HttpResponseBean> loadTokens({
  required String host,
  required String token,
}) {
  return http_util.get(
    path: '${host}/api/token/list',
    headers: {"Authorization": "Bearer ${token}"},
    cache: false,
  );
}

/// 创建token
Future<HttpResponseBean> createToken({
  required String host,
  required Map data,
  required String token,
}) {
  return http_util.putJson(
    path: '${host}/api/token/create',
    headers: {"Authorization": "Bearer ${token}"},
    data: data,
  );
}

// 删除token (admin)
Future<HttpResponseBean> deleteToken({
  required String host,
  required String token,
  required String targetToken,
}) {
  return http_util.delete(
    path: '${host}/api/token/delete',
    headers: {"Authorization": "Bearer ${token}"},
    data: {'token': targetToken},
  );
}