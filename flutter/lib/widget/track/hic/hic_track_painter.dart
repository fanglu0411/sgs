import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_data.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_feature_layout.dart';
import 'package:flutter_smart_genome/widget/track/hic/hic_track_widget.dart';
import 'package:dartx/dartx.dart' as dx;

import 'hic_style_config.dart';

class HicTrackPainter extends AbstractTrackPainter<HicData, HicStyleConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;

  late HicDisplayMode displayMode;

  HicTrackPainter({
    required super.trackData, // may be data in a range
    required super.styleConfig,
    required super.scale, // the scale by the hole chromosome
    required super.visibleRange,
    super.track,
    super.orientation,
    super.showSubFeature,
    double? trackHeight,
    super.selectedItem,
    required double pixelOfSeq,
    this.displayMode = HicDisplayMode.heatmap,
    super.scaling = false,
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
      ..strokeWidth = 1;

    _bgPaint = Paint();
    _blockPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    _selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = displayMode == HicDisplayMode.arc ? 2 : .8
      ..isAntiAlias = true
      ..color = styleConfig.selectedColor;

    rowSpace = .5;
    minHeight = 60;

//    trackData.filter(styleConfig.visibleFeatureTypes());
//     trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(trackData.matrix, pixelOfSeq);
  }

  void calculateFeatureHeight(HicMatrix hicMatrix, double pixelsOfSeq) {
    HicFeatureLayout featureLayout = TrackLayoutManager().getTrackLayout(track!) as HicFeatureLayout;
    featureLayout.calculate(
      trackData: trackData,
      binSize: hicMatrix.binSize,
      rowHeight: rowHeight ?? 0,
      rowSpace: rowSpace!,
      scale: scale,
      orientation: orientation!,
      collapseMode: collapseMode,
      showLabel: false,
      labelFontSize: 12.0,
      visibleRange: visibleRange,
      padding: styleConfig.padding!,
      pixelsOfSeq: pixelsOfSeq,
      displayMode: displayMode,
      scaling: scaling,
    );
    maxHeight = rowHeight ?? featureLayout.maxHeight + styleConfig.padding!.vertical;
    // if ((featureLayout.maxHeight ?? 0) > 0) {
    //   maxHeight = featureLayout.maxHeight + styleConfig.padding!.vertical;
    // } else {
    //   maxHeight = rowHeight; // track.defaultTrackHeight;
    // }
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      //canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor);
      // drawRect(canvas, _bgPaint..color = styleConfig.backgroundColor, rect);
    }

    if (displayMode == HicDisplayMode.heatmap) {
      _blockPaint..style = PaintingStyle.fill;
      canvas.save();

      // Matrix4 matrix4 = Matrix4.identity();
      // matrix4..scale(1.0, .5)
      // ..translate(size.width / 2, size.height / 2)
      // ..rotateX(180)
      // ..translate(-size.width / 2, -size.height) //
      ;
      // canvas.transform(matrix4.storage);

      trackData.bins.forEach((bin) => _drawItemByHeatmap(bin, canvas));
      checkSelectedItemHeatmap(canvas);

      canvas.restore();
    } else {
      _blockPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      trackData.bins.sortedBy((b) => b.value!).forEach((bin) => _drawItemByArc(bin, canvas));
      checkSelectedItemArc(canvas);
    }
    // for (RangeFeature feature in trackData.features) {
    //   if (!inVisibleRange(feature)) continue;
    //   drawRect(canvas, feature.rect, _blockPaint);
    // }
  }

  void _drawItemByHeatmap(HicBin bin, Canvas canvas) {
    if (bin.color == null || bin.value == null || bin.value == 0 || !bin.visible) return;
    // var _color = interceptSingleColor(styleConfig.color, bin.color.clamp(.05, 1.0));
    // var _color = styleConfig.color.withAlpha(bin.color!.clamp(1, 255));
    var _color = styleConfig.color.withOpacity(bin.color!.clamp(0.0, 1.0));
    canvas.drawPath(bin.path!, _blockPaint..color = _color);
    // canvas.drawPath(bin.path, _paint..color = Colors.white70);
  }

  void _drawItemByArc(HicBin bin, Canvas canvas) {
    if (bin.value == null || bin.value == 0 || !bin.visible) return;
    // var _color = interceptSingleColor(styleConfig.color, bin.color.clamp(.05, 1.0));
    // var _color = styleConfig.color.withAlpha(bin.color!.clamp(1, 255));
    var _color = styleConfig.color.withOpacity(bin.color!.clamp(0.0, 1.0));

    // Path arc = Path()..moveTo(bin.pixRange1.center, painterRect.top)..arc
    // canvas.drawArc(bin.arcRect, 0, pi, true, _blockPaint..color = _color);
    canvas.drawPath(bin.arcPath!, _blockPaint..color = _color);
    // canvas.drawPath(bin.path, _paint..color = Colors.white70);
  }

  void checkSelectedItemArc(Canvas canvas) {
    if (null == selectedItem) return;
    HicBin _selected = selectedItem;
    canvas.drawPath(_selected.arcPath!, _selectedPaint);
    Path _rangePath = Path();
    _rangePath
      ..moveTo(scale.scale(_selected.range1.start) as double, styleConfig.padding!.top)
      ..lineTo(scale.scale(_selected.range1.end) as double, styleConfig.padding!.top)
      ..moveTo(scale.scale(_selected.range2.start) as double, styleConfig.padding!.top)
      ..lineTo(scale.scale(_selected.range2.end) as double, styleConfig.padding!.top);
    canvas.drawPath(_rangePath, _selectedPaint);

    var tooltip = 'value : ${_selected.value}\nrange1: ${_selected.range1.print()}\nrange2: ${_selected.range2.print()}';
    var offset = _selected.arcPath!.getBounds().bottomCenter + Offset(-80, 4);
    drawTooltip(canvas, tooltip, offset, _bgPaint);
  }

  void checkSelectedItemHeatmap(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;
    HicBin _selected = selectedItem;
    canvas.drawPath(_selected.path!, _selectedPaint);

    double start1 = scale.scale(_selected.range1.start)!;
    double end1 = scale.scale(_selected.range1.end)!;
    Path path1 = Path()
      ..moveTo(start1, painterRect.top)
      ..lineTo(end1, painterRect.top)
      ..lineTo(_selected.points![3].dx, _selected.points![3].dy)
      ..lineTo(_selected.points![0].dx, _selected.points![0].dy)
      ..close();
    canvas.drawPath(path1, _selectedPaint);

    double start2 = scale.scale(_selected.range2.start) as double;
    double end2 = scale.scale(_selected.range2.end) as double;
    Path path2 = Path()
      ..moveTo(start2, painterRect.top)
      ..lineTo(end2, painterRect.top)
      ..lineTo(_selected.points![2].dx, _selected.points![2].dy)
      ..lineTo(_selected.points![3].dx, _selected.points![3].dy)
      ..close();
    canvas.drawPath(path2, _selectedPaint);

    var offset = _selected.path!.getBounds().bottomCenter + Offset(-80, 8);
    var tooltip = 'value : ${_selected.value}\nrange1: ${_selected.range1.print()}\nrange2: ${_selected.range2.print()}';
    drawTooltip(canvas, tooltip, offset, _bgPaint);
  }

  @override
  findHitItem(Offset position) {
    // RangeFeature blockFeature = trackData?.features?.firstWhere(
    //   (feature) => (feature.groupRect ?? feature.rect).contains(position),
    //   orElse: () => null,
    // );
    // //print('find item ${track.trackName} $item');
    // hitItem = blockFeature;
    // return hitItem;

    if (displayMode == HicDisplayMode.arc) {
      Iterable<HicBin> find = trackData.bins.where((b) => (b.visible ?? false) && (b.arcPath?.contains(position) ?? false));
      if (find.length > 0) {
        hitItem = find.minBy((e) => e.arcPath!.getBounds().height);
      } else {
        hitItem = null;
      }
    } else {
      HicBin? find = trackData.bins.firstOrNullWhere((b) => (b.visible ?? false) && (b.path?.contains(position) ?? false));
      hitItem = find;
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
    HicTrackPainter _painter = painter as HicTrackPainter;
    return super.painterChanged(painter) || _painter.trackData != trackData;
  }
}
