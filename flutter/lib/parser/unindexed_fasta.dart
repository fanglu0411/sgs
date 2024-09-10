import 'package:dbio_utils/generic_filehandle/generic_file_handle.dart';
import 'package:dbio_utils/generic_filehandle/local_file.dart';
import 'package:dbio_utils/gff/api.dart';
import 'package:dbio_utils/gff/gff.dart';
import 'package:flutter_smart_genome/parser/track_parser.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/upload/platform_entry.dart';

class UnIndexedGff extends TrackDataParser {
  late GenericFileHandle _gffFile;

  UnIndexedGff(UploadFileItem gff) {
    _gffFile = LocalFile(gff.file);
  }

  List<BaseFeature>? _features;

  Future<List<BaseFeature>> loadFeatures({required String ref, required Range range}) async {
    var __features = _features!.where((f) => f is GffFeature && Range(start: f.start, end: f.end).intersection(range) != null);
    // print(__features?.sublist(0, 100));
    return __features.toList();
  }

  @override
  Future parse() async {
    if (null == _features) {
      _features = await parseFile(_gffFile).toList();
      logger.d('feature count: ${_features!.length}');
    }
    return _features;
  }
}