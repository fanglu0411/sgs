import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/cell/point_data_matrix.dart';
import 'package:flutter_smart_genome/chart/base/chart_theme.dart';
import 'package:flutter_smart_genome/chart/painter/point_painter.dart';
import 'package:flutter_smart_genome/chart/scale/vector_scale_ext.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:flutter_smart_genome/mixin/text_painter_mixin.dart';
import 'package:vector_math/vector_math_64.dart' show Quad, Vector3, Matrix4;
import 'package:flutter_smart_genome/extensions/rect_extension.dart';

class CellPointPainter extends PointPainter with TextPainterMixin {
  CellPointPainter({
    // PointSeries<dynamic, dynamic> series,
    required ChartTheme theme,
    EdgeInsets? seriesPadding,
    ValueNotifier<Offset>? courserValue,
    required this.matrix4,
    required this.matrixData,
    required this.scale,
    this.interacting = false,
    this.selectedRect,
    this.plotImage,
    this.maxScale,
  }) : super(
          theme: theme,
          seriesPadding: seriesPadding,
          // series: series,
          courserValue: courserValue,
        ) {
    _paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    _selectedPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5;
  }

  double? maxScale;
  bool interacting;
  DensityCords<List>? matrixData;
  Vector3LinearScale scale;
  Matrix4 matrix4;
  Rect? selectedRect;
  Paint? _paint;
  Paint? _selectedPaint;
  Offset? _hover;
  double? _radius;
  double MIN_RADIUS = 1;
  double MAX_RADIUS = 5;

  double MIN_SELECTED_STROKE_WIDTH = 1;
  double MAX_SELECTED_STROKE_WIDTH = 2.5;

  double? _selectedStrokeWidth;

  Rect? _domainRect;
  Rect? _selectedDomainRect;

