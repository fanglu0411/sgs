import 'package:hive/hive.dart';

Box _box() => Hive.box('grouped-track-list');

void setGroupedTracks(String speciesId, List<String> tracks) async {
  await _box().put(speciesId, tracks);
}

List<String> getGroupedTracks(String speciesId) {
  return _box().get(speciesId, defaultValue: <String>[]);
}

Future<int> clear() => _box().clear();
