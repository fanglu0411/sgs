import 'package:flutter_smart_genome/components/remote_file_manager_widget.dart';
import 'package:path/path.dart' as path;

class TrackFile {
  RemoteFile remoteFile;

  TrackFile.from(this.remoteFile);

  String? _trackName;

  void set trackName(String trackName) {
    _trackName = trackName;
  }

  String get trackName {
    if (_trackName == null) {
      _trackName = path.basename(remoteFile.path!);
    }
    return _trackName!;
  }
}

mixin TrackFileMixin {
  String? _trackName;

  void set trackName(String? trackName) {
    _trackName = trackName;
  }

  String? get trackName => _trackName;
}