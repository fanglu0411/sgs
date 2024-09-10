import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';
import 'package:flutter_smart_genome/page/track/theme/gff_style.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/interactive_style.dart';
import 'package:flutter_smart_genome/widget/track/bam_coverage/bam_coverage_style.dart';
import 'package:flutter_smart_genome/widget/track/bam_reads/bam_reads_style.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/bed/bed_style.dart';
import 'package:flutter_smart_genome/widget/track/bigwig/bigwig_style.dart';
import 'package:flutter_smart_genome/widget/track/cell_expression/cell_exp_style.dart';
import 'package:flutter_smart_genome/widget/track/eqtl/eqtl_style.dart';
import 'package:flutter_smart_genome/widget/track/group_coverage/group_coverage_style.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_style.dart';
import 'package:flutter_smart_genome/widget/track/methylation/methylation_style.dart';
import 'package:flutter_smart_genome/widget/track/peak/co_access_style.dart';
import 'package:flutter_smart_genome/widget/track/peak/peak_style.dart';
import 'package:flutter_smart_genome/widget/track/sequence/seq_style.dart';
import 'package:flutter_smart_genome/widget/track/vcf/vcf_style.dart';
import 'package:flutter_smart_genome/widget/track/vcf_sample/vcf_sample_style.dart';
import 'package:flutter_smart_genome/page/track/theme/integraged/default_themes_map.dart' as theme_map;

class TrackTheme {
  late Map<TrackType, dynamic> _persistThemeMap;

  late String name;

  Brightness brightness = Brightness.light;

  TrackTheme(this.name, Map<String, dynamic> persistThemeMap, [this.brightness = Brightness.light]) {
    _persistThemeMap = persistThemeMap.map<TrackType, dynamic>((key, value) => MapEntry<TrackType, dynamic>(parseTrackType(key), value));
  }

  Map<TrackType, dynamic> get themeMap => _persistThemeMap;

  Map<String, dynamic> get persistJson {
    return _persistThemeMap.map((key, value) => MapEntry(trackTypeString(key), _persistMap(value)));
  }

  List get trackTypes => _persistThemeMap.keys.toList();

  Map? getTrackStyleMap(TrackType type) {
    return _persistThemeMap[type];
  }

  TrackStyle getTrackStyle(TrackType type) {
    Map _map = getTrackStyleMap(type) ?? {"dark": {}, "light": {}};
    switch (type) {
      case TrackType.gff:
        return GffStyle(_map, brightness);
      case TrackType.ref_seq:
        return SeqStyle(_map, brightness);
      case TrackType.vcf_coverage:
        return VcfStyle(_map, brightness);
      case TrackType.vcf_sample:
        return VcfSampleStyle(_map, brightness);
      case TrackType.bigwig:
        return BigWigStyle(_map, brightness);
      case TrackType.bam:
        return TrackStyle(_map, brightness);
      case TrackType.bam_coverage:
        return BamCoverageStyle(_map, brightness);
      case TrackType.bam_reads:
        return BamReadsStyle(_map, brightness);
      case TrackType.methylation:
        return MethylationStyle(_map, brightness);
      case TrackType.hic:
        return HicStyle(_map, brightness);
      case TrackType.interactive:
        return InteractiveStyle(_map, brightness);
      case TrackType.sc_exp:
        return CellExpStyle(_map, brightness);
      case TrackType.peak:
        return PeakStyle(_map, brightness);
      case TrackType.sc_group_coverage:
        return GroupCoverageStyle(_map, brightness);
      case TrackType.sc_co_access:
        return CoAccessStyle(_map, brightness);
      case TrackType.bed:
        return BedStyle(_map, brightness);
      case TrackType.eqtl:
        return EQTLStyle(_map, brightness);
      case TrackType.unknown:
        return TrackStyle(_map, brightness);
      default:
        return TrackStyle(_map, brightness);
    }
  }

