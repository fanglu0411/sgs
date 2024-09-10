import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/page/track/zoom_config.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class RelationParams {
  // Track track;
  ChromosomeData chr1;
  ChromosomeData chr2;
  String? speciesId;

  double sizeOfPixel1;
  double pixelPerSeq1;
  Range range1;

  double? sizeOfPixel2;
  double? pixelPerSeq2;
  Range? range2;

  ZoomConfig zoomConfig1;
  ZoomConfig? zoomConfig2;

  ScaleLinear<num> scale1;
  ScaleLinear<num>? scale2;

  // TrackType get trackType => track.trackType;

  RelationParams({
    // this.track,
    required this.chr1,
    required this.chr2,
    // required this.speciesId,
    required this.range1,
    required this.sizeOfPixel1,
    required this.pixelPerSeq1,
    required this.zoomConfig1,
    this.range2,
    this.sizeOfPixel2,
    this.pixelPerSeq2,
    this.zoomConfig2,
    required this.scale1,
    this.scale2,
  });

  // String get trackId => track?.id;

  bool get prepared => range2 != null && scale2 != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationParams &&
          runtimeType == other.runtimeType &&
          // track == other.track &&
          chr1 == other.chr1 &&
          chr2 == other.chr2 &&
          speciesId == other.speciesId &&
          sizeOfPixel1 == other.sizeOfPixel1 &&
          pixelPerSeq1 == other.pixelPerSeq1 &&
          range1 == other.range1 &&
          sizeOfPixel2 == other.sizeOfPixel2 &&
          pixelPerSeq2 == other.pixelPerSeq2 &&
          range2 == other.range2; // &&
  // zoomConfig1 == other.zoomConfig1 &&
  // zoomConfig2 == other.zoomConfig2;

  @override
  int get hashCode =>
      // track.hashCode ^
      chr1.hashCode ^ chr2.hashCode ^ speciesId.hashCode ^ sizeOfPixel1.hashCode ^ pixelPerSeq1.hashCode ^ range1.hashCode ^ sizeOfPixel2.hashCode ^ pixelPerSeq2.hashCode ^ range2.hashCode; // ^ zoomConfig1.hashCode ^ zoomConfig2.hashCode;

  @override
  String toString() {
    return 'RelationParams{ chr1: ${chr1.chrName}, chr2: ${chr2.chrName}, speciesId: $speciesId, sizeOfPixel1: $sizeOfPixel1, pixelPerSeq1: $pixelPerSeq1, range1: $range1, sizeOfPixel2: $sizeOfPixel2, pixelPerSeq2: $pixelPerSeq2, range2: $range2, zoomConfig1: $zoomConfig1, zoomConfig2: $zoomConfig2}';
  }

  bool scaleChanged(RelationParams params) {
    return params.sizeOfPixel1 != sizeOfPixel1 || params.sizeOfPixel2 != sizeOfPixel2;
  }

  bool rangeChanged(RelationParams params) {
    return params.range1 != range1 || params.range2 != range2;
  }
}
