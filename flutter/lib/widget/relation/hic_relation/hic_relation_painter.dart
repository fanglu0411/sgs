import 'package:d4/d4.dart' as d4;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/hic_relation_layout.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'dart:math' show Random, max, pi;
import 'package:dartx/dartx.dart' as dx;

import 'hic_relation_style_config.dart';
import 'interactive_data.dart';

class HicRelationPainter extends AbstractTrackPainter<InteractiveData, HicRelationConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;

  late d4.Scale<num, num> linearScale2;
  Range visibleRange2;

  double _chrHeight = 16;
  String chr1;
  String chr2;

  HicRelationPainter({
    required InteractiveData trackData, // may be data in a range
    required HicRelationConfig styleConfig,
    required d4.ScaleLinear<num> linearScale, // the scale by the hole chromosome
    required this.linearScale2,
    required Range visibleRange,
    required this.visibleRange2,
    required Track track,
    required Axis orientation,
    bool? showSubFeature,
    required double trackHeight,
    dynamic selectedItem,
    required double pixelOfSeq,
    required double pixelOfSeq2,
    required this.chr1,
    required this.chr2,
  }) : super(
          trackData: trackData,
          styleConfig: styleConfig,
          scale: linearScale,
          visibleRange: visibleRange,
          track: track,
          orientation: orientation,
          showSubFeature: showSubFeature,
          rowHeight: trackHeight,
          selectedItem: selectedItem,
        ) {
    featurePaint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    _paint = Paint()
      ..color = Colors.green[200]!
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..strokeWidth = 2.0;

    _bgPaint = Paint()..style = PaintingStyle.fill;
    _blockPaint = Paint()
      ..strokeWidth = 2.0
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..isAntiAlias = true
      ..color = styleConfig.selectedColor;
    rowSpace = .5;

    // print('range1: ${visibleRange}');
    // print('range2: ${visibleRange2}');

//    trackData.filter(styleConfig.visibleFeatureTypes());
//     trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(trackData, linearScale2, pixelOfSeq, pixelOfSeq2);
  }

  void calculateFeatureHeight(InteractiveData data, d4.Scale<num, num> scale2, double pixelsOfSeq, double pixelsOfSeq2) {
    HicRelationLayout featureLayout = TrackLayoutManager().getRelationLayout(track!) as HicRelationLayout;
    featureLayout.calculate(
      data: data,
      scale1: scale,
      scale2: scale2,
      orientation: orientation!,
      collapseMode: collapseMode,
      visibleRange1: visibleRange,
      visibleRange2: visibleRange2,
      padding: styleConfig.padding!,
      pixelsOfSeq1: pixelsOfSeq,
      pixelsOfSeq2: pixelsOfSeq2,
      top: styleConfig.padding!.top + _chrHeight,
      bottom: rowHeight! - _chrHeight - styleConfig.padding!.bottom,
    );
    maxHeight = rowHeight ?? track!.defaultTrackHeight;
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    return false;
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (styleConfig.backgroundColor != null) {
      //canvas.drawRect(rect, _bgPaint..color = styleConfig.backgroundColor);
      drawRect(
        canvas,
        rect,
        _bgPaint..color = styleConfig.backgroundColor!,
      );
    }

    //draw chr1
    canvas.drawRect(
      Rect.fromLTRB(
        painterRect.left,
        painterRect.top,
        painterRect.right,
        painterRect.top + _chrHeight,
      ),
      _blockPaint
        ..style = PaintingStyle.fill
        ..color = styleConfig.lineColor!.withOpacity(.25),
    );

    //draw chr2
    canvas.drawRect(
      Rect.fromLTRB(
        painterRect.left,
        painterRect.bottom - _chrHeight,
        painterRect.right,
        painterRect.bottom,
      ),
      _blockPaint..color = styleConfig.lineColor!.withOpacity(.25),
    );

    // d4.ScaleSequential colorScale = d4.ScaleSequential(domain: [0, trackData.maxValue], interpolator: d4.interpolateRgb('#fff',styleConfig.lineColor. ));
    d4.ScaleLinear<num> opacityScale = d4.ScaleLinear.number(domain: [0, trackData.maxValue], range: [10, 255]);
    Color _color;
    // Path path;
    for (InteractiveItem block in trackData.data!) {
      // _color = interceptSingleColor(styleConfig.lineColor!, block.colorValue).withOpacity(block.colorValue);
      // _color = d4.Color.parse(colorScale.call(block.value)).flutterColor;

      _color = styleConfig.lineColor!.withAlpha(opacityScale.call(block.value)!.toInt());
      // path = block.getPath(painterRect.top + _chrHeight, painterRect.bottom - _chrHeight);
      _blockPaint
        ..style = block.needClose ? PaintingStyle.fill : PaintingStyle.stroke
        ..color = _color;
      canvas.drawPath((block.path), _blockPaint);
      canvas.drawRect(
        Rect.fromLTWH(
          block.uiRange1.start,
          painterRect.top,
          max(block.uiRange1.size, 1.0),
          _chrHeight,
        ),
        _blockPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          block.uiRange2.start,
          painterRect.bottom - _chrHeight,
          max(block.uiRange2.size, 1.0),
          _chrHeight,
        ),
        _blockPaint,
      );
    }
    checkSelectedItem(canvas);
  }

  checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;
    InteractiveItem _selected = selectedItem;
    // Path _path = _selected.getPath(painterRect.top + _chrHeight, painterRect.bottom - _chrHeight);
    _selectedPaint
      ..color = styleConfig.selectedColor
      ..style = _selected.needClose ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawPath(
      _selected.path,
      _selectedPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        _selected.uiRange1.start,
        painterRect.top,
        _selected.uiRange1.end,
        painterRect.top + _chrHeight,
      ),
      _selectedPaint,
    );

    canvas.drawRect(
      Rect.fromLTRB(
        _selected.uiRange2.start,
        painterRect.bottom - _chrHeight,
        _selected.uiRange2.end,
        painterRect.bottom,
      ),
      _selectedPaint,
    );
    Rect _bounds = _selected.path.getBounds();
    var toolTip = 'name  : ${_selected.name ?? ''}\nLocus1: ${chr1}:${_selected.range1.print('-')}\nLocus2: ${chr2}:${_selected.range2.print('-')}\nscore : ${_selected.value}';
    drawTooltip(canvas, toolTip, _bounds.center, _bgPaint);
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

    Iterable<InteractiveItem> finds = trackData.data!.where(
      (b) => b.areaPath.contains(position),
    );
    if (finds.length == 0) {
      hitItem = null;
      return hitItem;
    }
    InteractiveItem? find = finds.minBy((f) {
      var intersection = Path.combine(
          PathOperation.intersect,
          f.areaPath,
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
    });
    hitItem = find;
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
    HicRelationPainter _painter = painter as HicRelationPainter;
    bool changed = super.painterChanged(painter) || //
        _painter.visibleRange != visibleRange ||
        _painter.visibleRange2 != visibleRange2 ||
        _painter.linearScale2 != linearScale2 ||
        painter.rowHeight != _painter.rowHeight;
    return changed;
  }
}