  void setTrackStyle(TrackType trackType, TrackStyle trackStyle) {
    _persistThemeMap[trackType] = trackStyle.toPersistMap();
  }

  static List<TrackTheme> defaultTrackThemes() {
    return [
      TrackTheme('theme_jbrowser', theme_map.theme_jbrowser),
      TrackTheme('theme_IGV', theme_map.theme_IGV),
      TrackTheme('Red', theme_map.theme_red),
      TrackTheme('Blue', theme_map.theme_blue),
      TrackTheme('Green', theme_map.theme_green),
    ];
  }

  TrackTheme.defaultTheme([String name = 'Sgs-default', this.brightness = Brightness.light]) {
    this.name = name;
    _persistThemeMap = theme_map.theme_jbrowser.map<TrackType, dynamic>((key, value) => MapEntry<TrackType, dynamic>(parseTrackType(key), value));
    // _persistThemeMap = {
    //   TrackType.ref_seq: SeqStyle.defaultStyle().toPersistMap(),
    //   TrackType.gff: GffStyle.defaultTheme().toPersistMap(),
    //   TrackType.vcf_coverage: VcfStyle.base().toPersistMap(),
    //   TrackType.vcf_sample: VcfSampleStyle.base().toPersistMap(),
    //   TrackType.bam_coverage: BamCoverageStyle.base().toPersistMap(),
    //   TrackType.bam_reads: BamReadsStyle.base().toPersistMap(),
    //   TrackType.bigwig: BigWigStyle.base().toPersistMap(),
    //   TrackType.hic: HicStyle.base().toPersistMap(),
    //   TrackType.interactive: InteractiveStyle.base().toPersistMap(),
    //   TrackType.methylation: MethylationStyle.base().toPersistMap(),
    //   TrackType.sc_exp: CellExpStyle.base().toPersistMap(),
    //   TrackType.peak: PeakStyle.base().toPersistMap(),
    //   TrackType.sc_group_coverage: GroupCoverageStyle.base().toPersistMap(),
    // };
  }

  void resetDefault() {
    // _persistThemeMap = TrackTheme.defaultTheme()._persistThemeMap;
    TrackTheme theme;
    if (name.toLowerCase().contains('blue')) {
      theme = TrackTheme('Blue', theme_map.theme_blue);
    } else if (name.toLowerCase().contains('green')) {
      theme = TrackTheme('Green', theme_map.theme_green);
    } else if (name.toLowerCase().contains('jbrowser')) {
      theme = TrackTheme('theme_jbrowser', theme_map.theme_jbrowser);
    } else if (name.toLowerCase().contains('igv')) {
      theme = TrackTheme('theme_IGV', theme_map.theme_IGV);
    } else {
      theme = TrackTheme('Red', theme_map.theme_red);
    }
    _persistThemeMap = theme._persistThemeMap;
  }

  Map<String, dynamic> toPersistMap([Map? map]) {
    return (map ?? _persistThemeMap).map<String, dynamic>((key, value) {
      return MapEntry<String, dynamic>(key, _persistMap(value));
    });
  }

  Map _persistMap(Map map) {
    return map.map((key, value) {
      var _value = value;
      if (value is Map) {
        _value = _persistMap(value);
      } else if (value is Color) {
        _value = value.hexString;
      }
      return MapEntry(key, _value);
    });
  }

  TrackTheme merge(TrackTheme theme) {
    _mergeMap(_persistThemeMap, theme._persistThemeMap);
    return this;
  }

  Map _mergeMap(Map map1, Map map2) {
    map2.forEach((key, value) {
      if (map1.containsKey(key) && value is Map) {
        map1[key] = _mergeMap(map1[key], value);
      } else {
        map1[key] = value;
      }
    });
    return map1;
  }

  @override
  String toString() {
    return 'TrackTheme{ name: $name, brightness: $brightness, $_persistThemeMap,}';
  }
}
