import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/cell_expression/cell_exp_style_config.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'package:dartx/dartx.dart' as dx;

import 'cell_exp_feature_layout.dart';

class CellExpTrackPainter extends AbstractTrackPainter<FeatureData<CellExpFeature>, CellExpStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;

  late List categories;

  CellExpTrackPainter({
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
    double? featureHeight,
    required this.categories,
  }) : super(
    rowHeight: featureHeight,
  ) {
    featurePaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    _paint = Paint()
      ..color = Colors.green[200]!
      ..isAntiAlias = true
      ..strokeWidth = 1;

    _bgPaint = Paint()
      ..strokeWidth = 1.2
      ..isAntiAlias = true
      ..color = styleConfig.primaryColor!;

    _blockPaint = Paint()
      ..isAntiAlias = true
      ..color = styleConfig.primaryColor!.withOpacity(.1);

    _selectedPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = .8
      ..isAntiAlias = true
      ..color = styleConfig.primaryColor!.withOpacity(.2); //styleConfig.selectedColor;

    rowHeight = featureHeight;

    // trackData.filter(styleConfig.visibleFeatureTypes());
    trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(trackData.features!, styleConfig.showLabel, this.showSubFeature!, styleConfig.labelFontSize);
  }

  void calculateFeatureHeight(List<CellExpFeature> features, bool showLabel, bool showSubFeature, double labelFontSize) {
    CellExpFeatureLayout blockFeatureCalculator = TrackLayoutManager().getTrackLayout(track!) as CellExpFeatureLayout;
    blockFeatureCalculator.calculate(
      features: features,
      rowHeight: rowHeight!,
      rowSpace: rowSpace!,
      scale: scale,
      orientation: orientation!,
      collapseMode: collapseMode,
      showLabel: showLabel,
      labelFontSize: labelFontSize,
      visibleRange: visibleRange,
      padding: styleConfig.padding ?? EdgeInsets.zero,
      barWidth: styleConfig.barWidth,
    );
    maxHeight = max(maxHeight!, blockFeatureCalculator.maxHeight + (styleConfig.padding?.vertical ?? 0));
    }

  double calculateTextWidth(String text, [double? fontSize, bool? showSubFeature]) {
    if (!styleConfig.showLabel || !showSubFeature!) return double.infinity;
//    double _fontSize = fontSize ?? styleConfig.labelFontSize;
    return 0;
    //return (text ?? '').length * _fontSize * .8;
  }

  bool _showLabel(Feature feature, bool showLabel, bool showSubFeature) {
    // return false;
    return showLabel && showSubFeature;
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    // super.onEmptyPaint(canvas, size);
    return true;
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      //canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor);
      // drawRect(canvas, _bgPaint..color = styleConfig.backgroundColor, rect);
    }

    for (CellExpFeature feature in trackData.features!) {
      if (!inVisibleRange(feature)) continue;
      drawHorizontalFeature(canvas, feature);
    }

    checkSelectedItem(canvas);
  }

  checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;

    Feature feature = selectedItem;
//    logger.d(feature.toString());
//     drawRect(canvas, (feature.groupRect).inflate(inflateValue), _selectedPaint, Radius.circular(2));
  }

  ///
  /// draw horizontal feature
  ///
  void drawHorizontalFeature(Canvas canvas, CellExpFeature feature) {
    bool _selected = selectedItem != null && selectedItem is RangeFeature && (selectedItem as RangeFeature).uniqueId == feature.uniqueId;

    drawRect(canvas, feature.groupRect!, _selected ? _selectedPaint : _blockPaint, Radius.circular(2));

    canvas.drawLine(feature.rect!.bottomLeft + Offset(0, 1), feature.rect!.bottomRight + Offset(0, 1), _bgPaint);
    drawFeatureBar(canvas, feature);

    if (_showLabel(feature, styleConfig.showLabel, this.showSubFeature!)) {
      Offset offset = feature.rect!.bottomLeft.minLeft();
      if ((offset.dx == 0 && feature.labelWidth > feature.rect!.right) || //
          (feature.labelWidth <= feature.rect!.width && feature.labelWidth > feature.rect!.right - feature.rect!.left)) {
        offset = Offset(feature.rect!.right - feature.labelWidth, offset.dy);
      }
      drawText(
        canvas,
        text: '${feature.name}',
        offset: offset, //Offset(feature.rect.left, feature.rect.bottom),
        width: 400.0, //featureRect.width,
        style: TextStyle(
          fontFamily: MONOSPACED_FONT,
          fontSize: styleConfig.labelFontSize,
          fontWeight: FontWeight.w400,
          color: styleConfig.labelColor,
        ),
      );
    }
  }

  void drawFeatureBar(Canvas canvas, CellExpFeature feature) {
    var featureRect = feature.rect;
    List values = feature.values!;
    // print('values: ${values}, categories: ${categories}');
    double barWidth = styleConfig.barWidth; //featureRect.width / values.length;
    var max = values.max();
    if (max == 0) max = 1;

    double valueScale = rowHeight! / max;
    double valueHeight;
    String category;
    for (int i = 0; i < categories.length; i++) {
      if (i >= values.length) break;
      valueHeight = valueScale * values[i];
      category = categories[i];
      var barRect = Rect.fromLTWH(
        featureRect!.left + i * barWidth,
        featureRect.bottom - valueHeight,
        barWidth,
        valueHeight,
      );
      featurePaint.color = styleConfig.colorMap[category]!;
      drawRect(canvas, barRect, featurePaint, Radius.circular(1));
    }
  }

  @override
  findHitItem(Offset position) {
    RangeFeature? blockFeature = trackData.features?.firstOrNullWhere((feature) => (feature.groupRect ?? feature.rect)!.contains(position));
    var item = _findChildHitItem(blockFeature, position);
    //print('find item ${track.trackName} $item');
    hitItem = item;
    return item;
  }

  Feature? _findChildHitItem(Feature? feature, Offset position) {
    if (feature == null) return null;

    Feature _find = feature;
    if (feature.hasChildren && collapseMode == TrackCollapseMode.expand) {
      _find = feature.children!.firstOrNullWhere((element) => (element.rect)!.contains(position)) ?? feature;
    }

//    if (_find.hasSubFeature) {
//      List<Feature> items = _find.subFeatures.where((subFeature) => subFeature.rect?.contains(position)).toList();
//      if (items.length == 0) return _find;
//      var item = findMinRangeFeature(items);
//      return _findChildHitItem(item, position);
//    }
    return _find;
  }

  Path rectToStrandPath(Rect rect, int strand) {
    double arrowWidth = rect.width > 5 ? 5 : 1;
    if (strand == 1) {
      return Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right - arrowWidth, rect.top)..lineTo(rect.right, rect.centerRight.dy)..lineTo(rect.right - arrowWidth, rect.bottom)..lineTo(rect.left, rect.bottom)
        ..close();
    }
    return Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)..lineTo(rect.left + arrowWidth, rect.bottom)..lineTo(rect.left, rect.centerLeft.dy)..lineTo(rect.left + arrowWidth, rect.top)
      ..close();
  }

  Feature? findMinRangeFeature(List<GffFeature> features) {
    if (features.length > 0) return features.reduce((value, element) => value.range.size < element.range.size ? value : element);
    return null;
  }

  Feature _minRangeFeature(Feature f1, Feature f2) {
    return f1.range.size < f2.range.size ? f1 : f2;
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