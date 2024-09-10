import 'package:dio/dio.dart';
import 'package:flutter_smart_genome/components/shortener/supplier/shorten_supplier.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';
import 'package:flutter_smart_genome/network/dio_helper.dart';

class BitlySupplier extends ShortenSupplier {
  BitlySupplier(super.map);

  @override
  Future<(String? shortUrl, String? error)> shortApi(String url) async {
    try {
      var response = await DioHelper().thirdDio.post(
        baseUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {'long_url': url, "domain": domain},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map body = response.data;
        String? url = body['link'];
        return (url, null);
      }
      Map body = response.data;
      return (null, body['message'] as String?);
    } catch (e) {
      if (e is DioException) {
        Map? data = e.response?.data;
        return (null, (data?['message'] as String?) ?? '${e}');
      }
      return (null, '$e');
    }
  }
}
