import 'dart:math' show max;

import 'package:flutter/material.dart';

import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/cross_overlay/cross_overlay_logic.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'dart:math' show pi;
import 'package:dartx/dartx.dart' as dx;

import 'package:flutter_smart_genome/widget/track/simple/range_feature_layout.dart';

class RangeTrackPainter extends AbstractTrackPainter<FeatureData<GffFeature>, FeatureStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;

  late bool _showLabel;
  late bool _showChildrenLabel;

  RangeTrackPainter({
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
  }) : super(rowHeight: trackHeight) {
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

    _showLabel = styleConfig.showLabel && this.showSubFeature!;
    _showChildrenLabel = styleConfig.showLabel && styleConfig.showChildrenLabel && this.showSubFeature!;
    trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(trackData.features!);
  }

  void calculateFeatureHeight(List<GffFeature> features) {
    // BlockFeatureLayout blockFeatureCalculator = TrackLayoutManager().getTrackLayout(track);
    RageFeatureLayout blockFeatureCalculator = TrackLayoutManager().getTrackLayout(track!) as RageFeatureLayout;
    blockFeatureCalculator.calculate(
      features: features,
      rowHeight: rowHeight!,
      rowSpace: showSubFeature! ? rowSpace! : 5,
      scale: scale,
      orientation: orientation!,
      collapseMode: collapseMode,
      showLabel: _showLabel,
      showChildrenLabel: _showChildrenLabel,
      labelFontSize: styleConfig.labelFontSize,
      visibleRange: visibleRange,
      showSubFeature: showSubFeature!,
      padding: styleConfig.padding ?? EdgeInsets.zero,
    );
    maxHeight = max(maxHeight!, blockFeatureCalculator.maxHeight + (styleConfig.padding.vertical ?? 0));
  }

//  List<FeatureRect> featureRects = [];

  double calculateTextWidth(String text, [double? fontSize, bool? showSubFeature]) {
    if (!styleConfig.showLabel || !showSubFeature!) return double.infinity;
//    double _fontSize = fontSize ?? styleConfig.labelFontSize;
    return 0;
    //return (text ?? '').length * _fontSize * .8;
  }

  bool needShowSubFeature(Rect rect, [double width = 0.0]) {
    return showSubFeature! || (rect.width > 40);
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    //super.onEmptyPaint(canvas, size);
    return true;
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      //canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor);
      // drawRect(canvas, _bgPaint..color = styleConfig.backgroundColor, rect);
    }
    featureCache.clear();

    GffFeature? targetFeature;

    for (GffFeature feature in trackData.features!) {
      if (!inVisibleRange(feature)) continue;
      drawFeature(canvas, feature);
      if (targetFeature == null && (CrossOverlayLogic.safe()?.checkFeature(feature, track!) ?? false)) {
        targetFeature = feature;
      }
    }

    // _paint
    //   ..style = PaintingStyle.fill
    //   ..color = styleConfig.groupColor;
    // canvas.drawPath(featureCache['group-background'], _paint);

    // for (MapEntry entry in featureCache.entries) {
    //   FeatureStyle? featureStyle = styleConfig[entry.key];
    //   if (entry.key == 'group-background') continue;
    //   var fillColor = featureStyle.colorWithAlpha;
    //   featurePaint
    //     ..style = PaintingStyle.fill
    //     ..strokeWidth = 2
    //     ..color = fillColor;
    //   canvas.drawPath(entry.value, featurePaint);
    // }

    if (targetFeature != null) {
      drawTarget(canvas, targetFeature);
    }

    checkSelectedItem(canvas);
  }

  void drawTarget(Canvas canvas, RangeFeature feature) {
    Rect _rect = (feature.groupRect ?? feature.rect)!.inflateXY(10, 8);
    _paint
      ..color = Colors.orange.withOpacity(.10)
      ..style = PaintingStyle.fill;
    drawRect(canvas, _rect, _paint, Radius.circular(15));
    double borderRadius = 15;
    double borderRectSize = 30;
    Path path = Path()
          ..moveTo(_rect.bottomLeft.dx + _rect.width / 4, _rect.bottom) //bottom left
          ..lineTo(_rect.bottomLeft.dx + borderRadius, _rect.bottom)
          ..arcTo(Rect.fromCenter(center: _rect.bottomLeft + Offset(borderRadius, -borderRadius), width: borderRectSize, height: borderRectSize), pi / 2, pi / 2, true)
          ..lineTo(_rect.left, _rect.bottom - _rect.height / 4)
          ..moveTo(_rect.left, _rect.centerLeft.dy - _rect.height / 4) //top left
          ..lineTo(_rect.left, _rect.topLeft.dy + borderRadius)
          ..arcTo(Rect.fromCenter(center: _rect.topLeft + Offset(borderRadius, borderRadius), width: borderRectSize, height: borderRectSize), pi, pi / 2, true)
          ..lineTo(_rect.topLeft.dx + _rect.width / 4, _rect.top)
          ..moveTo(_rect.right - _rect.width / 4, _rect.top) //top right
          ..lineTo(_rect.right - borderRadius, _rect.top)
          ..arcTo(Rect.fromCenter(center: _rect.topRight + Offset(-borderRadius, borderRadius), width: borderRectSize, height: borderRectSize), pi * 1.5, pi / 2, true)
          ..lineTo(_rect.right, _rect.top + _rect.height / 4)
          ..moveTo(_rect.right, _rect.bottom - _rect.height / 4)
          ..lineTo(_rect.right, _rect.bottom - borderRadius)
          ..arcTo(Rect.fromCenter(center: _rect.bottomRight - Offset(borderRadius, borderRadius), width: borderRectSize, height: borderRectSize), 0, pi / 2, true)
          ..lineTo(_rect.bottomRight.dx - _rect.width / 4, _rect.bottom)
        //
        ;
    _paint
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, _paint);
  }

  checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;

    Feature feature = selectedItem;
    Rect _rect = (feature.groupRect ?? feature.rect!);
