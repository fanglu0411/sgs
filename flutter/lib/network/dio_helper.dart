import 'dart:convert';
import 'dart:io';

import 'package:dio/io.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:path/path.dart' show join;
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_genome/components/events/http_request_event/logic.dart';
import 'package:flutter_smart_genome/network/empty_retry_interceptor.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:uuid/uuid.dart';

// import 'dio_cache_cipher.dart';

final _uuid = Uuid();

// final DioCacheCipher dioCacheCipher = DioCacheCipher();

final dioCacheOptions = CacheOptions(
// A default store is required for interceptor.
  store: SgsConfigService.get() == null || kIsWeb
      ? MemCacheStore() //
      : FileCacheStore(
          join(SgsConfigService.get()!.applicationDocumentsPath, '_cache')),
  // : HiveCacheStore(SgsConfigService.get()!.applicationDocumentsPath),
// Default.
  policy: CachePolicy.forceCache,
// Optional. Returns a cached response on error but for statuses 401 & 403.
  hitCacheOnErrorExcept: [401, 403],
// Optional. Overrides any HTTP directive to delete entry past this duration.
  maxStale: const Duration(days: 7),
// Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
// Default. Body and headers encryption with your own algorithm.
  cipher: null,
//   cipher: CacheCipher(encrypt: dioCacheCipher.encrypt, decrypt: dioCacheCipher.decrypt),
// Default. Key builder to retrieve requests.
//   keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  keyBuilder: (RequestOptions request) {
    var query = request.data is Map
        ? request.data.entries.map((e) => '${e.key}=${e.value}').join('&')
        : '${request.data}';
    return _uuid.v5(Uuid.NAMESPACE_URL, '${request.uri.toString()}?${query}');
  },
// Default. Allows to cache POST requests.
// Overriding [keyBuilder] is strongly recommended.
  allowPostMethod: true,
);

Options buildNoCacheOptions() {
  return dioCacheOptions
      .copyWith(
        policy: CachePolicy.noCache,
      )
      .toOptions();
}

Options buildCacheOptions(
    {Duration duration = const Duration(days: 7), bool forceRefresh = false}) {
  return dioCacheOptions
      .copyWith(
        maxStale: Nullable(duration),
        policy: forceRefresh
            ? CachePolicy.refreshForceCache
            : CachePolicy.forceCache,
      )
      .toOptions();
}

class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //{"Authorization": "Bearer ${token}"}
    var user = SgsAppService.get()?.loginUser;
    if (user != null) options.headers['Authorization'] = 'Bearer ${user.token}';
    // if (options.data is Map) {
    //   Map data = {...(options.data), 'user_id': SgsConfigService.get()?.userId};
    //   options.data = data;
    // }
    handler.next(options);
  }
}

class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (LOG_ENABLED) {
      var msg = '''
 request: ${options.path}
 headers: ${options.headers}
 params : ${options.data ?? '{data}'}''';
      logger.i(msg);
    }
    // HttpRequestEventLogic.safe().add(HttpRequestItem.request(url: options.uri.toString(), params: options.data ?? {}));
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (LOG_ENABLED) {
      var msg = '''
${response.headers}     
 response: ${response.requestOptions.path}
 code    : ${response.statusCode}
 params  : ${response.requestOptions.data}
 message : ${response.statusMessage}''';
      logger.w(msg);
    }
    Map _data;
    try {
      _data = response.data is Map
          ? response.data
          : (response.data is String
              ? json.decode(response.data)
              : {'data': response.data});
    } catch (e) {
      _data = {'data': response.data};
    }
    HttpRequestEventLogic.safe()?.add(HttpRequestItem.response(
      url: response.requestOptions.uri.toString(),
      data: _data,
      params: response.requestOptions.data ?? {},
      responseHeader: response.headers,
      statusCode: response.statusCode,
      time: DateTime.now(),
    ));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (LOG_ENABLED) {
      var msg = '''
 response: ${err.requestOptions.path}
 code    : ${err.response?.statusCode}
 params  : ${err.requestOptions.data}
 message : ${err.response?.statusMessage ?? err.message ?? err.error}''';
      logger.e(msg);
    }
    HttpRequestEventLogic.safe()?.add(HttpRequestItem.error(
      url: err.requestOptions.uri.toString(),
      error: err.response?.data ?? err.response?.statusMessage ?? err.message,
      params: err.requestOptions.data ?? {},
      statusCode: err.response?.statusCode,
      time: DateTime.now(),
    ));
    super.onError(err, handler);
  }
}

class DioHelper {
  static DioHelper _instance = DioHelper._init();

  static final String browserBaseUrl = "/proxy/api/data";

  String? get baseUrl => SgsAppService.get()?.site?.url;

  late Dio _dio;
  late Dio _thirdDio;

  // DioCacheManagerWrapper _manager;

  bool isWeb = false;

  DioHelper._init() {
    _thirdDio = Dio();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: Duration(seconds: 45),
      receiveTimeout: Duration(seconds: 45),
    ));
    _dio
          ..interceptors.add(CustomInterceptor())
          ..interceptors.add(DioCacheInterceptor(options: dioCacheOptions))
          ..interceptors.add(EmptyRetryInterceptor(dio: _dio)) //
        ;
    if (LOG_ENABLED) {
      _dio.interceptors.add(LogInterceptor());
      _thirdDio.interceptors.add(LogInterceptor());
    }
    // checkCacheSize();
    // dioCacheCipher.test();
  }

  checkCacheSize() async {
    if (kIsWeb) return;

    var cacheFilePath = join(
        SgsConfigService.get()!.applicationDocumentsPath, 'dio_cache.hive');
    var file = File(cacheFilePath);
    if (!file.existsSync()) return;
    var s = await file.stat();
    var max = 1 * 1000 * 1000 * 1000;
    print('cache size: ${s.size}, max: ${max}');
    if (s.size > max) {
      await clearCache();
    }
  }

  factory DioHelper() {
    return _instance;
  }

  Dio get dio => _dio;

  Dio get thirdDio => _thirdDio;

  clearCache() async {
    await dioCacheOptions.store?.clean(staleOnly: false);
  }
}
