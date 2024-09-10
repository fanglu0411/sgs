import 'package:flutter/material.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'dart:math' show max, sin, pi, min, Random, atan;
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/hic/hic_track_widget.dart';

import 'hic_data.dart';

class HicFeatureLayout extends TrackLayout {
  Map<String, int> _featureRowMap = {};

  double measureTextWidth(String text, double fontSize) {
    labelPainter!.text = TextSpan(text: text, style: TextStyle(fontSize: fontSize));
    labelPainter!.layout();
    return labelPainter!.width;
  }

  HicFeatureLayout() {
    labelPainter = TextPainter(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
    );
  }

  clear() {
    int length = _featureRowMap.length;
    _featureRowMap.clear();
    maxHeight = 0;
    print('clear => $length');
  }

  void calculate({
    required HicData trackData,
    required double rowHeight,
    required double rowSpace,
    required Scale<num, num> scale,
    required Axis orientation,
    required TrackCollapseMode collapseMode,
    required bool showLabel,
    required double labelFontSize,
    required Range visibleRange,
    required double pixelsOfSeq,
    required double binSize,
    EdgeInsets padding = EdgeInsets.zero,
    required HicDisplayMode displayMode,
    bool scaling = false,
  }) {
    if (trackData.isEmpty) return;

    Path blockPath;
    Range pixRange1;
    Range pixRange2;

    double maxTop = 0;
    // double _c = blockWidth;
    // double _squareSide = _c * sin(45 * (pi / 180));
    double blockWidth = binSize * pixelsOfSeq;

    double maxValue = trackData.bins.maxBy((b) => b.value!)!.value as double;

    double _safeRowHeight = rowHeight > 0 ? rowHeight : 200;
    double heightScale = (_safeRowHeight - padding.top - 20) / maxValue;

    double tanX = _safeRowHeight / (scale.call(visibleRange.size)! / 2);
    double angle = atan(tanX);
    double halfBlockHeight = blockWidth / 2; // tanX * blockWidth / 2;

    Offset top;
    for (HicBin bin in trackData.bins) {
      pixRange1 = Range.fromSize(start: scale[bin.range1.start]!, width: blockWidth);
      pixRange2 = Range.fromSize(start: scale[bin.range2.start]!, width: blockWidth);

      double halfDistance = (pixRange2.end - pixRange1.start) / 2;
      double crossHeight = halfDistance; // tanX * halfDistance;

      top = Offset(pixRange1.start + crossHeight, crossHeight - blockWidth).translate(0, padding.top);
      maxTop = max(top.dy, maxTop);
      blockPath = Path();

      //rect four point
      List<Offset> points = [
        Offset(top.dx - blockWidth / 2, top.dy + halfBlockHeight), //left
        Offset(top.dx, top.dy + halfBlockHeight * 2), //bottom
        Offset(top.dx + blockWidth / 2, top.dy + halfBlockHeight), //right
        Offset(top.dx, top.dy), // top
      ];

      blockPath
            ..moveTo(points[0].dx, points[0].dy) //left
            ..lineTo(points[1].dx, points[1].dy) //bottom
            ..lineTo(points[2].dx, points[2].dy) //right
          ;
      if (bin.index1 != bin.index2) {
        blockPath..lineTo(points[3].dx, points[3].dy); //top
      }
      blockPath.close();

      // double arcRectWidth = (top.dy + blockWidth / 2 - padding.top) * 2;

      Rect arcRect = bin.index1 == bin.index2
          ? Rect.fromCenter(
              center: Offset(top.dx, padding.top),
              width: blockWidth,
              height: displayMode == HicDisplayMode.arc ? bin.value! * heightScale * 2 : blockWidth * 2,
            )
          : Rect.fromCenter(
              center: Offset(top.dx, padding.top),
              width: crossHeight * 2 - blockWidth,
              height: displayMode == HicDisplayMode.arc ? bin.value! * heightScale * 2 : (top.dy - padding.top) * 2,
            );

      Path arcPath = Path()..arcTo(arcRect, 0, pi, false);

      bin
        ..path = blockPath
        ..points = points
        ..arcPath = arcPath
        // ..pixRange1 = pixRange1
        // ..pixRange2 = pixRange2
        // ..arcRect = Rect.fromLTWH(pixRange1.center, padding.top - arcRectWidth / 2, arcRectWidth, arcRectWidth)
        // ..center = Offset(top.dx, top.dy + blockWidth / 2)
        ..visible = trackData.valueFilterFunction?.call(bin) ?? true;
    }
    if (!scaling) {
      var _maxHeight = displayMode == HicDisplayMode.heatmap ? maxTop + blockWidth : _safeRowHeight;
      // var _maxHeight = rowHeight;
      maxHeight = max(_maxHeight, maxHeight);
    }
    // maxHeight = 0;
  }
}