  ui.Image? plotImage;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
  }

  @override
  renderChartSeries(Canvas canvas, Rect rect) {
    if (matrixData == null) return;
    canvas.drawRect(rect, _paint!..color = theme.backgroundColor);
    canvas.save();
    canvas.transform(matrix4.storage);
    Rect _rect = rect.translate(-rect.left, -rect.top).transform(matrix4);
    _drawPoints(canvas, _rect, rect);
    canvas.restore();
    // if (null != plotImage) {
    //   canvas.drawImage(plotImage, Offset.zero, _paint);
    // }

    if (null != selectedRect) {
      canvas.drawRect(
          selectedRect!,
          _paint!
            ..color = Colors.black54
            ..strokeWidth = .5
            ..strokeMiterLimit = 10.0
            ..style = PaintingStyle.stroke);
    }

    // if (courserValue != null) {
    //   Offset _hover = courserValue.value;
    //   double courserSize = 20;
    //   Path hoverPath = Path();
    //   hoverPath
    //     ..moveTo(_hover.dx - courserSize, _hover.dy)
    //     ..lineTo(_hover.dx + courserSize, _hover.dy)
    //     ..moveTo(_hover.dx, _hover.dy - courserSize)
    //     ..lineTo(_hover.dx, _hover.dy + courserSize);
    //   canvas.drawPath(
    //       hoverPath,
    //       _paint
    //         ..color = Colors.red
    //         ..style = PaintingStyle.stroke
    //         ..strokeWidth = 1.0);
    //   canvas.drawCircle(_hover, 10, _paint);
    // }
  }

  Offset? _delta;

  void _drawPoints(Canvas canvas, Rect targetRect, Rect canvasRect) {
    _domainRect = scale.revertRect(targetRect); // Rect.fromLTRB(domainLeftTop.x, domainLeftTop.y, domainBottomRight.x, domainBottomRight.y);
    _selectedDomainRect = null == selectedRect ? null : scale.revertRect(selectedRect!.transform(matrix4));
    // matrixData.transform(_domainRect);

    double _scale = matrix4.getMaxScaleOnAxis();
    _hover = courserValue!.value.transformInvert(matrix4);

    _radius = (MIN_RADIUS + (_scale - 1) / (maxScale! - 1) * (MAX_RADIUS - MIN_RADIUS)) / _scale;
    _selectedStrokeWidth = (MIN_SELECTED_STROKE_WIDTH + (_scale - 1) / (maxScale! - 1) * (MAX_SELECTED_STROKE_WIDTH - MIN_SELECTED_STROKE_WIDTH)) / _scale;
    // print('_radius: ${_radius}');

    Size blockSize = Size(canvasRect.width / matrixData!.divisions!.x * matrixData!.mergeBlocks, canvasRect.height / matrixData!.divisions!.y * matrixData!.mergeBlocks);

    if (matrixData!.mergeBlocks > 1) {
      matrixData!.forEach((GridCord cord, CordBlock block, int row, int col) {
        if (block.count == 0) return;
        Rect rect = block.getRect(blockSize);
        _paint!..color = cord.blockColor(block, matrixData!.getGroupColor(cord.name));
        canvas.drawRect(rect, _paint!);
      });
    } else {
      matrixData!.forEach((GridCord cord, CordBlock block, int row, int col) {
        // Rect rect = block.getRect(blockSize);
        if (block.count == 0) return;
        _paint!..color = cord.blockColor(block, matrixData!.getGroupColor(cord.name));
        _drawPointBlock(canvas, block, _scale, matrixData!.getGroupColor(cord.name));
        // print('rect width: ${rect.width * _scale}, $rect');
      });
    }
    // matrixData.forEach((CordBlock block, int row, int col) {
    //   if (block.count == 0) return;
    //   Rect rect = block.getRect(blockSize);
    //   _paint..color = matrixData.blockColor(block);
    //   count += block.count;
    //   if (block.isEmpty) {
    //     canvas.drawRect(rect, _paint);
    //   } else {
    //     _drawPointBlock(canvas, block, _scale);
    //   }
    // });
  }

  _drawPointBlock(Canvas canvas, CordBlock block, double _scale, Color color) {
    if (block.isEmpty) return;
    _paint!.style = PaintingStyle.fill;
    Path _unPath = Path();
    _unPath.fillType = PathFillType.evenOdd;

    // block.list.sort(matrixData.sortByColor);
    Offset domainOffset;

    List<Offset> drawdPoints = [];
    block.list!.forEach((item) {
      domainOffset = Offset(matrixData!.xMapper.call(item).toDouble(), matrixData!.yMapper.call(item).toDouble());
      // if (_delta > Offset.zero && drawdPoints.any((o) => (o - domainOffset) <= _delta)) {
      //   return;
      // }
      // drawdPoints.add(domainOffset);
      // Offset point = scale.scaleXY(Point3.xy(domainOffset.dx, domainOffset.dy));
      // drawdPoints.add(point);
      _drawRawPoint(canvas, item, domainOffset, color);
      // _unPath.addOval(rect);
    });

    // canvas.drawPoints(ui.PointMode.points, drawdPoints, _paint..color = Colors.red);

    // canvas.drawPath(_unPath, _paint..color = color);
    // _drawRawPoint(canvas, block.list.first);
  }

  _drawRawPoint(Canvas canvas, List item, Offset domainOffset, Color color) {
    // double x = 0, y = 0;
    // Offset domainOffset = Offset(matrixData.xMapper.call(item), matrixData.yMapper.call(item));
    if (!_domainRect!.contains(domainOffset)) return;
    bool selected = _selectedDomainRect != null && _selectedDomainRect!.contains(domainOffset);
    _drawPoint(canvas, domainOffset, color, selected);
  }

  _drawPoint(Canvas canvas, Offset offset, Color color, bool selected) {
    // Rect rect;
    //这里因为画布已经被painter做了matrix变换，所以只做 value 到 位置映射，不再做matrix变换
    Offset point = scale.scaleOffset(offset);
    // rect = Rect.fromCircle(center: point, radius: _radius);
    // if (null != _hover && rect.contains(_hover)) {
    //   canvas.drawCircle(point, _radius * 2, _paint..color = color);
    // } else {
    // canvas.drawCircle(point, _radius, _paint..color = color);
    // canvas.drawOval(rect, _paint..color = color);
    // }
    _paint!..color = color;
    _selectedPaint!..strokeWidth = _selectedStrokeWidth!;

    if (matrix4.getMaxScaleOnAxis() * _radius! * 2 <= 4) {
      var rect = Rect.fromCircle(center: point, radius: _radius!);
      if (selected) canvas.drawRect(rect, _selectedPaint!);
      canvas.drawRect(rect, _paint!);
    } else {
      if (selected) canvas.drawCircle(point, _radius!, _selectedPaint!);
      canvas.drawCircle(point, _radius!, _paint!);
    }
  }

  @override
  bool shouldRepaint(covariant CellPointPainter oldDelegate) {
    return !interacting;
  }
}
