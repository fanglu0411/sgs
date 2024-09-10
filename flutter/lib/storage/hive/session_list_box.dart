import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:hive/hive.dart';

import 'type_ids.dart';

Box<TrackSession> _box() => Hive.box<TrackSession>('sessions');

List<TrackSession> loadSessions(String? speciesId) {
  var list = _box().values.toList();
  if (null != speciesId) {
    list = list.where((s) => s.speciesId == speciesId).toList();
  }
  return list;
}

void addSession(TrackSession session) {
  _box().put(session.storeKey, session);
}

Future deleteSession(TrackSession session) async {
  return _box().delete(session.storeKey);
}

Future<int> clear() => _box().clear();

void delete() => _box().deleteFromDisk();

class SessionAdapter extends TypeAdapter<TrackSession> {
  @override
  TrackSession read(BinaryReader reader) {
    Map map = reader.readMap();
    return TrackSession.fromMap(map);
  }

  @override
  int get typeId => SESSION_LIST_TYPE_ID;

  @override
  void write(BinaryWriter writer, TrackSession obj) {
    writer.writeMap(obj.toMap());
  }
}
