import 'package:flutter/material.dart';

typedef void TextBackgroundPainter(double width, double height);

mixin TextPainterMixin on CustomPainter {
  double measureText({required String text, TextStyle? style}) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
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
    TextDirection textDirection = TextDirection.ltr,
    double width = 10,
    TextBackgroundPainter? backgroundPainter,
  }) {
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
    TextDirection textDirection = TextDirection.ltr,
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
    if (textAlign == TextAlign.center && width < labelPainter.width) {
      offset -= Offset((labelPainter.width - width) / 2, 0);
    }
    labelPainter.paint(canvas, offset);
  }
}
