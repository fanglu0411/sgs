import 'package:hive_flutter/hive_flutter.dart';

Box<List<String>> _box() => Hive.box<List<String>>('compare-history');

void addCompareHistories(String scId, List<String> features) {
  List<String> list = _box().get(scId, defaultValue: <String>[])!;
  features.sort();
  String item = features.join(',');
  if (list.contains(item)) return;
  list.add(item);
  _box().put(scId, list);
}

List<List<String>> getCompareHistories(String scId) {
  List<String> list = _box().get(scId, defaultValue: <String>[])!;
  return list.map((e) => e.split(',')).toList();
}

void deleteCompareHistories(String scId, List<String> features) {
  List<String> list = _box().get(scId, defaultValue: <String>[])!;

  features.sort();
  String item = features.join(',');

  list.remove(item);
  _box().put(scId, list);
}

Future delete() => _box().deleteFromDisk();

Future<int> clear() => _box().clear();
