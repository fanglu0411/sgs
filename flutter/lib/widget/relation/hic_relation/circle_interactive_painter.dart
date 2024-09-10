import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/d3/color/schemes.dart';
import 'package:flutter_smart_genome/widget/relation/hic_relation/interactive_data.dart';
import 'package:flutter_smart_genome/widget/track/base/base_painter.dart';

import 'dart:math' show pi, sin, cos;

import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';

import 'package:dartx/dartx.dart' as dx;

class CircleInteractivePainter extends BasePainter {
  CircleInteractivePainter({
    required this.primaryChr,
    required this.interactions,
    required this.rangeValues,
    this.selectedChrList,
  }) {
    _paint = Paint()..style = PaintingStyle.stroke;
    _linePaint = Paint()..style = PaintingStyle.stroke;
    totalLength = [primaryChr, ...interactions.keys].sumBy((e) => e.size);
    colors = schemeRainbow(interactions.length + 1, v: .8);
  }

  late double totalLength;
  RangeValues rangeValues;
  List<String>? selectedChrList;

  ChromosomeData primaryChr;
  Map<ChromosomeData, List<InteractiveItem>> interactions;

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
    double _start = primaryChr.range.size, startAngle = 0, _start2, angle2;
    double r = size.width / 2;
    int i = 0;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    interactions.forEach((chr, _interactions) {
      if (selectedChrList != null && !selectedChrList!.contains(chr.id)) {
        i++;
        _start += chr.size;
        return;
      }
      Path path = Path();

      for (InteractiveItem item in _interactions) {
        if (item.value < rangeValues.start || item.value > rangeValues.end) continue;

        startAngle = angle(item.range1.center as double);
        angle2 = angle(_start + item.range2.center);
        path
              ..moveTo(cos(startAngle) * r, sin(startAngle) * r)
              // ..lineTo(0, 0)
              ..conicTo(0, 0, cos(angle2) * r, sin(angle2) * r, .8)
            // ..lineTo(cos(angle2) * r, sin(angle2) * r);
            ;
      }
      canvas.drawPath(path, _linePaint..color = colors[i + 1].withOpacity(.3));

      i++;
      _start += chr.size;
    });
    canvas.restore();
  }

  double angle(double start) {
    return (start / totalLength) * (pi * 2);
  }

  @override
  bool shouldRepaint(covariant CircleInteractivePainter oldDelegate) {
    return interactions.length != oldDelegate.interactions || interactions != oldDelegate.interactions;
  }
}