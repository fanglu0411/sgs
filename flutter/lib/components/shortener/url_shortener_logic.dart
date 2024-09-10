import 'package:bot_toast/bot_toast.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/constants.dart';
import 'package:flutter_smart_genome/components/shortener/supplier/original_short_supplier.dart';
import 'package:flutter_smart_genome/storage/base_store_provider.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:get/get.dart';

import 'supplier/bitly_supplier.dart';
import 'supplier/short_io_supplier.dart';
import 'supplier/shorten_supplier.dart';
import 'supplier/tinyurl_supplier.dart';

class UrlShortenerLogic extends GetxController {
  ShortenSupplier get shortener => _shortenerList[_currentIndex];

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  bool _shorting = false;

  bool get shorting => _shorting;

  String? _shortedUrl;

  String? get shortedUrl => _shortedUrl;
  String? _error;

  String? get error => _error;

  String? _targetUrl;

  String? get targetUrl => _targetUrl;

  void set targetUrl(String? url) {
    _targetUrl = url;
    // shortUrl(url);
  }

  void changeCurrent(
    int index,
    TextEditingController endpointController,
    TextEditingController domainController,
    TextEditingController tokenController,
  ) {
    _currentIndex = index;

    var s = shortener;
    endpointController.text = s.baseUrl;
    domainController.text = s.domain;
    tokenController.text = s.token;

    shortUrl(targetUrl);
    // update();
  }

  List<ShortenSupplier> _shortenerList = [];

  List<ShortenSupplier> get shortenerList => _shortenerList;

  void addShortener(Map shortener) {}

  ShortenSupplier create(Map map) {
    var supplier = map['supplier'];
    if (supplier == 'bitly') {
      return BitlySupplier(map);
    } else if (supplier == 'short.io') {
      return ShortIoSupplier(map);
    } else if (supplier == 'tinyurl') {
      return TinyurlSupplier(map);
    }
    return OriginalShortSupplier(map);
  }

  @override
  void onInit() {
    super.onInit();
    var __shortenerList = BaseStoreProvider.get().getShortenList();
    if (__shortenerList.length == 0) {
      __shortenerList = SHORT_PLATFORMS;
      for (var s in __shortenerList) {
        BaseStoreProvider.get().updateShortener(s['name'], s);
      }
    }
    _shortenerList = __shortenerList.map(create).sortedBy((e) => e.id).toList();
  }

  @override
  void onReady() {
    super.onReady();
    shortUrl(targetUrl);
  }

  shortUrl(String? url) async {
    if (url == null) return;
    _shorting = true;
    _error = null;
    _shortedUrl = null;
    update();
    var (shortUrl, error) = await shortener.short(url);
    _shortedUrl = shortUrl;
    _error = error;
    _shorting = false;
    update();
  }

  updateSupplier(
    TextEditingController endpointController,
    TextEditingController domainController,
    TextEditingController tokenController,
  ) async {
    var s = shortener;

    s.baseUrl = endpointController.text;
    s.domain = domainController.text;
    s.token = tokenController.text;
    BaseStoreProvider.get().updateShortener(s.name, s.toJson());
    showToast(text: '${s.name} Config updated');

    s.clearCache();
    shortUrl(targetUrl);
  }
}
