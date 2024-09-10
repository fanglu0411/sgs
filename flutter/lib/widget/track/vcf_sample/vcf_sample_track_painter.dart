import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/page/track/track_ui_config_bean.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_data.dart';
import 'package:flutter_smart_genome/widget/track/painter/feature_style_config.dart';
import 'dart:math' show max, pi;
import 'package:dartx/dartx.dart' as dx;
import 'package:flutter_smart_genome/widget/track/vcf_sample/vcf_sample_feature_layout.dart';

class VcfSampleTrackPainter extends AbstractTrackPainter<FeatureData, FeatureStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;
  late String labelKey;
  late double offset;

  late double viewHeight;

  late int pageSize;

  late int rowStart = 0;
  late int rowEnd;

  late bool trackHover;
  late bool showSampleName;

  VcfSampleTrackPainter({
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
    required double trackHeight,
    double? featureHeight,
    this.labelKey = 'name',
    this.offset = 0,
    this.trackHover = false,
    this.showSampleName = true,
  }) : super(
          rowHeight: featureHeight,
          rowSpace: 10,
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

    viewHeight = trackHeight;

//    trackData.filter(styleConfig.visibleFeatureTypes());
    trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(trackData.features!, styleConfig.showLabel && showSubFeature!, styleConfig.labelFontSize, labelKey);
  }

  void calculateFeatureHeight(List<Feature> features, bool showLabel, double labelFontSize, String labelKey) {
    VcfSampleFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(track!) as VcfSampleFeatureLayout;
    pageSize = (viewHeight / (rowHeight! + rowSpace!)).ceil() + 2;
    rowStart = (offset / (rowHeight! + rowSpace!)).floor();
    rowEnd = rowStart + pageSize;
    if (rowStart < 0) rowStart = 0;
    if (rowEnd >= featureLayout.sampleCount) rowEnd = featureLayout.sampleCount - 1;
    // print('row start:$rowStart, row end:$rowEnd, pageSize: ${pageSize} count:${featureLayout.sampleCount}, rowHeight: ${rowHeight + rowSpace}');
    featureLayout
      ..rowHeight = rowHeight
      ..rowSpace = rowSpace
      ..padding = styleConfig.padding;
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
    // return showLabel && showSubFeature;
    return false;
  }

  bool needShowSubFeature(Rect rect, [double width = 0.0]) {
    return showSubFeature! || (rect.width > 20);
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    // super.onEmptyPaint(canvas, size);
    return false;
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    VcfSampleFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(track!) as VcfSampleFeatureLayout;
    _bgPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = .1
      ..color = styleConfig.lineColor!;
    for (int i = rowStart; i <= rowEnd; i++) {
      double top = i * (rowHeight! + rowSpace!) + styleConfig.padding.top;
      canvas.drawLine(Offset(rect.left, top + rowHeight! + rowSpace!), Offset(rect.right, top + rowHeight! + rowSpace!), _bgPaint);
    }

    // for (RangeFeature feature in (trackData.features ?? [])) {
    //   if (!inVisibleRange(feature)) continue;
    //   drawHorizontalFeature(canvas, feature, feature.rect);
    // }
    _drawFeatures(canvas);

    if (showSampleName) {
      for (int i = rowStart; i <= rowEnd; i++) {
        double top = i * (rowHeight! + rowSpace!) + styleConfig.padding.top;
        drawText(
          canvas,
          text: featureLayout.sampleList![i],
          width: 300,
          style: TextStyle(color: styleConfig.textColor, fontSize: styleConfig.labelFontSize),
          offset: Offset(0, top + (rowHeight! + rowSpace!) / 2 - styleConfig.labelFontSize / 2),
        );
      }
    }

    checkSelectedItem(canvas);
  }

  checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;

    Feature feature = selectedItem;
    //logger.d('selected item ${feature.id}');
    Rect _rect = Rect.fromLTRB(feature.rect!.left, rowStart * (rowHeight! + rowSpace!), feature.rect!.right, (rowEnd + 1) * (rowHeight! + rowSpace!));
    drawRect(
      canvas,
      (_rect).inflate(inflateValue),
      _selectedPaint,
      Radius.circular(2),
    );
  }

  void _drawFeatures(Canvas canvas) {
    Map<String, Path> typeRectMap = Map.fromIterables(styleConfig.featureStyles.keys, List.generate(styleConfig.featureStyles.length, (index) => Path()));

    String type;
    for (Feature feature in (trackData.features ?? [])) {
      if (!inVisibleRange(feature)) continue;
      VcfSampleFeatureLayout layout = TrackLayoutManager().getTrackLayout(track!) as VcfSampleFeatureLayout;
      List genoTypes = feature['sample_geno_types'];
      for (int row = rowStart; row <= rowEnd; row++) {
        if (row >= genoTypes.length) continue;
        type = '${genoTypes[row]}';
        // FeatureStyle featureStyle = styleConfig.getFeatureStyle(type);
        // if (featureStyle == null) continue;
        typeRectMap[type]?.addRect(layout.rowRect(feature, row));
      }
    }

    for (var entry in typeRectMap.entries) {
      FeatureStyle? featureStyle = styleConfig[entry.key];
      featurePaint
        ..style = PaintingStyle.fill
        ..color = featureStyle.color ?? styleConfig.blockBgColor;
      canvas.drawPath(entry.value, featurePaint);
    }
  }

  ///
  /// draw horizontal feature
  ///
  void drawHorizontalFeature(Canvas canvas, RangeFeature feature, Rect featureRect) {
    // bool _selected = selectedItem != null && selectedItem is BlockFeature && (selectedItem as BlockFeature).id == feature.id;
    drawHorizontalSingleSubFeature(canvas, feature, featureRect);
  }

  void drawHorizontalSingleSubFeature(Canvas canvas, Feature feature, Rect parentRect) {
    //Range range = feature.range;
    Rect fRect = feature.rect!; //Rect.fromLTRB(scale[range.start], parentRect.top, scale[range.end], parentRect.bottom);
    if (fRect.right < 0 || fRect.left > size.width) return;

//    if (!featureStyle.visible) return;

    VcfSampleFeatureLayout layout = TrackLayoutManager().getTrackLayout(track!) as VcfSampleFeatureLayout;
    List genoTypes = feature['sample_geno_types'];
    for (int row = rowStart; row <= rowEnd; row++) {
      if (row >= genoTypes.length) continue;
      String type = '${genoTypes[row]}';
      FeatureStyle? featureStyle = styleConfig[type];
      featurePaint
        ..style = PaintingStyle.fill
        ..color = featureStyle.color ?? styleConfig.blockBgColor;
      drawRect(canvas, layout.rowRect(feature, row), featurePaint);
    }
  }

  @override
  findHitItem(Offset position) {
    Feature? blockFeature = trackData.features?.firstOrNullWhere((feature) => (feature.groupRect ?? feature.rect!).contains(position));
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