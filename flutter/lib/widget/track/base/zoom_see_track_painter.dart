import 'dart:ui';
import 'dart:math' as math;
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class ZoomSeeTrackPainter extends AbstractTrackPainter {
  late Paint _paint;
  late TextStyle style;
  Color? background;
  late String message;

  ZoomSeeTrackPainter({
    Axis? orientation,
    required ScaleLinear<num> scale,
    required Range visibleRange,
    this.background,
    this.message = 'Zoom in to view sequence',
    this.style = const TextStyle(fontSize: 18, fontWeight: FontWeight.w200),
    double height = 30,
  }) : super(orientation: orientation, trackData: BaseTrackData(), scale: scale, visibleRange: visibleRange, styleConfig: StyleConfig()) {
    _paint = Paint()..color = Colors.green;
    maxHeight = height;
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    return false;
    // return super.onEmptyPaint(canvas, size);
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    if (background != null) {
      canvas.drawRect(rect, _paint..color = background!);
    }

    if (orientation == Axis.vertical) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(-math.pi / 2);
      drawText(
        canvas,
        text: message,
        style: style,
        textAlign: TextAlign.center,
        width: size.height,
        offset: Offset(-size.height / 2, 0),
      );
      canvas.restore();
    } else {
      drawText(
        canvas,
        text: message,
        style: style,
        textAlign: TextAlign.center,
        width: size.width,
        offset: Offset(0, size.height / 2 - 8),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
