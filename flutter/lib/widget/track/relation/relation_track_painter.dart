import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/relation/relation_track_layout.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/layout/track_layout_manager.dart';
import 'dart:math' show Random, max, pi;
import 'package:dartx/dartx.dart' as dx;

import 'hic_relation_style_config.dart';
import 'interactive_data.dart';
import 'relation_view_type.dart';

class RelationTrackPainter extends AbstractTrackPainter<InteractiveData, HicRelationConfig> {
  late Paint _paint;
  late Paint _bgPaint;
  late Paint _blockPaint;
  late Paint _selectedPaint;

  late Paint featurePaint;

  double inflateValue = 1;

  double _chrHeight = 16;
  RelationViewType viewMode;

  bool get arcMode => viewMode == RelationViewType.arc;

  RelationTrackPainter({
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
    required double pixelOfSeq,
    this.viewMode = RelationViewType.line,
  }) : super(
          rowHeight: trackHeight,
        ) {
    featurePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
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
      ..strokeWidth = 1.5
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    _selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5
      ..isAntiAlias = true
      ..color = styleConfig.selectedColor;
    rowSpace = .5;

    // print('range1: ${visibleRange}');
    // print('range2: ${visibleRange2}');

//    trackData.filter(styleConfig.visibleFeatureTypes());
//     trackData.filterAndPrepare(visibleRange);
    calculateFeatureHeight(trackData, pixelOfSeq);
  }

  void calculateFeatureHeight(InteractiveData data, double pixelsOfSeq) {
    RelationTrackLayout featureLayout = TrackLayoutManager().getTrackLayout(track!) as RelationTrackLayout;
    featureLayout.calculate(
      data: data,
      scale: scale,
      orientation: orientation!,
      collapseMode: collapseMode,
      visibleRange: visibleRange,
      padding: styleConfig.padding!,
      top: styleConfig.padding!.top + _chrHeight,
      bottom: rowHeight! - _chrHeight - styleConfig.padding!.bottom,
    );
    maxHeight = rowHeight ?? track!.defaultTrackHeight;
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
      _paint
        ..style = PaintingStyle.fill
        ..color = styleConfig.lineColor!.withOpacity(.25),
    );

