import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/mixin/text_painter_mixin.dart';

abstract class BasePainter extends CustomPainter {
  double measureText({required String text, required TextStyle style}) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.start,
    )..layout();
    return textPainter.width;
  }

  void drawText(
    Canvas canvas, {
    required String text,
    Offset offset = Offset.zero,
    TextStyle style = const TextStyle(),
    TextAlign textAlign = TextAlign.start,
    ui.TextDirection textDirection = ui.TextDirection.ltr,
    double width = 10,
    TextBackgroundPainter? backgroundPainter,
  }) {
    if (offset.dx.isNaN || offset.dy.isNaN) return;
    drawTextSpan(
      canvas,
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: textDirection,
      width: width,
      offset: offset,
      backgroundPainter: backgroundPainter,
    );
  }

  void drawTextSpan(
    Canvas canvas, {
    required TextSpan text,
    Offset offset = Offset.zero,
    TextAlign textAlign = TextAlign.start,
    ui.TextDirection textDirection = ui.TextDirection.ltr,
    double width = 10,
    TextBackgroundPainter? backgroundPainter,
  }) {
    TextPainter labelPainter = TextPainter(
      text: text,
      textAlign: textAlign,
      textDirection: textDirection,
    );
    labelPainter.layout(minWidth: width, maxWidth: double.infinity);
    if (backgroundPainter != null) {
      double _width = labelPainter.width;
      double _height = labelPainter.height;
      backgroundPainter.call(_width, _height);
    }
    if (textAlign == TextAlign.right || textAlign == TextAlign.end) {
      offset -= Offset((labelPainter.width), 0);
    }
    labelPainter.paint(canvas, offset);
  }
}
