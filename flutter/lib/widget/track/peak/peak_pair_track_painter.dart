import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'dart:math' show max, pi;
import 'package:dartx/dartx.dart' as dx;
import 'peak_pair_layout.dart';
import 'peak_pair_track_data.dart';

class PeakPairTrackPainter extends AbstractTrackPainter<PeakPairTrackData, FeatureStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;
  late String labelKey;
  late bool drawDown;

  PeakPairTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    required super.track,
    super.orientation,
    super.showSubFeature,
    super.collapseMode,
    super.selectedItem,
    super.scaling,
    double? trackHeight,
    this.labelKey = 'name',
    this.drawDown = true,
  }) : super(
          rowHeight: trackHeight,
        ) {
    featurePaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    _paint = Paint()
      ..color = Colors.green[200]!
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 1.2;

    _bgPaint = Paint();
    _blockPaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    _selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5
      ..isAntiAlias = true
      ..color = styleConfig.selectedColor;

    rowSpace = 0;

//    trackData.filter(styleConfig.visibleFeatureTypes());
    trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(
      trackData.features,
      false, //styleConfig.showLabel && showSubFeature,
      styleConfig.labelFontSize,
      labelKey,
    );
  }

  void calculateFeatureHeight(List<PeakPair> features, bool showLabel, double labelFontSize, String labelKey) {
    PeakPairLayout featureLayout = TrackLayoutManager().getTrackLayout(track!) as PeakPairLayout;
    featureLayout.calculate(
      peakPairs: features,
      rowHeight: rowHeight!,
      rowSpace: rowSpace!,
      scale: scale,
      orientation: orientation!,
      collapseMode: collapseMode,
      showLabel: showLabel,
      labelFontSize: labelFontSize,
      visibleRange: visibleRange,
      padding: styleConfig.padding,
      coAccessibility: true,
      drawDown: drawDown,
    );
    if ((featureLayout.maxHeight ?? 0) > 0) {
      maxHeight = max(maxHeight!, featureLayout.maxHeight + styleConfig.padding.vertical);
    } else {
      maxHeight = track!.defaultTrackHeight;
    }
  }

  bool _showLabel(Feature feature, bool showLabel, bool showSubFeature) {
    return false;
    return showLabel && showSubFeature;
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      //canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor);
      // drawRect(canvas, _bgPaint..color = styleConfig.backgroundColor, rect);
    }

    for (PeakPair feature in trackData.features) {
      // if (feature.rect == null || !inVisibleRange(feature)) continue;
      if (feature == selectedItem) continue;
      drawHorizontalFeature(canvas, feature, feature.rect!);
      // print(feature);
    }

    checkSelectedItem(canvas);

    // canvas.drawPath(_gapPath, _paint..color = styleConfig.blockBgColor);
    // canvas.drawPath(_rectPath, featurePaint..color = Colors.red);
  }

  checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;

    if (selectedItem is PeakPair) {
      PeakPair pair = selectedItem;
      canvas.drawPath(pair.linkPath!, _selectedPaint);

      TextStyle _textStyle = TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK);
      Rect _bounds = pair.linkPath!.getBounds();
      _bounds = _bounds.intersect(painterRect);

      var tooltip = 'peak1: ${pair.peak1}\npeak2: ${pair.peak2}\nvalue: ${pair.value}';
      drawTooltip(canvas, tooltip, _bounds.center, _bgPaint);
    }
  }

  ///
  /// draw horizontal feature
  ///
  void drawHorizontalFeature(Canvas canvas, PeakPair feature, Rect featureRect) {
    //draw self sub features
    //drawHorizontalSingleSubFeature(canvas, feature, featureRect);

    // drawHorizontalSingleSubFeature(canvas, feature, featureRect, true);

    //paired reads
    if (feature.linkPath != null) {
      // draw co relation score
      var color = styleConfig.lineColor!.withOpacity(feature.value / trackData.max);
      canvas.drawPath(feature.linkPath!, _paint..color = color);
    }
  }

  void drawHorizontalSingleSubFeature(Canvas canvas, Feature feature, Rect parentRect, [bool subFeature = false]) {
    Rect? fRect = feature.rect; //Rect.fromLTRB(scale[range.start], parentRect.top, scale[range.end], parentRect.bottom);
    if (fRect == null || fRect.right < 0 || fRect.left > size.width) return;
    fRect = fRect.intersectHorizontal(rect);
    var strand = feature.strandStr ?? '.';
    FeatureStyle featureStyle = styleConfig['peak'];
//

    Radius? _radius = featureStyle.radius > 0 ? Radius.circular(featureStyle.radius) : null;
    if (featureStyle.hasBorder) {
      featurePaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = featureStyle.borderWidth
        ..color = featureStyle.borderColor!;
      drawRect(canvas, fRect, featurePaint, _radius);
    }

    featurePaint
      ..style = PaintingStyle.fill
      ..color = featureStyle.color ?? styleConfig.blockBgColor;

    drawRect(canvas, fRect, featurePaint, _radius);
  }

  @override
  findHitItem(Offset position) {
    Iterable<PeakPair> features = trackData.features.where((f) {
      return (f.linkPath?.contains(position) ?? false);
    });

    if (features.length == 0) {
      hitItem = null;
    } else {
      PeakPair? blockFeature = features.minBy((f) {
        var intersection = Path.combine(
            PathOperation.intersect,
            f.linkPath!,
            Path()
              ..addRect(
                Rect.fromCenter(
                  center: Offset(position.dx, painterRect.center.dy),
                  width: 2,
                  height: painterRect.height,
                ),
              ));
        // if (intersection.computeMetrics().any((PathMetric metric) => metric.length > 0)) {
        //
        // }
        return intersection.getBounds().height;
        return f.linkPath!.getBounds().height;
      });
      hitItem = blockFeature;
    }
    return hitItem;
  }

  @override
  bool hitTest(Offset position) {
    var item = findHitItem(position);
    if (item != null) return true;
    return super.hitTest(position);
  }

  @override
  bool painterChanged(AbstractTrackPainter painter) {
    return super.painterChanged(painter);
  }
}