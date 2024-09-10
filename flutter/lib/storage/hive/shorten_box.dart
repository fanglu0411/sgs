import 'package:flutter_smart_genome/base/constants.dart';
import 'package:flutter_smart_genome/components/shortener/url_shortener_logic.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isar/isar.dart';

Box<Map> _box() => Hive.box<Map>('url-shorten');

void updateShortener(String supplier, Map data) {
  if (data['name'] == null) data['name'] = supplier;
  _box().put(supplier, data);
}

List<Map> getShortens() {
  List<Map> list = _box().values.toList();
  return list;
}

Future delete() => _box().deleteFromDisk();

Future<int> clear() => _box().clear();
