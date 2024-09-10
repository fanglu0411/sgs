import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'package:flutter_smart_genome/mixin/text_painter_mixin.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/scatter_front_controller.dart';

class PointAxisPainter extends CustomPainter with TextPainterMixin {
  Vector3LinearScale scale;

  Rect yAxisRect;
  Rect xAxisRect;

  Paint? _paint;
  Brightness brightness;
  Color primaryColor;

  late ScatterFrontController controller;

  bool _dirty = true;

  PointAxisPainter({
    required this.controller,
    required this.scale,
    required this.xAxisRect,
    required this.yAxisRect,
    required this.primaryColor,
    this.brightness = Brightness.light,
  }) : super(repaint: controller) {
    controller.addListener(() {
      _dirty = true;
    });
    _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.red;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawRect(
    //     Rect.fromLTWH(0, 0, size.width, size.height),
    //     _paint!
    //       ..style = PaintingStyle.fill
    //       ..color = Colors.transparent);

    drawAxis(canvas);
    drawSelectedArea(canvas);
    drawSelectedCells(canvas);
    // drawCursor(canvas);
    drawFocusCluster(canvas);
    drawCluster(canvas, controller.linkedCluster?.position, controller.linkedCluster?.text, controller.tapedClusterColor);

    _dirty = false;
    // _hover = courserValue.value.transformInvert(matrix4);
  }

  void drawCursor(Canvas canvas) {
    if (controller.cursor == null || null != controller.drawingPath) {
      return;
    }
    Offset _hover = controller.cursor!;
    double courserSize = 10;
    Path hoverPath = Path();
    hoverPath
      ..moveTo(_hover.dx - courserSize, _hover.dy)
      ..lineTo(_hover.dx + courserSize, _hover.dy)
      ..moveTo(_hover.dx, _hover.dy - courserSize)
      ..lineTo(_hover.dx, _hover.dy + courserSize);
    canvas.drawPath(
        hoverPath,
        _paint!
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    canvas.drawCircle(_hover, 5, _paint!);
  }

  void drawSelectedArea(Canvas canvas) {
    if (null != controller.drawingPath) {
      canvas.drawPath(controller.drawingPath!, _paint!..strokeWidth = 2);
    }

    // if (null == controller.selectedRect) {
    //   return;
    // }
    // canvas.drawRect(
    //     controller.selectedRect!,
    //     _paint!
    //       ..color = Colors.black54
    //       ..strokeWidth = 1.0
    //       ..strokeMiterLimit = 10.0
    //       ..style = PaintingStyle.stroke);
  }

  void drawFocusCluster(Canvas canvas) {
    if (controller.tapedCluster == null || null == controller.cursor) {
      return;
    }
    var offset = controller.cursor! + Offset(20, 4);
    drawTextSpan(
      canvas,
      text: TextSpan(
        text: controller.tapedCluster,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          // fontFamily: MONOSPACED_FONT,
          // fontFamilyFallback: MONOSPACED_FONT_BACK,
        ),
      ),
      offset: offset,
      backgroundPainter: (double width, double height) {
        var rect = RRect.fromRectAndRadius(Rect.fromLTWH(offset.dx, offset.dy, width, height).inflateXY(10, 6), Radius.circular(4));
        canvas.drawRRect(
          rect,
          Paint()..color = controller.tapedClusterColor ?? Colors.black.withOpacity(.5),
        );
        canvas.drawRRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = brightness == Brightness.dark ? Colors.white : Colors.black12,
        );
      },
    );
  }