//    logger.d(feature.toString());
//     _selectedPaint..color = styleConfig.groupColor.withAlpha(240);
//     if (!feature.hasChildren) drawRect(canvas, _rect.inflate(inflateValue), _selectedPaint, Radius.circular(1));
    if (!showSubFeature! || (!_showChildrenLabel && !feature.hasChildren)) {
      var offset = _rect.bottomLeft.minLeft() + Offset(0, 10);
      drawTooltip(canvas, '${feature.featureId}', offset, _selectedPaint);
    }
  }

  //select feature or it's children
  bool _isSelected(RangeFeature feature) {
    if (selectedItem == null) return false;
    if (!(selectedItem is RangeFeature)) return false;
    var id = (selectedItem as RangeFeature).uniqueId;
    return id == feature.uniqueId || (feature.hasChildren && feature.children!.any((e) => e.uniqueId == id));
  }

  Map<String, Path> featureCache = {};

  ///
  /// draw horizontal feature
  ///
  void drawFeature(Canvas canvas, RangeFeature feature) {
    bool _selected = _isSelected(feature);
    bool _showSubFeature = needShowSubFeature(feature.rect!);

    if ((feature.hasChildren || _selected) && collapseMode == TrackCollapseMode.expand) {
      //draw group background
      _paint
        ..style = PaintingStyle.fill
        ..color = _selected ? styleConfig.groupColor!.withAlpha(240) : styleConfig.groupColor!;
      drawRect(canvas, (feature.groupRect ?? feature.rect)!.inflate(inflateValue), _paint, Radius.circular(2));

      // featureCache['group-background'] ??= Path();
      // featureCache['group-background'].addRRect(RRect.fromRectAndRadius((feature.groupRect ?? feature.rect).inflate(inflateValue), Radius.circular(2)));

      //drawRect(canvas, _paint..color = Colors.green.withAlpha(200), featureRect);
    }

    var children = feature.flatChildren;
    int i = 0;
    for (Feature f in children) {
      drawRowFeature(canvas, f, feature.rect!, showSubFeature: _showSubFeature, rootFeature: i == 0);
      i++;
      if (i >= 1 && collapseMode == TrackCollapseMode.collapse) break;
    }
    // drawRowFeature(canvas, feature, feature.rect, showSubFeature: _showSubFeature, rootFeature: true);
  }

  void drawRowFeature(Canvas canvas, Feature feature, Rect parentRect, {showSubFeature = false, rootFeature = false}) {
    //draw self sub features
    if (!showSubFeature) {
      drawHorizontalFeatureBackgroundStrand(canvas, feature, parentRect, showSubFeature);
      return;
    }

    if (feature.hasSubFeature) {
      if (feature.subFeatures!.length == 1) {
        if (feature.subFeatures!.first.range.size < feature.range.size) {
          // drawMinFeature(canvas, feature, parentRect, true);
          drawRect(canvas, feature.rect!, _paint..color = styleConfig.groupColor!.withGreen(100));
          _drawFeatureStrand(canvas, feature, parentRect, true);
        }
        //only one sub feature, do not draw self
        // FeatureStyle featureStyle = styleConfig[feature.type.toLowerCase()];
        // if(featureStyle.visible && featureStyle.id != 'others'){
        //   drawMinFeature(canvas, feature, parentRect, true);
        // }
        drawMinFeature(canvas, feature.subFeatures!.first, parentRect, true);
      } else {
        feature.subFeatures!.sort(featureSortFunction);
        drawRowSubFeatures(canvas, feature, parentRect);
      }
    } else {
      drawMinFeature(canvas, feature, parentRect, true);
    }

    //draw feature strand on intron or
    if (feature.hasSubFeature) {
      var intron = feature.subFeatures!.where((f) => f.type == 'intron').maxBy((f) => f.range.size);
      if (intron != null) {
        _drawFeatureStrand(canvas, intron, parentRect, false);
      } else if (feature.subFeatures!.length > 1) {
        //no intron
        _bgPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = styleConfig.lineColor!;
        canvas.drawLine(feature.rect!.centerLeft, feature.rect!.centerRight, _bgPaint);
        _drawFeatureStrand(canvas, feature, feature.rect!, false);
      }
    }

    if ((_showLabel && rootFeature) || (_showChildrenLabel)) {
      Offset offset = (rootFeature && !_showChildrenLabel ? feature.groupRect : feature.rect)!.bottomLeft.minLeft();
      if (rootFeature && !_showChildrenLabel) offset -= Offset(0, styleConfig.labelFontSize);
      if ((offset.dx == 0 && feature.labelWidth > feature.rect!.right) // || //
          // (feature.labelWidth <= parentRect.width && feature.labelWidth > parentRect.right - feature.rect.left)
          ) {
        offset = Offset(feature.rect!.right - feature.labelWidth, offset.dy);
      }
      drawText(
        canvas,
        text: '${feature.name}',
        offset: offset, //Offset(feature.rect.left, feature.rect.bottom),
        width: 400.0, //featureRect.width,
        style: TextStyle(
          fontFamily: MONOSPACED_FONT,
          fontFamilyFallback: MONOSPACED_FONT_BACK,
          fontSize: styleConfig.labelFontSize,
          // fontWeight: FontWeight.w400,
          color: styleConfig.textColor,
        ),
      );
    }
  }

  ///draw block feature
  void drawHorizontalFeatureBackgroundStrand(Canvas canvas, Feature feature, Rect parentRect, bool showSubFeature) {
    double arrowDirection = (feature.strand == 1 ? 5 : -5);
    double arrowHeight = parentRect.height / 4;
    double arrowWidth = 5;
    if (!showSubFeature) {
      if (feature.hasStrand && feature.rect!.width >= arrowWidth) {
        if (feature.strand > 0) {
          Path path = Path()
            ..moveTo(feature.rect!.left, feature.rect!.top)
            ..lineTo(feature.rect!.right - arrowWidth, feature.rect!.top)
            ..lineTo(feature.rect!.right, feature.rect!.centerRight.dy)
            ..lineTo(feature.rect!.right - arrowWidth, feature.rect!.bottom)
            ..lineTo(feature.rect!.left, feature.rect!.bottom) //
            ..close();
          canvas.drawPath(path, _blockPaint..color = styleConfig.blockBgColor);
        } else {
          Path path = Path()
            ..moveTo(feature.rect!.right, feature.rect!.top)
            ..lineTo(feature.rect!.left + arrowWidth, feature.rect!.top)
            ..lineTo(feature.rect!.left, feature.rect!.center.dy)
            ..lineTo(feature.rect!.left + arrowWidth, feature.rect!.bottom)
            ..lineTo(feature.rect!.right, feature.rect!.bottom) //
            ..close();
          canvas.drawPath(path, _blockPaint..color = styleConfig.blockBgColor);
        }
      } else {
        drawRect(canvas, feature.rect!, _blockPaint..color = styleConfig.blockBgColor);
      }

      if (_showLabel) {
        drawText(
          canvas,
          text: feature.name,
//          offset: feature.rect.topLeft.minLeft() + Offset(5, (feature.rect.height - styleConfig.labelFontSize) / 2 - 2),
          offset: Offset(feature.rect!.topLeft.minLeft().dx, feature.rect!.bottom),
          width: 300.0, //feature.rect.width,
          style: TextStyle(fontSize: styleConfig.labelFontSize, fontWeight: FontWeight.w300, color: styleConfig.textColor),
        );
      }
    } else {
      //show sub feature
      if (feature.strand == 0) return;
      // draw line and arrow
      if (feature.hasSubFeature) {
        var step = rect.width ~/ 4;
        if (feature.rect!.width > step) {
          var _left = feature.rect!.left + step;
          Path path = Path();
          while (_left + arrowDirection < feature.rect!.right) {
            if (_left < rect.right && _left >= 0)
              path
                ..moveTo(_left, feature.rect!.center.dy - arrowHeight)
                ..lineTo(_left + arrowDirection, feature.rect!.center.dy)
                ..lineTo(_left, feature.rect!.center.dy + arrowHeight);
            _left += step;
          }
          _paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = rowHeight! > 10 ? 2 : 1
            ..color = styleConfig.lineColor!.withAlpha(feature.hasSubFeature ? 50 : 150);
          canvas.drawPath(path, _paint);
        } else if (feature.rect!.width > 10) {
          Path arrowPath = Path()
            ..moveTo(feature.rect!.center.dx + arrowDirection, feature.rect!.center.dy - arrowHeight)
            ..lineTo(feature.rect!.center.dx, feature.rect!.center.dy)
            ..lineTo(feature.rect!.center.dx + arrowDirection, feature.rect!.center.dy + arrowHeight);
          _paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = rowHeight! > 10 ? 2 : 1
            ..color = styleConfig.lineColor!.withAlpha(100);
          canvas.drawPath(arrowPath, _paint);
        }
      }
    }
  }

  void drawRowSubFeatures(Canvas canvas, Feature feature, Rect parentRect) {
    if (!inVisibleRange(feature)) return;
    int len = feature.subFeatures!.length;
    if (len > 0) {
      for (int i = 0; i < len; i++) {
        drawRowSubFeatures(canvas, feature.subFeatures![i], feature.rect!);
        //drawHorizontalSingleSubFeature(canvas, element, featureRect);
      }
    } else {
      drawMinFeature(canvas, feature, parentRect);
    }
  }

  void drawMinFeature(Canvas canvas, Feature feature, Rect parentRect, [bool single = false]) {
    //Range range = feature.range;
    Rect fRect = feature.rect!; //Rect.fromLTRB(scale[range.start], parentRect.top, scale[range.end], parentRect.bottom);
    if (fRect.right < 0 || fRect.left > size.width) return;

    FeatureStyle featureStyle = styleConfig[feature.type.toLowerCase()];
    if (!featureStyle.visible) return;

    if (featureStyle.height < 1) {
      fRect = fRect.deflateXY(0, (1 - featureStyle.height) * fRect.height / 2);
    }
    if (fRect.width < 1.5) fRect = fRect.inflateXY(.5, 0);

    Radius? _radius = featureStyle.hasRadius ? Radius.circular(featureStyle.radius) : null;

    featureCache[feature.type.toLowerCase()] ??= Path();
    if (featureStyle.hasBorder && featureStyle.borderColor != Colors.transparent) {
      featurePaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = featureStyle.borderWidth
        ..color = featureStyle.borderColor!;
      if (single && feature.hasStrand && feature.rect!.width > 5) {
        canvas.drawPath(rectToStrandPath(fRect.deflateXY(featureStyle.borderWidth / 2, 0), feature.strand), featurePaint);
        // featureCache[feature.type.toLowerCase()].addPath(rectToStrandPath(fRect.deflateXY(featureStyle.borderWidth / 2, 0), feature.strand), Offset.zero);
      } else {
        drawRect(canvas, fRect.deflateXY(featureStyle.borderWidth / 2, 0), featurePaint, _radius);
        // featureCache[feature.type.toLowerCase()].addRRect(RRect.fromRectAndRadius( fRect.deflateXY(featureStyle.borderWidth / 2, 0), _radius));
      }
    }

    var fillColor = featureStyle.colorWithAlpha;
    if (fillColor != Colors.transparent) {
      featurePaint
        ..style = PaintingStyle.fill
//      ..style = feature.type == 'exon' ? PaintingStyle.stroke : PaintingStyle.fill
        ..color = fillColor;
      if (single && feature.hasStrand && fRect.width > 5) {
        canvas.drawPath(rectToStrandPath(fRect, feature.strand), featurePaint);
        // featureCache[feature.type.toLowerCase()]!.addPath(rectToStrandPath(fRect, feature.strand), Offset.zero);
        if (feature.type == 'intron') _drawFeatureStrand(canvas, feature, parentRect, single);
      } else {
        drawRect(canvas, fRect, featurePaint, _radius);
        // featureCache[feature.type.toLowerCase()]!.addRect(fRect);
      }
    }
    if (!single && fRect.width > 200 && feature.type == 'intron') {
      _drawFeatureStrand(canvas, feature, parentRect, single);
    }
  }

  /// if feature is intron draw strand arrow
  void _drawFeatureStrand(Canvas canvas, Feature feature, Rect parentRect, bool single) {
    double width = feature.rect!.width;

    // if (!single && width < 100) return;
    if (width < 4 || !feature.hasStrand) return;

    Offset center = feature.rect!.center;

    double arrowHalfHeight = (parentRect.height / 2).clamp(3.0, 8.0);
    double arrowHalfWidth = 3;
    int _strand = feature.strand > 0 ? 1 : -1;

    _bgPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = styleConfig.lineColor!;

    double step = 500;

    if (width < step) {
      Path path = Path();
      path
        ..moveTo(center.dx - arrowHalfWidth * _strand, center.dy - arrowHalfHeight)
        ..relativeLineTo(arrowHalfWidth * 2 * _strand, arrowHalfHeight)
        ..relativeLineTo(-arrowHalfWidth * 2 * _strand, arrowHalfHeight);
      canvas.drawPath(path, _bgPaint);
    } else {
      int arrowCount = width ~/ step;
      double delta = (width - arrowCount * step) / 2;
      Path path = Path();
      double _x;
      for (int i = 0; i < arrowCount; i++) {
        _x = feature.rect!.left + i * step + step / 2 + delta - arrowHalfWidth * _strand;
        if (_x < 0 || _x > rect.width) continue;
        path
          ..moveTo(_x, center.dy - arrowHalfHeight)
          ..relativeLineTo(arrowHalfWidth * 2 * _strand, arrowHalfHeight)
          ..relativeLineTo(-arrowHalfWidth * 2 * _strand, arrowHalfHeight);
      }
      canvas.drawPath(path, _bgPaint);
    }
  }

  @override
  findHitItem(Offset position) {
    RangeFeature? blockFeature = trackData.features?.firstOrNullWhere((feature) => (feature.groupRect ?? feature.rect)!.contains(position));
    rootItem = blockFeature?.uniqueId;
    hitItem = _findChildHitItem(blockFeature, position);
    //print('find item ${track.trackName} $item');
    return hitItem;
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
    double arrowWidth = 5;
    if (strand == 1) {
      return rect.width > 5
          ? (Path()
            ..moveTo(rect.left, rect.top)
            ..lineTo(rect.right - arrowWidth, rect.top)
            ..lineTo(rect.right, rect.centerRight.dy)
            ..lineTo(rect.right - arrowWidth, rect.bottom)
            ..lineTo(rect.left, rect.bottom)
            ..close())
          : (Path()
            ..moveTo(rect.left, rect.top)
            ..lineTo(rect.left + 5, rect.center.dy)
            ..lineTo(rect.left, rect.bottom)
            ..close());
    }
    return rect.width > 5
        ? (Path()
          ..moveTo(rect.right, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left + arrowWidth, rect.bottom)
          ..lineTo(rect.left, rect.centerLeft.dy)
          ..lineTo(rect.left + arrowWidth, rect.top)
          ..close())
        : (Path()
          ..moveTo(rect.left, rect.center.dy)
          ..lineTo(rect.left + 5, rect.top)
          ..lineTo(rect.left + 5, rect.bottom)
          ..close());
    ;
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
