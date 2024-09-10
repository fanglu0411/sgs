import 'package:flutter_smart_genome/components/shortener/supplier/shorten_supplier.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';

class OriginalShortSupplier extends ShortenSupplier {
  OriginalShortSupplier(super.map);

  bool get isOrigin => true;

  @override
  Future<(String? shortUrl, String? error)> short(String url) async {
    return (url, null);
  }

  @override
  Future<(String? shortUrl, String? error)> shortApi(String url) async {
    return (url, null);
  }
}
