import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'dart:math' show max, pi;
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/vcf/vcf_feature_layout.dart';

class VcfTrackPainter extends AbstractTrackPainter<FeatureData, FeatureStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;
  late String labelKey;

  VcfTrackPainter({
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

    rowSpace = labelKey == 'alt_detail' ? (styleConfig.labelFontSize + 4) * 2 : styleConfig.labelFontSize + 4;

//    trackData.filter(styleConfig.visibleFeatureTypes());
//     trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(trackData.features!, styleConfig.showLabel && showSubFeature!, styleConfig.labelFontSize, labelKey);
  }

  void calculateFeatureHeight(List<Feature> features, bool showLabel, double labelFontSize, String labelKey) {
    VcfFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(track!) as VcfFeatureLayout;
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
      labelKey: labelKey,
      padding: styleConfig.padding,
    );
    if ((featureLayout.maxHeight ?? 0) > 0) {
      maxHeight = max(maxHeight!, featureLayout.maxHeight + styleConfig.padding.vertical);
    } else {
      maxHeight = track!.defaultTrackHeight;
    }
  }

  bool _showLabel(Feature feature, bool showLabel, bool showSubFeature) {
    return showLabel && showSubFeature;
  }

  bool needShowSubFeature(Rect rect, [double width = 0.0]) {
    return showSubFeature! || (rect.width > 20);
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      //canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor);
      // drawRect(canvas, _bgPaint..color = styleConfig.backgroundColor, rect);
    }
    for (Feature feature in trackData.features!) {
      if (!inVisibleRange(feature)) continue;
      drawHorizontalFeature(canvas, feature, feature.rect!);
    }
    checkSelectedItem(canvas);
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
    if ((!showSubFeature! || labelKey != 'alt_detail')) {
      var offset = _rect.bottomLeft.minLeft() + Offset(0, 10);
      drawTooltip(canvas, '${feature.name}', offset, _selectedPaint);
    }
  }

  ///
  /// draw horizontal feature
  ///
  void drawHorizontalFeature(Canvas canvas, Feature feature, Rect featureRect) {
    bool _selected = selectedItem != null && selectedItem is Feature && (selectedItem as Feature).uniqueId == feature.uniqueId;
    bool _showSubFeature = needShowSubFeature(featureRect);
    drawHorizontalBlock(canvas, feature, feature.rect!, true, _showSubFeature);
  }

  void drawHorizontalBlock(Canvas canvas, Feature feature, Rect featureRect, [bool drawBackground = false, showSubFeature = false]) {
    //draw self sub features
    drawHorizontalSingleSubFeature(canvas, feature, featureRect);
    if (_showLabel(feature, styleConfig.showLabel, this.showSubFeature!)) {
      Offset offset = featureRect.bottomLeft.minLeft();
      if (offset.dx == 0 && feature.labelWidth > feature.rect!.right) offset = Offset(feature.rect!.right - feature.labelWidth, offset.dy);
      var style = TextStyle(
        fontFamily: MONOSPACED_FONT,
        fontFamilyFallback: MONOSPACED_FONT_BACK,
        fontSize: styleConfig.labelFontSize,
        fontWeight: FontWeight.w400,
        color: styleConfig.textColor,
      );
      TextSpan nameSpan = TextSpan(
        text: feature.name + '\n',
        style: style.copyWith(color: styleConfig.textColor!.withRed(200)),
      );
      // bool drawName = feature.name != '.';
      if (kIsWeb && labelKey == 'alt_detail') {
        drawTextSpan(
          canvas,
          text: nameSpan,
          offset: offset, //Offset(feature.rect.left, feature.rect.bottom),
          width: feature.labelWidth, //featureRect.width,
        );
        drawTextSpan(
          canvas,
          text: TextSpan(text: feature.printValue(labelKey), style: style),
          offset: offset + Offset(0, styleConfig.labelFontSize + 2), //Offset(feature.rect.left, feature.rect.bottom),
          width: feature.labelWidth, //featureRect.width,
        );
      } else {
        TextSpan span = TextSpan(children: [
          if (labelKey == 'alt_detail') nameSpan,
          TextSpan(text: feature.printValue(labelKey), style: style),
        ]);
        drawTextSpan(
          canvas,
          text: span,
          offset: offset, //Offset(feature.rect.left, feature.rect.bottom),
          width: feature.labelWidth, //featureRect.width,
        );
      }
    }
  }

  void drawHorizontalSubFeature(Canvas canvas, Feature feature, Rect featureRect) {
    if (!inVisibleRange(feature)) return;
    if (feature.hasSubFeature) {
      feature.subFeatures!.forEach((e) {
        drawHorizontalSubFeature(canvas, e, e.rect!);
        //drawHorizontalSingleSubFeature(canvas, element, featureRect);
      });
    } else {
      drawHorizontalSingleSubFeature(canvas, feature, featureRect);
    }
  }

  void drawHorizontalSingleSubFeature(Canvas canvas, Feature feature, Rect parentRect) {
    //Range range = feature.range;
    Rect fRect = feature.rect!; //Rect.fromLTRB(scale[range.start], parentRect.top, scale[range.end], parentRect.bottom);
    if (fRect.right < 0 || fRect.left > size.width) return;

    FeatureStyle featureStyle = styleConfig[feature['alt_type']] ?? styleConfig['INDEL'];
//    if (!featureStyle.visible) return;
//
//    Radius _radius = featureStyle.radius != null && featureStyle.radius > 0 ? Radius.circular(featureStyle.radius) : null;
//    if (featureStyle.borderWidth != null && featureStyle.borderWidth > 0 && featureStyle.borderColor != Colors.transparent) {
//      featurePaint
//        ..style = PaintingStyle.stroke
//        ..strokeWidth = featureStyle.borderWidth
//        ..color = featureStyle.borderColor;
//
//      drawRect(canvas, featurePaint, fRect, _radius);
//    }

    featurePaint
      ..style = PaintingStyle.fill
      ..color = featureStyle.color ?? styleConfig.blockBgColor;
    drawRect(canvas, fRect, featurePaint);
  }

  @override
  findHitItem(Offset position) {
    Feature? blockFeature = trackData.features?.firstOrNullWhere((feature) => (feature.groupRect ?? feature.rect)!.contains(position));
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