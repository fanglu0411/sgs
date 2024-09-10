import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';

class FeaturePainter extends AbstractTrackPainter<FeatureData, FeatureStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;

  FeaturePainter({
    required FeatureData trackData, // may be data in a range
    required FeatureStyleConfig styleConfig,
    required ScaleLinear<num> linearScale, // the scale by the hole chromosome
    required super.visibleRange,
  }) : super(
          trackData: trackData,
          styleConfig: styleConfig,
          scale: linearScale,
        ) {
    _paint = Paint()
      ..color = Colors.green[200]!
      ..strokeWidth = 1;

    _bgPaint = Paint();
    _blockPaint = Paint();
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
//    if (!trackData.hasFeature) {
//      canvas.drawRect(rect, _bgPaint);
//      return;
//    }

    if (styleConfig.backgroundColor != null) {
      canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor!);
    }

    drawText(canvas, text: 'Track', style: TextStyle(fontSize: 12, color: Colors.brown), offset: Offset(0, 2), width: size.width, textAlign: TextAlign.center);

    for (Feature feature in trackData.features!) {
      drawBlock(canvas, feature);
    }
  }

  void drawBlock(Canvas canvas, Feature feature) {
    Range range = feature.range;
    double left = styleConfig.padding.left;
    double right = left + styleConfig.featureWidth;
    Rect rect = Rect.fromLTRB(left, scale[range.start]!, right, scale[range.end]!);
    canvas.drawRect(rect, _blockPaint..color = styleConfig.blockBgColor);

    if (feature.subFeatures == null) return;
    feature.subFeatures!.forEach((subFeature) {
      drawSubFeature(canvas, subFeature);
    });
  }

  void drawSubFeature(Canvas canvas, Feature feature) {
    double left = styleConfig.padding.left;
    double right = left + styleConfig.featureWidth;
    if (feature.subFeatures != null) {
      feature.subFeatures!.forEach((element) {
        drawSubFeature(canvas, element);
      });
    } else {
      Range range = feature.range;
      Rect rect = Rect.fromLTRB(left, scale[range.start]!, right, scale[range.end]!);
      canvas.drawRect(rect, _paint..color = Colors.orange[500]!);
    }
  }
}
