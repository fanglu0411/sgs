import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// import 'package:flutter_smart_genome/cell/point_data_matrix.dart';
import 'dart:math' as math;
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:flutter_smart_genome/chart/scale/vector_scale_ext.dart';
import 'package:flutter_smart_genome/mixin/text_painter_mixin.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/density_plot_matrix.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/gene_plot_matrix.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'package:flutter_smart_genome/page/cell/quick_scatter/canvas_controller.dart';

class CellPlotChartPainter extends CustomPainter with TextPainterMixin {
  CellPlotChartPainter({
    required this.matrixData,
    this.genePlotData,
    required this.scale,
    this.plotImage,
    required this.maxScale,
    required this.controller,
  }) : super(repaint: controller) {
    controller.addListener(() {
      _dirty = true;
    });
    _paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    _selectedPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5;

    _labelPaint = Paint()..style = PaintingStyle.fill;
  }

  CanvasController controller;

  bool _dirty = true;
  late double maxScale;
  DensityGroupPlotMatrix matrixData;

  // GroupPlotMatrix matrixData;
  GenePlotMatrix? genePlotData;
  Vector3LinearScale scale;

  Paint? _paint;
  Paint? _labelPaint;
  Paint? _selectedPaint;
  Offset? _hover;
  late double _radius;
  double MIN_RADIUS = 1.0;
  double MAX_RADIUS = 6;

  double MIN_SELECTED_STROKE_WIDTH = 1;
  double MAX_SELECTED_STROKE_WIDTH = 2.5;

  double? _selectedStrokeWidth;
  Rect? _domainRect;
  Rect? _selectedDomainRect;

  ui.Image? plotImage;

  @override
  void paint(Canvas canvas, Size size) {
    // print('paint dirty: $_dirty, ${this.hashCode}');
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // canvas.drawRect(rect, _paint..color = theme.backgroundColor);
    // canvas.drawRect(rect, _paint!..color = Colors.red.withOpacity(.2));

    // canvas.clipRect(rect);

    Matrix4 matrix4 = controller.matrix4!;
    _dirty = false;
    canvas.save();

    canvas.transform(matrix4.storage);

    if (null != plotImage) canvas.drawImage(plotImage!, Offset.zero, _paint!);

    Rect _rect = rect.translate(-rect.left, -rect.top).transform(matrix4);

    if (matrixData.enableDensityMode && matrixData.mergeBlockCount > 1) {
      _drawDensityBlocks(canvas, rect);
    } else {
      _drawPoints(canvas, _rect, rect);
    }
    canvas.restore();
  }

  void _drawDensityBlocks(Canvas canvas, Rect canvasRect) {
    _paint!
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Size blockSize = Size(canvasRect.width / matrixData.divisions.x * matrixData.mergeBlocks, canvasRect.height / matrixData.divisions.y * matrixData.mergeBlocks);
    // matrixData.forEach((cord, block) {
    //   if (block.count == 0) return;
    //   Rect rect = block.getRect(blockSize);
    //   // _paint..color = matrixData.groupChecked(cord.name) ? cord.blockColor(block, matrixData.getGroupColor(cord.name)) : matrixData.getGroupColor(cord.name);
    //   _paint..color = cord.blockColor(block, Colors.red);
    //   canvas.drawRect(rect, _paint);
    // });
    List<String> _groups = controller.orderedGroup;
    for (var group in _groups) {
      _paint!
        ..color = controller.getGroupColor(group, controller.pointOpacity).withOpacity(.55)
        ..blendMode = BlendMode.srcOver;
      canvas.drawPath(matrixData.groupPath![group]!, _paint!);
    }
    // canvas.drawPath(matrixData.totalPath, _paint..color = Colors.red);
  }

  void _drawPoints(Canvas canvas, Rect targetRect, Rect canvasRect) {
    // canvas.drawRect(canvasRect, _paint!..color = Colors.red.withOpacity(.2));
    Matrix4 matrix4 = controller.matrix4!;
    // _domainRect = scale.revertRect(targetRect);
    _selectedDomainRect = null == controller.selectedRect ? null : scale.revertRect(controller.selectedRect!.transform(matrix4));

    double _scale = controller.matrix4!.getMaxScaleOnAxis();
    // _hover = courserValue!.value.transformInvert(matrix4);
    // _radius = (controller.pointSize + (_scale - 1) / (maxScale - 1) * 10) / _scale;
    _radius = controller.currentPointSize;
    _selectedStrokeWidth = (MIN_SELECTED_STROKE_WIDTH + (_scale - 1) / (maxScale - 1) * (MAX_SELECTED_STROKE_WIDTH - MIN_SELECTED_STROKE_WIDTH)) / _scale;

    Color? _color = genePlotData == null ? null : genePlotData!.legends?.first.showColor ?? Colors.grey[300];
    List<String> _groups = controller.orderedGroup;

    // var _start = DateTime.now();
    _paint!
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = _radius;

    int count = 0;
    double percent;
    for (var group in _groups) {
      // if (controller.interacting! && i > 10) return;
      // Path path = matrixData.groupPath[group];
      // if (path == null) return;
      if (genePlotData == null) _color = controller.getGroupColor(group, controller.pointOpacity);
      // canvas.drawPath(path, _paint..color = _color);
      Float32List? originList = matrixData.groupCords[group];

      if (originList == null) return;
      percent = originList.length / 2 / matrixData.cellCount;
      if (controller.maxDrawCount != null) originList = originList.sublist(0, math.min(2 * (controller.maxDrawCount! * percent).toInt(), originList.length));
      // Float32List list = originList.sublist(0, math.min(avgDrawCount, originList.length));
      count += originList.length;
      canvas.drawRawPoints(
        ui.PointMode.points,
        controller.interacting! ? originList.sublist(0, math.min(2 * (50000 * percent).toInt(), originList.length)) : originList,
        _paint!..color = _color!,
      );
      // var ps = matrixData.groupCords[group]!.expand((e) => [e, e, e]).toList();

      // var colors = List.filled(matrixData.groupCords[group]!.length * 3, _color!);
      // var _colors = Int32List.fromList(List.filled(ps.length ~/ 2, _color!.value));
      // canvas.drawVertices(ui.Vertices.raw(VertexMode.triangles, Float32List.fromList(ps), colors: _colors), BlendMode.src, _paint!);
      // canvas.drawVertices(ui.Vertices.raw(VertexMode.triangles, matrixData.groupCords[group]!, colors: Int32List.fromList(List.filled(matrixData.groupCords[group]!.length ~/ 2, _color!.value))), BlendMode.srcOver, _paint!);
    }
    // print('count:${count / 2}, ${controller.maxDrawCount}');

    // _end = DateTime.now();
    // print('draw cords: ${(_end.millisecondsSinceEpoch - _start.millisecondsSinceEpoch)}');
    genePlotData?.transformAndDraw(canvas, _paint!, targetRect, _radius / 2);
  }

  Int32List _encodeColorList(List<Color> colors) {
    final int colorCount = colors.length;
    final Int32List result = Int32List(colorCount);
    for (int i = 0; i < colorCount; ++i) {
      result[i] = colors[i].value;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CellPlotChartPainter oldDelegate) {
    // print('shouldRepaint: ${_dirty}');
    return _dirty;
    return matrixData != oldDelegate.matrixData || //
        genePlotData != oldDelegate.genePlotData;
  }
}