  void drawCluster(Canvas canvas, Point? position, String? cluster, Color? color) {
    if (cluster == null || null == position) {
      return;
    }

    canvas.save();
    canvas.transform(controller.matrix.storage);

    Offset offset = Offset(position.x.toDouble(), position.y.toDouble());
    drawTextSpan(
      canvas,
      text: TextSpan(
        text: cluster,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16 / controller.matrix.getMaxScaleOnAxis(),
          // fontFamily: MONOSPACED_FONT,
          // fontFamilyFallback: MONOSPACED_FONT_BACK,
        ),
      ),
      offset: offset,
      backgroundPainter: (double width, double height) {
        var rect = RRect.fromRectAndRadius(Rect.fromLTWH(offset.dx, offset.dy, width, height).inflateXY(10, 6), Radius.circular(4));
        canvas.drawRRect(
          rect,
          Paint()..color = color ?? Colors.black.withOpacity(.5),
        );
        canvas.drawRRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = brightness == Brightness.dark ? Colors.white : Colors.black54,
        );
      },
    );
    canvas.restore();
  }

  void drawSelectedCells(Canvas canvas) {
    if (controller.selectedPoints == null || controller.selectedPoints!.length == 0) return;
    canvas.save();

    canvas.transform(controller.matrix.storage);
    _paint!
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = controller.currentPointSize;
    for (var entry in controller.selectedPoints!.entries) {
      canvas.drawRawPoints(PointMode.points, entry.value, _paint!);
    }
    canvas.restore();
  }

  void drawAxis(Canvas canvas) {
    if (!controller.showAxis) {
      return;
    }
    canvas.save();
    // canvas.transform(matrix.storage);

    Matrix4 matrix = controller.matrix;

    bool _dark = brightness == Brightness.dark;
    Color textColor = _dark ? Colors.white54 : Colors.black38;
    Color backgroundColor = _dark ? Colors.grey[800]! : Colors.grey[100]!.withOpacity(.75);
    _paint!
      ..style = PaintingStyle.stroke
      ..color = backgroundColor;
    // canvas.drawRect(xAxisRect, _paint);
    // canvas.drawRect(yAxisRect, _paint);

    canvas.drawLine(xAxisRect.bottomLeft, xAxisRect.bottomRight, _paint!..color = textColor);
    canvas.drawLine(yAxisRect.topLeft, yAxisRect.bottomLeft + Offset(0, xAxisRect.height), _paint!..color = textColor);

    var yDomain = scale.yScale.domain;

    double maxScale = matrix.getMaxScaleOnAxis();

    double delta = maxScale > 2 ? maxScale % 2 : 0;

    int tickerCount = 5 * (maxScale - delta).toInt();

    double tickSize = (scale.yScale.domainWidth + 1) / tickerCount;
    Offset _tickPoint;
    var yStart = scale.yScale.domainMin;
    for (int i = 1; i <= tickerCount; i++) {
      yStart = scale.yScale.domainMin + i * tickSize;
      if (yStart > scale.yScale.domainMax) break;
      _tickPoint = Offset(yAxisRect.left, yAxisRect.bottom - scale.yScale.scale(yStart)!);
      var _transTickPoint = _tickPoint.transform(matrix);
      Offset __tickY = Offset(_tickPoint.dx, _transTickPoint.dy); // + yAxisRect.topLeft;
      if (!yAxisRect.inflate(1).contains(__tickY)) continue;

      canvas.drawLine(__tickY, __tickY + Offset(4, 0), _paint!..color = textColor);
      drawText(
        canvas,
        text: '${yStart.toStringAsFixed(0)}',
        offset: __tickY + Offset(4, -6),
        textAlign: TextAlign.start,
        width: 40,
        style: TextStyle(fontSize: 10, color: textColor),
      );
    }

    var xDomain = scale.xScale.domain;
    tickSize = scale.xScale.domainWidth / tickerCount;
    var xStart = scale.xScale.domainMin;
    for (int i = 1; i <= tickerCount; i++) {
      xStart = scale.xScale.domainMin + i * tickSize;
      if (xStart > scale.xScale.domainMax) break;
      _tickPoint = Offset(scale.xScale.scale(xStart)!.toDouble(), 0);
      var _transTickPoint = _tickPoint.transform(matrix);
      Offset __tickX = Offset(_transTickPoint.dx, _tickPoint.dy) + xAxisRect.bottomLeft;
      if (!xAxisRect.inflate(1).contains(__tickX)) continue;

      canvas.drawLine(__tickX, __tickX + Offset(0, -4), _paint!..color = textColor);
      drawText(
        canvas,
        text: '${xStart.toStringAsFixed(0)}',
        offset: __tickX + Offset(-20, -15),
        width: 40,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: textColor),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PointAxisPainter oldDelegate) {
    return _dirty;
    return this.scale != oldDelegate.scale;
  }
}
