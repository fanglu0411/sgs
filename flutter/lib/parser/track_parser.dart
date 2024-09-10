import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/parser/bigwig_parser.dart';
import 'package:flutter_smart_genome/parser/vcf_parser.dart';

abstract class TrackDataParser {
  static TrackDataParser? findParser(Track track) {
    if (track.isBigWig) return BigWigParser();
    if (track.isVcfCoverage) return VcfParser();
    return null;
  }

  Future parse();
}