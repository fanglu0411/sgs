import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:hive/hive.dart';

Box<TrackSession> _box() => Hive.box<TrackSession>('species-sessions');

// List<TrackSession> loadSpeciesSessions(){
//   return speciesSessionBox.values;
// }

void setSpeciesSession(TrackSession session) {
  _box().put(session.speciesId, session);
}

TrackSession? getSpeciesSession(String speciesId) {
  return _box().get(speciesId);
}

Future<int> clear() => _box().clear();