import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/fast_bed_feature_layout.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'dart:math' show max, pi;

class BedTrackPainter extends AbstractTrackPainter<FeatureData<BedFeature>, FeatureStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;

  bool? _showLabel;
  double? offset;
  double? viewHeight;

  BedTrackPainter({
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
    double? featureHeight,
    this.viewHeight,
    this.offset,
  }) : super(
          rowHeight: featureHeight,
        ) {
    featurePaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    _paint = Paint()
      ..color = Colors.green[200]!
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..strokeWidth = 1;

    _bgPaint = Paint();
    _blockPaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    _selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .5
      ..isAntiAlias = true
      ..color = styleConfig.selectedColor;

    rowSpace = styleConfig.labelFontSize + 4;
    _showLabel = styleConfig.showLabel && showSubFeature!;
    trackData.filterAndPrepare(visibleRange.inflate(visibleRange.size * 2));
    calculateFeatureHeight(trackData.features!);
  }

  bool layouted = false;

  void calculateFeatureHeight(List<Feature> features) {
    FastBedFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(track!) as FastBedFeatureLayout;
    featureLayout.calculate(
      features: features,
      rowHeight: rowHeight!,
      rowSpace: rowSpace!,
      scale: scale,
      orientation: orientation!,
      collapseMode: collapseMode,
      showLabel: _showLabel!,
      showSubFeature: showSubFeature!,
      labelFontSize: styleConfig.labelFontSize,
      visibleRange: visibleRange,
      padding: styleConfig.padding,
    );
    if ((featureLayout.maxHeight) > 0) {
      maxHeight = max(maxHeight!, featureLayout.maxHeight + styleConfig.padding.vertical);
    } else {
      maxHeight = track!.defaultTrackHeight;
    }
    layouted = true;
  }

  bool needShowSubFeature(Rect rect, [double width = 0.0]) {
    return showSubFeature! || (rect.width > 20);
  }

  static const List orderedFeatureTypes = [
    'basic',
    'thick',
    'block',
    BedFeature.ENHANCE_BLOCK_TYPE,
  ];

  int featureSortFunction(Feature a, Feature b) {
    return orderedFeatureTypes.indexOf(a.type.toLowerCase()) - orderedFeatureTypes.indexOf(b.type.toLowerCase());
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      //canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor);
      // drawRect(canvas, _bgPaint..color = styleConfig.backgroundColor, rect);
    }

    // _paint..blendMode = BlendMode.srcOver;
    for (BedFeature feature in trackData.features!) {
      if (!inVisibleRange(feature)) continue;
      drawFeature(canvas, feature, feature.rect!);
    }
    checkSelectedItem(canvas);
  }

  void checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;

    Feature feature = selectedItem;
    // logger.d('selected item ${feature.featureId}');
    drawRect(
      canvas,
      (feature.rect)!.inflate(inflateValue),
      _selectedPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = .4,
      Radius.circular(1),
    );
    Rect _rect = (feature.groupRect ?? feature.rect!);
    if ((!showSubFeature!)) {
      var offset = _rect.bottomLeft.minLeft() + Offset(0, 10);
      drawTooltip(canvas, '${feature.name}', offset, _selectedPaint);
    }
  }

  ///
  /// draw horizontal feature
  ///
  void drawFeature(Canvas canvas, BedFeature feature, Rect featureRect) {
    bool _selected = selectedItem != null && selectedItem is BedFeature && (selectedItem as BedFeature).uniqueId == feature.uniqueId;
    bool _showSubFeature = needShowSubFeature(featureRect);
    drawHorizontalBlock(canvas, feature, feature.rect!, true, _showSubFeature);
  }

  void drawHorizontalBlock(Canvas canvas, BedFeature feature, Rect featureRect, [bool drawBackground = false, showSubFeature = false]) {
    //draw self and sub features
    // drawHorizontalSubFeature(canvas, feature, featureRect);

    if (!showSubFeature) {
      drawMinSubFeature(canvas, feature, featureRect, drawStrand: true);
      // _drawStrand(canvas, feature);
      return;
    }

    // _bgPaint
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.2
    //   ..color = styleConfig.lineColor;
    // canvas.drawPath(
    //     Path()
    //       ..moveTo(feature.rect.centerLeft.dx, feature.rect.centerLeft.dy)
    //       ..lineTo(feature.rect.centerRight.dx, feature.rect.centerRight.dy),
    //     _bgPaint);

    if (feature.hasSubFeature) {
      FeatureStyle lineStyle = feature.subFeatures!.length == 1 ? styleConfig['base'] : (styleConfig.getFeatureStyle('line') ?? styleConfig['base']);
      bool singleSubFeature = feature.subFeatures!.where((f) => f['view_type'] != 'thick').length == 1;
      if (singleSubFeature) {
        drawMinSubFeature(canvas, feature, featureRect, drawStrand: true);
      } else {
        _bgPaint
          ..color = lineStyle.color!
          ..strokeWidth = (lineStyle.height * featureRect.height);
        canvas.drawLine(featureRect.centerLeft, featureRect.centerRight, _bgPaint);
      }

      feature.subFeatures!.sort(featureSortFunction);
      drawRowSubFeatures(canvas, feature, painterRect);
      _drawStrand(canvas, feature, color: singleSubFeature ? Colors.white : null);
    } else {
      drawMinSubFeature(canvas, feature, featureRect, drawStrand: true);
      _drawStrand(canvas, feature, color: Colors.white);
    }

    if (_showLabel!) {
      Offset offset = featureRect.bottomLeft.minLeft();
      if (offset.dx == 0 && feature.labelWidth > feature.rect!.right) offset = Offset(feature.rect!.right - feature.labelWidth, offset.dy);
      var style = TextStyle(
        fontFamily: MONOSPACED_FONT,
        fontFamilyFallback: MONOSPACED_FONT_BACK,
        fontSize: styleConfig.labelFontSize,
        fontWeight: FontWeight.w400,
        color: styleConfig.textColor,
      );
      drawText(canvas, text: feature.name, offset: offset, style: style);
    }
  }

  void drawRowSubFeatures(Canvas canvas, BedFeature feature, Rect parentRect) {
    if (!inVisibleRange(feature)) return;
    int len = feature.subFeatures!.length;
    if (len > 0) {
      feature.subFeatures!.sort(featureSortFunction);
      for (int i = 0; i < len; i++) {
        drawRowSubFeatures(canvas, feature.subFeatures![i] as BedFeature, feature.rect!);
        //drawHorizontalSingleSubFeature(canvas, element, featureRect);
      }
    } else {
      drawMinSubFeature(canvas, feature, parentRect, drawStrand: true);
    }
  }

  void drawMinSubFeature(Canvas canvas, BedFeature feature, Rect parentRect, {bool drawStrand = false}) {
    //Range range = feature.range;
    Rect fRect = feature.rect!; //Rect.fromLTRB(scale[range.start], parentRect.top, scale[range.end], parentRect.bottom);
    if (fRect.right < 0 || fRect.left > size.width) return;
    bool isEnhanceBlock = feature.viewType == BedFeature.ENHANCE_BLOCK_TYPE;

    FeatureStyle featureStyle = styleConfig.getFeatureStyle(isEnhanceBlock ? 'block' : feature.viewType.toLowerCase()) ?? styleConfig['base'];
    if (!featureStyle.visible) return;

    if (featureStyle.height < 1) {
      var dy = isEnhanceBlock ? 1 - featureStyle.height - .2 : 1 - featureStyle.height;
      fRect = fRect.deflateXY(0, dy * fRect.height / 2);
    }
    if (fRect.width < 1.5) fRect = fRect.inflateXY(.5, 0);

    Radius? _radius = featureStyle.radius > 0 ? Radius.circular(featureStyle.radius) : null;
    if (featureStyle.borderWidth > 0 && featureStyle.borderColor != Colors.transparent) {
      featurePaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = featureStyle.borderWidth
        ..color = featureStyle.borderColor!;
      if (drawStrand && feature.strand != 0) {
        Path path = rectToStrandPath(fRect, feature.strand);
        canvas.drawPath(path, featurePaint);
      } else {
        drawRect(canvas, fRect, featurePaint, _radius);
      }
    }

    var fillColor = feature.color ?? featureStyle.colorWithAlpha;
    if (fillColor == Colors.transparent) return;
    featurePaint
      ..style = PaintingStyle.fill
      ..color = fillColor;
    if (drawStrand && feature.strand != 0 && fRect.width > 5) {
      Path path = rectToStrandPath(fRect, feature.strand);
      canvas.drawPath(path, featurePaint);
    } else {
      drawRect(canvas, fRect, featurePaint);
    }
  }

  Path rectToStrandPath(Rect rect, int strand) {
    double arrowWidth = rect.width > 5 ? 5 : 1;
    if (strand == 1) {
      return Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right - arrowWidth, rect.top)
        ..lineTo(rect.right, rect.centerRight.dy)
        ..lineTo(rect.right - arrowWidth, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..close();
    }
    return Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left + arrowWidth, rect.bottom)
      ..lineTo(rect.left, rect.centerLeft.dy)
      ..lineTo(rect.left + arrowWidth, rect.top)
      ..close();
  }

  void _drawStrand(Canvas canvas, Feature feature, {Color? color}) {
    if (!feature.hasStrand) return;
    double arrowHeight = feature.rect!.height / 4;
    double arrowDirection = (feature.strand > 0 ? arrowHeight : -arrowHeight);
    Path arrowPath = Path();
    // if (feature.hasSubFeature) {
    var step = rect.width ~/ 4;
    if (feature.rect!.width > step) {
      var _left = feature.rect!.left + step;
      while (_left + arrowDirection < feature.rect!.right) {
        if (_left < rect.right && _left >= 0)
          arrowPath
            ..moveTo(_left, feature.rect!.center.dy - arrowHeight)
            ..lineTo(_left + arrowDirection, feature.rect!.center.dy)
            ..lineTo(_left, feature.rect!.center.dy + arrowHeight);
        _left += step;
      }
    } else if (feature.rect!.width > 10) {
      arrowPath
        ..moveTo(feature.rect!.center.dx, feature.rect!.center.dy - arrowHeight)
        ..lineTo(feature.rect!.center.dx + arrowDirection, feature.rect!.center.dy)
        ..lineTo(feature.rect!.center.dx, feature.rect!.center.dy + arrowHeight);
    }
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = rowHeight! > 15 ? 2 : 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color ?? styleConfig.lineColor!.withAlpha(feature.hasSubFeature ? 150 : 150);
    // ..color = Colors.white70;
    canvas.drawPath(arrowPath, _paint);
    // }
  }

  @override
  findHitItem(Offset position) {
    // var y = position.dy + offset;
    // Offset _of = Offset(position.dx, y);
    // int row = (y - styleConfig.padding.top) ~/ (rowSpace + rowHeight);
    // FastBedFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(track);
    // var f = featureLayout.rowFeatures[row].features.firstWhere((f) => (f.groupRect ?? f.rect).contains(_of), orElse: () => null);

    RangeFeature? f = trackData.features?.firstOrNullWhere((feature) => (feature.groupRect ?? feature.rect)!.contains(position));
    // var item = _findChildHitItem(f, position);
    // print('find item ${track.trackName} ${f}');
    hitItem = f;
    return f;
  }

  Feature? _findChildHitItem(Feature? feature, Offset position) {
    if (feature == null) return null;

    Feature? _find = feature;
    if (feature.hasChildren && collapseMode == TrackCollapseMode.expand) {
      _find = feature.children!.firstOrNullWhere((f) => (f.rect)!.contains(position)) ?? feature;
    }

//    if (_find.hasSubFeature) {
//      List<Feature> items = _find.subFeatures.where((subFeature) => subFeature.rect?.contains(position)).toList();
//      if (items.length == 0) return _find;
//      var item = findMinRangeFeature(items);
//      return _findChildHitItem(item, position);
//    }
    return _find;
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
