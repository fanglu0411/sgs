import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';

class EmptyTrackPainter extends AbstractTrackPainter {
  late Paint _paint;

  LinearGradient? gradient;
  late Brightness brightness;

  String label;

  EmptyTrackPainter({
    Axis? orientation,
    required super.scale,
    required super.visibleRange,
    this.label = 'Track Loading ...',
    this.brightness = Brightness.light,
    super.maxHeight = 30,
  }) : super(trackData: BaseTrackData(), styleConfig: StyleConfig()) {
    _paint = Paint()
      ..color = Colors.lightBlue[50]!;

    maxHeight = 80;
  }

  @override
  bool onEmptyPaint(Canvas canvas, Size size) {
    return false;
    // return super.onEmptyPaint(canvas, size);
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
//    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _paint);

    if (orientation == Axis.vertical) {
//      Rect _rect = Rect.fromCenter(center: rect.center, width: size.width / 2, height: size.height);
//      _paint..shader = gradient.createShader(_rect);
//      canvas.drawRRect(RRect.fromRectAndRadius(_rect, Radius.circular(5)), _paint);
//      canvas.drawRect(rect, _paint);

      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(-math.pi / 2);
      drawText(
        canvas,
        text: '${label}',
        style: TextStyle(fontSize: 14, color: Brightness.dark == brightness ? Colors.white70 : Colors.black54),
        textAlign: TextAlign.center,
        width: size.height,
        offset: Offset(-size.height / 2, 0),
      );
      canvas.restore();
    } else {
      Rect _rect = Rect.fromCenter(center: rect.center, width: rect.width, height: rect.height / 2);
//      _paint..shader = gradient.createShader(_rect);
//      canvas.drawRRect(RRect.fromRectAndRadius(_rect, Radius.circular(5)), _paint);
//      canvas.drawRect(rect, _paint);
      drawText(
        canvas,
        text: '${label}',
        style: TextStyle(fontSize: 14, color: Brightness.dark == brightness ? Colors.white70 : Colors.black54),
        offset: Offset(0, (size.height) / 2 - 8),
        textAlign: TextAlign.center,
        width: size.width,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is EmptyTrackPainter) {
      return oldDelegate.orientation != orientation;
    }
    return false;
  }
}