    if (arcMode) {
      _drawWithArcMode(canvas, size, painterRect);
      checkSelectedItemArc(canvas);
    } else {
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
      _drawWithLineMode(canvas, size, painterRect);
      checkSelectedItem(canvas);
    }
  }

  _drawWithLineMode(Canvas canvas, Size size, Rect painterRect) {
    Color _color;

    /// 增加绘制速度，把颜色分层100个梯度，同一个梯度加到一个path里面
    Map<String, Path> _areaPathMapByColor = {};
    Map<String, Path> _rangePathMapByColor = {};

    Rect rect1, rect2;
    String colorKey;
    for (InteractiveItem block in trackData.data!) {
      // _color = interceptSingleColor(styleConfig.lineColor, block.colorValue);
      colorKey = block.colorValue!.toStringAsFixed(1);
      if (_areaPathMapByColor[colorKey] == null) _areaPathMapByColor[colorKey] = Path();
      _areaPathMapByColor[colorKey]!.addPath(block.path!, Offset.zero);

      // canvas.drawPath(block.path, _blockPaint);

      if (_rangePathMapByColor[colorKey] == null) _rangePathMapByColor[colorKey] = Path();
      rect1 = Rect.fromLTWH(
        block.uiRange1!.start,
        painterRect.top,
        max(block.uiRange1!.size, 1.0),
        _chrHeight,
      );
      _rangePathMapByColor[colorKey]!.addRect(rect1);
      // canvas.drawRect(rect1, _blockPaint);

      rect2 = Rect.fromLTWH(
        block.uiRange2!.start,
        painterRect.bottom - _chrHeight,
        max(block.uiRange2!.size, 1.0),
        _chrHeight,
      );
      _rangePathMapByColor[colorKey]!.addRect(rect2);
      // canvas.drawRect(rect2, _blockPaint);
    }

    _blockPaint.style = PaintingStyle.fill;
    for (MapEntry<String, Path> entry in _rangePathMapByColor.entries) {
      _color = styleConfig.lineColor!.withOpacity(double.parse(entry.key));
      _blockPaint..color = _color;
      canvas.drawPath(_areaPathMapByColor[entry.key]!, _blockPaint);

      featurePaint..color = _color;
      canvas.drawPath(entry.value, featurePaint);
    }
  }

  _drawWithArcMode(Canvas canvas, Size size, Rect painterRect) {
    Color _color;
    // Path path;
    Rect rect1, rect2;
    canvas.clipRect(painterRect);

    _blockPaint.style = PaintingStyle.stroke;

    /// 增加绘制速度，把颜色分层10个梯度，同一个梯度加到一个path里面
    Map<String, Path> _arcPathMapByColor = {};
    Map<String, Path> _rangePathMapByColor = {};

    String colorKey;
    for (InteractiveItem block in trackData.data!) {
      // _color = interceptSingleColor(styleConfig.lineColor, block.colorValue);
      _color = styleConfig.lineColor!.withOpacity(block.colorValue!);
      // path = block.getPath(painterRect.top + _chrHeight, painterRect.bottom - _chrHeight);

      colorKey = block.colorValue!.toStringAsFixed(1);

      // canvas.drawPath(block.arcPath!, _blockPaint..color = _color);
      if (block.arcRect!.left >= painterRect.left - 500 && block.arcRect!.right <= painterRect.right + 500) {
        canvas.drawPath(block.arcPath!, _blockPaint..color = _color);
      } else {
        if (_arcPathMapByColor[colorKey] == null) _arcPathMapByColor[colorKey] = Path();
        _arcPathMapByColor[colorKey]!
          // ..addRect(block.arcRect!);
          // ..moveTo(block.arcRect!.left, block.arcRect!.top)
          // ..conicTo(block.arcRect!.center.dx, block.arcRect!.bottom, block.arcRect!.right, block.arcRect!.top, 1.0);
          // ..moveTo(block.arcRect!.left, block.arcRect!.top)
          // ..extendWithPath(block.arcPath!, Offset.zero);
          ..addPath(block.arcPath!, Offset.zero);
      }

      // rect1 = Rect.fromLTWH(
      //   block.uiRange1!.start,
      //   painterRect.top,
      //   max(block.uiRange1!.size, 1.5),
      //   _chrHeight,
      // );
      // if (_rangePathMapByColor[colorKey] == null) _rangePathMapByColor[colorKey] = Path();
      // _rangePathMapByColor[colorKey]!.addRect(rect1);
      //
      // // canvas.drawRect(rect1, _blockPaint..style = PaintingStyle.fill);
      // if (block.range1 == block.range2) continue;
      // rect2 = Rect.fromLTWH(
      //   block.uiRange2!.start,
      //   painterRect.top,
      //   max(block.uiRange2!.size, 1.5),
      //   _chrHeight,
      // );
      // _rangePathMapByColor[colorKey]!.addRect(rect2);
      //canvas.drawRect(rect2, _blockPaint);
    }

    _blockPaint
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // featurePaint..style = PaintingStyle.fill;
    for (MapEntry<String, Path> entry in _arcPathMapByColor.entries) {
      _color = styleConfig.lineColor!.withOpacity(double.parse(entry.key));
      _blockPaint..color = _color;
      canvas.drawPath(entry.value, _blockPaint);

      // featurePaint..color = _color;
      // canvas.drawPath(_rangePathMapByColor[entry.key]!, featurePaint);
    }
  }

  checkSelectedItemArc(Canvas canvas) {
    if (null == selectedItem) return;
    InteractiveItem _selected = selectedItem;
    _selectedPaint
      ..strokeWidth = 2.5
      ..color = styleConfig.selectedColor!.withOpacity(_selected.colorValue ?? 1.0)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(_selected.arcPath!, _selectedPaint);

    canvas.drawRect(
      Rect.fromLTRB(
        _selected.uiRange1!.start,
        painterRect.top,
        _selected.uiRange1!.end,
        painterRect.top + _chrHeight,
      ),
      _selectedPaint..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        _selected.uiRange2!.start,
        painterRect.top,
        _selected.uiRange2!.end,
        painterRect.top + _chrHeight,
      ),
      _selectedPaint,
    );
    Rect _bounds = _selected.arcPath!.getBounds();
    var toolTip = 'name  : ${_selected.name ?? ''}\nrange1: ${_selected.range1.print()}\nrange2: ${_selected.range2.print()}\nscore : ${_selected.value}';
    drawTooltip(canvas, toolTip, _bounds.center, _bgPaint);
  }

  checkSelectedItem(Canvas canvas) {
    //logger.d('selected item ${selectedItem?.hashCode}');
    if (null == selectedItem) return;
    InteractiveItem _selected = selectedItem;
    // Path _path = _selected.getPath(painterRect.top + _chrHeight, painterRect.bottom - _chrHeight);
    _selectedPaint
      ..color = styleConfig.selectedColor
      ..style = _selected.needClose ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawPath(_selected.path!, _selectedPaint);
    canvas.drawRect(
      Rect.fromLTRB(
        _selected.uiRange1!.start,
        painterRect.top,
        _selected.uiRange1!.end,
        painterRect.top + _chrHeight,
      ),
      _selectedPaint,
    );

    canvas.drawRect(
      Rect.fromLTRB(
        _selected.uiRange2!.start,
        painterRect.bottom - _chrHeight,
        _selected.uiRange2!.end,
        painterRect.bottom,
      ),
      _selectedPaint,
    );
    Rect _bounds = _selected.path!.getBounds();
    var toolTip = 'name  : ${_selected.name ?? ''}\nrange1: ${_selected.range1.print()}\nrange2: ${_selected.range2.print()}\nscore : ${_selected.value}';
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
    InteractiveItem? find;
    if (arcMode) {
      Iterable<InteractiveItem> finds = trackData.data!.where(
        (b) => b.arcPath!.contains(position) ?? false,
      );
      if (finds.length == 0) {
        hitItem = null;
        return hitItem;
      }
      find = finds.minBy((e) => e.arcPath!.getBounds().width);
    } else {
      Iterable<InteractiveItem> finds = trackData.data!.where(
        (b) => b.areaPath!.contains(position) ?? false,
      );
      if (finds.length == 0) {
        hitItem = null;
        return hitItem;
      }
      find = finds.minBy((f) {
        var intersection = Path.combine(
            PathOperation.intersect,
            f.areaPath!,
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
    }
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
    RelationTrackPainter _painter = painter as RelationTrackPainter;
    bool changed = super.painterChanged(painter) || //
        _painter.visibleRange != visibleRange ||
        painter.rowHeight != _painter.rowHeight;
    return changed;
  }
}
