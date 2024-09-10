import 'package:flutter_smart_genome/components/shortener/supplier/bitly_supplier.dart';
import 'package:flutter_smart_genome/components/shortener/supplier/short_io_supplier.dart';

abstract class ShortenSupplier {
  late int id;
  late String supplier;
  late String website;
  late String name;
  late String baseUrl;
  late String domain;
  late String token;

  Map toJson() {
    return {
      'id': id,
      'supplier': supplier,
      'website': website,
      'name': name,
      'baseUrl': baseUrl,
      'domain': domain,
      'token': token,
    };
  }

  Map<String, String> _shortCache = {};

  void clearCache() {
    _shortCache.clear();
  }

  bool get isOrigin => false;

  ShortenSupplier(Map map) {
    id = map['id'];
    supplier = map['supplier'];
    website = map['website'];
    name = map['name'];
    token = map['token'] ?? map['key'];
    domain = map['domain'];
    baseUrl = map['baseUrl'];
  }

  Future<(String? shortUrl, String? error)> short(String url) async {
    if (_shortCache[url] != null) {
      return (_shortCache[url]!, null);
    }
    var _url = await shortApi(url);
    if (null != _url.$1) {
      _shortCache[url] = _url.$1!;
    }
    return _url;
  }

  Future<(String? shortUrl, String? error)> shortApi(String url);
}
