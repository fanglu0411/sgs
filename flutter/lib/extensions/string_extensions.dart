import 'package:flutter_smart_genome/browser/routing_data.dart';

extension StringExtension on String {
  RoutingData get parseRoutingData {
    var uri = Uri.parse(this);
    return RoutingData(
      queryParameters: uri.queryParameters,
      route: uri.path,
    );
  }

  cut(int length) {
    if (this.length > length) {
      return this.substring(0, length);
    }
    return this;
  }
}
