import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/hic_relation_layout.dart';
import 'package:flutter_smart_genome/widget/track/bam_reads/bam_reads_layout.dart';
import 'package:flutter_smart_genome/widget/track/bam_reads/bam_reads_layout_paired.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/fast_bed_feature_layout.dart';
import 'package:flutter_smart_genome/widget/track/cell_expression/cell_exp_feature_layout.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_feature_layout.dart';
import 'package:flutter_smart_genome/widget/track/peak/peak_layout.dart';
import 'package:flutter_smart_genome/widget/track/peak/peak_pair_layout.dart';
import 'package:flutter_smart_genome/widget/track/relation/relation_track_layout.dart';
import 'package:flutter_smart_genome/widget/track/simple/range_feature_layout.dart';
import 'package:flutter_smart_genome/widget/track/vcf/vcf_feature_layout.dart';
import 'package:flutter_smart_genome/widget/track/vcf_sample/vcf_sample_feature_layout.dart';

abstract class TrackLayout {
  void clear();

  double maxHeight = 0;
  double? _charWidth;

  TextPainter? labelPainter;

  double measureTextWidth(String text, double fontSize) {
    if (_charWidth == null || _charWidth == 0) {
      labelPainter ??= TextPainter(textAlign: TextAlign.start, textDirection: TextDirection.ltr);
      labelPainter!.text = TextSpan(text: 'A', style: TextStyle(fontSize: fontSize, fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK));
      labelPainter!.layout();
      _charWidth = labelPainter!.width;
    }
    return text.length * _charWidth!;
  }
}

class BasicTrackLayout extends TrackLayout {
  @override
  void clear() {}
}

class TrackLayoutManager {
  static TrackLayoutManager _instance = TrackLayoutManager._init();

  Map<String, TrackLayout> _trackLayoutMap = {};

  factory TrackLayoutManager() {
    return _instance;
  }

  TrackLayout getTrackLayout(Track track) {
    var layout = _trackLayoutMap[track.key];
    if (null == layout) {
      layout = _createLayout(track);
      addTrackLayout(track.key, layout);
    }
    return layout;
  }

  TrackLayout getRelationLayout(Track track) {
    String key = 'relation-${track.key}';
    var layout = _trackLayoutMap[key];
    if (null == layout) {
      layout = _createRelation(track);
      addTrackLayout(key, layout);
    }
    return layout;
  }

  addTrackLayout(String key, TrackLayout trackLayout) {
    _trackLayoutMap[key] = trackLayout;
  }

  TrackLayout _createRelation(Track track) {
    return HicRelationLayout();
  }

  TrackLayout _createLayout(Track track) {
    if (track.isVcfSample) {
      return VcfSampleFeatureLayout();
    }
    if (track.isVcfCoverage) {
      return VcfFeatureLayout();
    }
    if (track.isGff) {
      // return BlockFeatureLayout();
      return RageFeatureLayout();
    }
    if (track.isBed) {
      // return BlockFeatureLayout();
      // return BedFeatureLayout();
      return FastBedFeatureLayout();
    }
    if (track.isBamReads) {
      return track.paired ? BamReadsPairedLayout() : BamReadsLayout();
    }
    if (track.isInteractive) {
      return RelationTrackLayout();
    }
    if (track.isHic) {
      return HicFeatureLayout();
    }
    if (track.isCellExp) {
      return CellExpFeatureLayout();
    }
    if (track.isPeak) {
      return PeakLayout();
    }
    if (track.isCoAccess) {
      return PeakPairLayout();
    }
    return BasicTrackLayout();
  }

  TrackLayoutManager._init() {}

  static clear([Track? track]) {
    if (null != track) {
      _instance.getTrackLayout(track).clear();
    } else {
      _instance._clear();
    }
  }

  _clear() {
    for (TrackLayout trackLayout in _trackLayoutMap.values) {
      trackLayout.clear();
    }
  }
}
