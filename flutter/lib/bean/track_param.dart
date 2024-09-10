import 'package:flutter_smart_genome/page/track/zoom_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';

class TrackParams {
  late Track track;
  late String speciesName;
  late String speciesId;
  late String chrId;
  late ChromosomeData chr;

  // Species species;

  /// range per pixel
  late double bpPerPixel;
  late ZoomConfig zoomConfig;

  ///
  /// pixels of each seq
  ///
  late double pixelPerBp;

  TrackParams({
    required this.track,
    required this.speciesId,
    required this.speciesName,
    required this.chrId,
    required this.chr,
    required this.bpPerPixel,
    required this.zoomConfig,
    required this.pixelPerBp,
  });

  String? get trackTypeStr => track.bioType;

  TrackType get trackType => track.trackType;

  String get trackId => '${track.id}';

  String get key => '$speciesId/tracks/$trackTypeStr/$chrId/${track.id}';

  String get nameKey => '$speciesId/$speciesName/tracks/$trackTypeStr/$chrId/${chr.chrName}/${track.id}';

  Map toMap() {
    var map = {};
    if (trackTypeStr != null) map['track_type'] = trackTypeStr;
    map['species_name'] = speciesName;
    map['species_id'] = speciesId;
    map['chr_id'] = chrId;
    map['chr'] = chr;
    return map;
  }

//  fromMap(Map map) {
//    trackType = map[FileItem.columnTrackType];
//    species = map[FileItem.columnSpecies];
//    chr = map[FileItem.columnChr];
//    fileName = map[FileItem.columnFileName];
//  }

  @override
  String toString() {
    return 'path: $key, scale: $bpPerPixel, pixOfRange:${pixelPerBp}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is TrackParams && runtimeType == other.runtimeType && track == other.track && speciesName == other.speciesName && speciesId == other.speciesId && chrId == other.chrId && bpPerPixel == other.bpPerPixel && pixelPerBp == other.pixelPerBp;

  @override
  int get hashCode => track.hashCode ^ speciesName.hashCode ^ speciesId.hashCode ^ chrId.hashCode ^ bpPerPixel.hashCode ^ pixelPerBp.hashCode;
}