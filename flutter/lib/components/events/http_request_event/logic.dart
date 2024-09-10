import 'package:get/get.dart';

class HttpRequestItem {
  String? type;
  String url;
  Map params;
  dynamic responseHeader;
  Map? data;
  int? statusCode;
  DateTime? time;
  dynamic error;

  HttpRequestItem.request({required this.url, required this.params}) {
    type = 'Request';
    error = null;
  }

  HttpRequestItem.response({
    required this.url,
    required this.statusCode,
    required this.params,
    this.data,
    required this.time,
    this.responseHeader,
  }) {
    type = 'Response';
  }

  HttpRequestItem.error({
    required this.url,
    this.statusCode,
    required this.params,
    this.time,
    this.error,
  });
}

class HttpRequestEventLogic extends GetxController {
  static HttpRequestEventLogic? safe() {
    if (Get.isRegistered<HttpRequestEventLogic>()) {
      return Get.find<HttpRequestEventLogic>();
    }
    return null;
  }

  List<HttpRequestItem> _data = [];

  int get count => _data.length;

  bool get isEmpty => count == 0;

  List<HttpRequestItem> get data => _data;

  void add(HttpRequestItem item) {
    if (_data.length > 100) {
      _data.removeAt(0);
    }
    _data.add(item);
    update();
  }

  void clear() {
    _data.clear();
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
