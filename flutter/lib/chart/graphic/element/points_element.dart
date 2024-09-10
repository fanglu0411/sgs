import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class PointsElement extends PrimitiveElement {
  Float32List points;

  late Paint _paint;

  PointsElement({required this.points, required super.style}) {
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = style.strokeWidth ?? 4
      ..color = style.strokeColor ?? style.fillColor!;
  }

  @override
  void drawPath(Path path) {}

  @override
  void draw(Canvas canvas) {
    super.draw(canvas);
    canvas.drawRawPoints(PointMode.points, points, _paint);
  }

  @override
  PointsElement lerpFrom(covariant PointsElement from, double t) {
    return PointsElement(points: points, style: style.lerpFrom(from.style, t));
  }

  @override
  List<Segment> toSegments() {
    return [];
  }
}