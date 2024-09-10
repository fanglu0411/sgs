import 'package:dbio_utils/base/lru_cache.dart';

import 'track_parser.dart';

class TrackParseManager {
  late LruCache _cache;

  addTask(String trackId, TrackDataParser parser) {
    _cache.save(trackId, parser);
    parser.parse().then((value) {});
  }
}