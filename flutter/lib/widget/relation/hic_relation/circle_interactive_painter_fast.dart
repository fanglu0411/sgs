import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/d3/color/schemes.dart';
import 'package:flutter_smart_genome/widget/track/base/base_painter.dart';

import 'dart:math' show pi, sin, cos, max;

import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';

import 'package:dartx/dartx.dart' as dx;

class CircleInteractivePainterFast extends BasePainter {
  CircleInteractivePainterFast({
    required this.primaryChr,
    required this.interactions,
    this.rangeValues,
    this.selectedChrList,
  }) {
    _paint = Paint()..style = PaintingStyle.stroke;
    _linePaint = Paint()..style = PaintingStyle.stroke;
    totalLength = [primaryChr, ...interactions.keys].sumBy((e) => e.size);
    colors = schemeRainbow(interactions.length + 1, v: .8);
    _maxCount = interactions.values.max()!;
  }

  late num _maxCount;
  late double totalLength;
  RangeValues? rangeValues;
  List<String>? selectedChrList;

  ChromosomeData primaryChr;
  Map<ChromosomeData, int> interactions;

  late Paint _paint;
  late Paint _linePaint;
  late List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    _paint
      ..strokeWidth = 15
      ..color = Colors.red;
    _linePaint
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = Colors.red;

    double _startAngle = 0; //-pi / 2;
    double swipeAngle;

    int i = 0;
    for (ChromosomeData chr in [primaryChr, ...interactions.keys]) {
      swipeAngle = (chr.size / totalLength) * (pi * 2);
      _paint.color = colors[i];
      canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), _startAngle, swipeAngle, false, _paint);
      double x = cos(swipeAngle / 2) * size.width;
      double y = sin(swipeAngle / 2) * size.width;
      // drawText(canvas, text: chr.chrName, offset: Offset(x, y), style: TextStyle(color: Colors.red));
      _startAngle += swipeAngle;
      i++;
    }

    _drawChrName(canvas, size);
    _drawInteractions(canvas, size);
  }

  void _drawChrName(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    double _startAngle = 0, swipeAngle;
    int i = 0;
    for (ChromosomeData chr in [primaryChr, ...interactions.keys]) {
      swipeAngle = (chr.size / totalLength) * (pi * 2);
      canvas.save();
      canvas.rotate((.5 * pi + _startAngle + swipeAngle / 2));
      drawText(
        canvas,
        text: ' ${chr.chrName} ',
        offset: Offset(0, -size.height / 2 - 30),
        textAlign: TextAlign.center,
        width: 10,
        style: TextStyle(
          color: colors[i],
          fontSize: 20,
          fontFamily: MONOSPACED_FONT,
          fontWeight: FontWeight.bold,
          backgroundColor: chr.id == primaryChr.id ? Colors.grey : null,
        ),
      );
      canvas.restore();
      _startAngle += swipeAngle;
      i++;
    }
    canvas.restore();
  }

  void _drawInteractions(Canvas canvas, Size size) {
    double _start = primaryChr.range.size, startAngle = 0, angle2;
    double r = size.width / 2;
    int i = 0;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    interactions.forEach((chr, count) {
      if (selectedChrList != null && !selectedChrList!.contains(chr.id)) {
        i++;
        _start += chr.size;
        return;
      }
      Path path = Path();

      var _primaryStartAngle = angle(0);
      var _primarySwipeAngle = angle(primaryChr.range.end);
      var _primaryEndAngle = angle(primaryChr.range.end);

      var _secondaryStartAngle = angle(_start);
      var _secondaryEndAngle = angle(_start + chr.range.size);
      var _secondarySwipeAngle = angle(chr.range.size);

      // path
      //   ..moveTo(cos(_primaryStartAngle) * r, sin(_primaryStartAngle) * r)
      //   ..arcTo(Rect.fromLTWH(0, 0, size.width, size.height).translate(-size.width / 2, -size.height / 2), _primaryStartAngle, _primarySwipeAngle, false)
      //   ..conicTo(0, 0, cos(_secondaryStartAngle) * r, sin(_secondaryStartAngle) * r, .8)
      //   ..arcTo(Rect.fromLTWH(0, 0, size.width, size.height).translate(-size.width / 2, -size.height / 2), _secondaryStartAngle, _secondarySwipeAngle, false)
      //   ..conicTo(0, 0, cos(_primaryStartAngle) * r, sin(_primaryStartAngle) * r, .8)
      //   ..close();

      path
        ..moveTo(cos(angle(primaryChr.range.center)) * r, sin(angle(primaryChr.range.center)) * r)
        ..conicTo(0, 0, cos(angle(_start + chr.range.center)) * r, sin(angle(_start + chr.range.center)) * r, .8);

      canvas.drawPath(
          path,
          _linePaint
            // ..style = PaintingStyle.fill
            ..strokeWidth = 20
            ..color = colors[i + 1].withOpacity(max(count / _maxCount, .05)));
      i++;
      _start += chr.size;
    });
    canvas.restore();
  }

  double angle(num start) {
    return (start / totalLength) * (pi * 2);
  }

  @override
  bool shouldRepaint(covariant CircleInteractivePainterFast oldDelegate) {
    return interactions.length != oldDelegate.interactions || interactions != oldDelegate.interactions;
  }
}