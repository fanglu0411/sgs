import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/service/beans.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'dart:math' show max, pi;
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/peak/peak_layout.dart';
import 'package:flutter_smart_genome/widget/track/peak/peak_track_data.dart';

class PeakTrackPainter extends AbstractTrackPainter<PeakTrackData, FeatureStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;
  late String labelKey;
  late bool paired;

  PeakTrackPainter({
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
    this.paired = true,
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
      ..strokeWidth = 2;

    _bgPaint = Paint();
    _blockPaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    _selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .8
      ..isAntiAlias = true
      ..color = styleConfig.selectedColor;

    maxHeight = 10;
    rowSpace = styleConfig.labelFontSize + 4;

//    trackData.filter(styleConfig.visibleFeatureTypes());
    trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(
      trackData.features,
      false, //styleConfig.showLabel && showSubFeature,
      styleConfig.labelFontSize,
      labelKey,
    );
  }

  void calculateFeatureHeight(List<Peak> features, bool showLabel, double labelFontSize, String labelKey) {
    PeakLayout featureLayout = TrackLayoutManager().getTrackLayout(track!
      ..paired = paired) as PeakLayout;
    featureLayout.calculate(
      features: features,
      rowHeight: rowHeight!,
      rowSpace: rowSpace!,
      scale: scale,
      orientation: orientation!,
      collapseMode: collapseMode,
      showLabel: showLabel,
      labelFontSize: labelFontSize,
      visibleRange: visibleRange,
      padding: styleConfig.padding,
      coHeight: 100,
      coAccessibility: paired,
    );
    if ((featureLayout.maxHeight ?? 0) > 0) {
      maxHeight = max(maxHeight!, featureLayout.maxHeight);
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

    for (Peak feature in trackData.features) {
      // if (feature.rect == null || !inVisibleRange(feature)) continue;
      drawHorizontalFeature(canvas, feature, feature.rect!);
    }

    checkSelectedItem(canvas);

    // canvas.drawPath(_gapPath, _paint..color = styleConfig.blockBgColor);
    // canvas.drawPath(_rectPath, featurePaint..color = Colors.red);
  }

  checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;

    if (paired && selectedItem is PeakPair) {
      PeakPair pair = selectedItem;
      canvas.drawPath(pair.linkPath!, _selectedPaint);
    } else {
      Feature feature = selectedItem;
      drawRect(
        canvas,
        (feature.rect)!.inflate(inflateValue),
        _selectedPaint,
        Radius.circular(2),
      );
      drawTooltip(
        canvas,
        'ID   : ${feature.featureId}\nrange: ${feature.range.print()}',
        Offset(feature.rect!.right + 6, 6),
        _selectedPaint,
      );
    }
  }

  ///
  /// draw horizontal feature
  ///
  void drawHorizontalFeature(Canvas canvas, Peak feature, Rect featureRect) {
    //draw self sub features
    //drawHorizontalSingleSubFeature(canvas, feature, featureRect);

    drawHorizontalSingleSubFeature(canvas, feature, featureRect, true);

    if (_showLabel(feature, styleConfig.showLabel, this.showSubFeature!)) {
      Offset offset = featureRect.bottomLeft.minLeft();
      if (offset.dx == 0 && feature.labelWidth > feature.rect!.right) offset = Offset(feature.rect!.right - feature.labelWidth, offset.dy);
      var style = TextStyle(
        fontSize: styleConfig.labelFontSize,
        fontWeight: FontWeight.w400,
        color: styleConfig.textColor,
      );
      TextSpan nameSpan = TextSpan(text: feature.name, style: style);
      drawTextSpan(
        canvas,
        text: nameSpan,
        offset: offset, //Offset(feature.rect.left, feature.rect.bottom),
        width: feature.labelWidth, //featureRect.width,
      );
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
    Peak? blockFeature = trackData.features.firstOrNullWhere((feature) {
      return (feature.rect)!.contains(position) || (feature.rect?.contains(position) ?? false);
    });

    var item = _findChildHitItem(blockFeature, position);
    //print('find item ${track.trackName} $item');
    hitItem = item;
    return item;
  }

  Feature? _findChildHitItem(Peak? feature, Offset position) {
    if (feature == null) return null;
    if (feature.rect!.contains(position)) {
      return feature;
    }
    return null;
  }

  Feature? findMinRangeFeature(List<GffFeature> features) {
    if (features.length > 0) return features.reduce((value, element) => value.range.size < element.range.size ? value : element);
    return null;
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