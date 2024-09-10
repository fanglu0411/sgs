import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/bam_reads/bam_reads_layout.dart';
import 'package:flutter_smart_genome/widget/track/bam_reads/reads_view_options.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'dart:math' show max;
import 'package:dartx/dartx.dart' as dx;

class BamReadsTrackPainter extends AbstractTrackPainter<FeatureData<BamReadsFeature>, FeatureStyleConfig> {
  late Paint _paint;

  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;
  late String labelKey;
  late bool paired;
  late ReadsColorOption colorOption;

  BamReadsTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    required super.track,
    super.orientation,
    super.showSubFeature,
    super.collapseMode,
    super.selectedItem,
    super.scaling = false,
    double? trackHeight,
    this.labelKey = 'name',
    this.paired = false,
    this.colorOption = ReadsColorOption.strand_default,
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
      ..isAntiAlias = true
      ..strokeWidth = 1;

    _selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .8
      ..isAntiAlias = true
      ..color = styleConfig.selectedColor;

    rowSpace = styleConfig.labelFontSize + 4;

//    trackData.filter(styleConfig.visibleFeatureTypes());
    trackData.distinct(distinctBy: (f) => f.name);
    calculateFeatureHeight(
      trackData.features!,
      false, //styleConfig.showLabel && showSubFeature,
      styleConfig.labelFontSize,
      labelKey,
    );
  }

  void calculateFeatureHeight(List<BamReadsFeature> features, bool showLabel, double labelFontSize, String labelKey) {
    BamReadsLayout featureLayout = TrackLayoutManager().getTrackLayout(track!..paired = paired) as BamReadsLayout;
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
    );
    if ((featureLayout.maxHeight) > 0) {
      maxHeight = max(maxHeight!, featureLayout.maxHeight + styleConfig.padding.vertical);
    } else {
      maxHeight = track!.defaultTrackHeight;
    }
  }

  bool _showLabel(Feature feature, bool showLabel, bool showSubFeature) {
    return false;
    return showLabel && showSubFeature;
  }

  bool needShowSubFeature(Rect rect, [double width = 0.0]) {
    return showSubFeature! && (rect.width >= 2);
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      //canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor);
      // drawRect(canvas, _bgPaint..color = styleConfig.backgroundColor, rect);
    }
    // _gapPath = Path();
    // _rectPath = Path();
    for (BamReadsFeature feature in trackData.features!) {
      if (feature.rect == null || !inVisibleRange(feature)) continue;
      drawHorizontalFeature(canvas, feature, feature.rect!);
    }
    checkSelectedItem(canvas);

    // canvas.drawPath(_gapPath, _paint..color = styleConfig.blockBgColor);
    // canvas.drawPath(_rectPath, featurePaint..color = Colors.red);
  }

  checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;

    Feature feature = selectedItem;
    //logger.d('selected item ${feature.id}');
    drawRect(
      canvas,
      (feature.rect)!.inflate(inflateValue),
      _selectedPaint,
      Radius.circular(2),
    );

    Rect _rect = (feature.groupRect ?? feature.rect!);
    // if ((!showSubFeature)) {
    var offset = _rect.bottomLeft.minLeft() + Offset(4, 4);
    drawTooltip(canvas, '${feature.name}', offset, _selectedPaint);
  }

  Path _gapPath = Path();
  Path _rectPath = Path();

  ///
  /// draw horizontal feature
  ///
  void drawHorizontalFeature(Canvas canvas, BamReadsFeature feature, Rect featureRect) {
    //draw self feature
    drawFeatureBlock(canvas, feature, featureRect);
    //draw gap
    _gapPath.reset();
    List<Feature> gaps = feature.gaps ?? [];
    for (Feature gap in gaps) {
      _gapPath.addRect(gap.rect!.deflateXY(0, (featureRect.height - 2) / 2));
    }
    _paint
      ..style = PaintingStyle.fill
      ..color = styleConfig.blockBgColor;
    canvas.drawPath(_gapPath, _paint);

    //paired reads
    if (feature.linkTo != null) {
      canvas.drawLine(featureRect.centerRight, feature.linkTo!, _paint..color = Colors.grey);
    }

    drawSubFeatures(canvas, feature, featureRect);

    // reads feature always false, no label to show
    // if (_showLabel(feature, styleConfig.showLabel, this.showSubFeature)) {
    //   Offset offset = featureRect.bottomLeft.minLeft();
    //   if (offset.dx == 0 && feature.labelWidth > feature.rect.right) offset = Offset(feature.rect.right - feature.labelWidth, offset.dy);
    //   var style = TextStyle(
    //     fontSize: styleConfig.labelFontSize,
    //     fontWeight: FontWeight.w400,
    //     color: styleConfig.textColor,
    //     fontFamily: MONOSPACED_FONT,
    //     fontFamilyFallback: MONOSPACED_FONT_BACK,
    //   );
    //   TextSpan nameSpan = TextSpan(text: feature.name, style: style);
    //   drawTextSpan(
    //     canvas,
    //     text: nameSpan,
    //     offset: offset, //Offset(feature.rect.left, feature.rect.bottom),
    //     width: feature.labelWidth, //featureRect.width,
    //   );
    // }
  }

  void drawSubFeatures(Canvas canvas, Feature feature, Rect featureRect) {
    bool _showSubFeature = needShowSubFeature(featureRect);
    if (feature.hasSubFeature) {
      Feature? preFeature;
      feature.subFeatures!.forEachIndexed((subFeature, i) {
        if (subFeature['alt_type'] == 'line') return;
        bool clipType = styleConfig.getFeatureStyle(subFeature['alt']) == null && subFeature.range.size == 0;
        if (clipType) {
          if (featureRect.width > 80 && !scaling) {
            bool draw = _drawClipSubFeature(canvas, subFeature, featureRect, preFeature);
            if (draw) preFeature = subFeature;
          }
        } else if (_showSubFeature) {
          drawSingleSubFeature(canvas, subFeature, featureRect);
        }
      });
    }
  }

  /// draw feature block
  void drawFeatureBlock(Canvas canvas, Feature feature, Rect parentRect) {
    Rect? fRect = feature.rect; //Rect.fromLTRB(scale[range.start], parentRect.top, scale[range.end], parentRect.bottom);
    if (fRect == null || fRect.right < 0 || fRect.left > size.width) return;
    fRect = fRect.intersectHorizontal(rect);

    Color? featureColor;
    var colorKey = feature.strandStr;
    if (ReadsColorOption.strand_default == colorOption) {
      //todo more key to set
      colorKey = feature.strandStr == '.' ? 'no_strand' : (feature.strandStr == "+" ? 'fwd' : 'rev');
      featureColor = styleConfig[colorKey].color;
    } else if (ReadsColorOption.strand == colorOption || ReadsColorOption.no_color == colorOption) {
      colorKey = feature.strandStr == '.' ? 'no_strand' : feature.strandStr;
      featureColor = styleConfig[colorKey].color;
    } else if (ReadsColorOption.modification == colorOption || ReadsColorOption.melthylation == colorOption) {
      colorKey = feature.strandStr == '.' ? 'no_strand' : feature.strandStr;
      featureColor = styleConfig[colorKey].color;
    } else {
      //linear color by value
      Color startColor = styleConfig['start'].color!;
      Color endColor = styleConfig['end'].color!;
      featureColor = Color.lerp(startColor, endColor, .5);
    }

    var rects = [fRect];
    if (feature is BamReadsFeature && feature.rects != null) {
      rects = feature.rects!;
    }

    featurePaint
      ..style = PaintingStyle.fill
      ..color = featureColor ?? styleConfig.blockBgColor;

    _rectPath.reset();
    rects.forEach((fRect) => _rectPath.addRect(fRect));
    canvas.drawPath(_rectPath, featurePaint);
  }

  /// draw single sub-feature
  void drawSingleSubFeature(Canvas canvas, Feature feature, Rect parentRect) {
    Rect? fRect = feature.rect; //Rect.fromLTRB(scale[range.start], parentRect.top, scale[range.end], parentRect.bottom);
    if (fRect == null || fRect.right < 0 || fRect.left > size.width) return;
    fRect = fRect.intersectHorizontal(rect);

    FeatureStyle? featureStyle = styleConfig[feature['alt']];
//    if (!featureStyle.visible) return;

    //currently always no border
//     Radius _radius = featureStyle.radius != null && featureStyle.radius > 0 ? Radius.circular(featureStyle.radius) : null;
//     if (featureStyle.hasBorder) {
//       featurePaint
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = featureStyle.borderWidth
//         ..color = featureStyle.borderColor;
//       drawRect(canvas, fRect, featurePaint, _radius);
//     }

    var rects = [fRect];
    if (feature is BamReadsFeature && feature.rects != null) {
      rects = feature.rects!;
    }

    featurePaint
      ..style = PaintingStyle.fill
      ..color = featureStyle.color ?? styleConfig.blockBgColor;

    _rectPath.reset();
    rects.forEach((fRect) => _rectPath.addRect(fRect));
    canvas.drawPath(_rectPath, featurePaint);

    if (fRect.width >= 8) {
      double fontSize = (20.0).clamp(6.0, fRect.height + 2.0);
      drawText(
        canvas,
        text: '${feature['alt']}',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontFamily: MONOSPACED_FONT,
          fontFamilyFallback: MONOSPACED_FONT_BACK,
        ),
        offset: fRect.topLeft + Offset(0, (fRect.height - fontSize) / 2 - 2.0),
        textAlign: TextAlign.center,
        width: fRect.width,
      );
    }
  }

  bool _drawClipSubFeature(Canvas canvas, Feature feature, Rect parentRect, Feature? preFeature) {
    if (feature.rect == null) return false;
    Rect fRect = feature.rect!;
    if (fRect.right < 0 || fRect.left > size.width) return false;
    double fontSize = (18.0).clamp(6.0, fRect.height + 2);
    if (preFeature != null && (preFeature.rect!.left + '${preFeature['alt']}'.length * fontSize > fRect.left)) return false;
    fRect = fRect.intersectHorizontal(rect);

    var del = (fRect.right - parentRect.right).abs();
    drawText(
      canvas,
      text: '${feature['alt']}',
      style: TextStyle(
        color: styleConfig.textColor,
        fontSize: fontSize,
        fontFamily: MONOSPACED_FONT,
        fontFamilyFallback: MONOSPACED_FONT_BACK,
        fontWeight: FontWeight.bold,
      ),
      offset: (del <= 1 ? parentRect.topLeft : fRect.topLeft) + Offset(0, (fRect.height - fontSize) / 2 - 2.0),
      textAlign: del <= 1 ? TextAlign.end : TextAlign.start,
      width: parentRect.width,
    );
    return true;
  }

  @override
  findHitItem(Offset position) {
    RangeFeature? blockFeature = trackData.features?.firstOrNullWhere((feature) => (feature.groupRect ?? feature.rect)?.contains(position) ?? false);
    var item = _findChildHitItem(blockFeature, position);
    //print('find item ${track.trackName} $item');
    hitItem = item;
    return item;
  }

  Feature? _findChildHitItem(Feature? feature, Offset position) {
    if (feature == null) return null;

    Feature _find = feature;
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
