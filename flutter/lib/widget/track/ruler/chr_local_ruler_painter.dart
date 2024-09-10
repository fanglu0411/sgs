import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/ruler/ruler_style_config.dart';
import 'package:intl/intl.dart';

import '../base/abstract_track_painter.dart';

class LocalChrRulerPainter extends AbstractTrackPainter<TrackData, RulerStyleConfig> {
  late Paint bgPaint;
  late Paint fillPaint;

  int tickSize = 18;
  int smallTickSize = 5;

  static const int TickDistance = 20;
  static const int TextTickDistance = 100;

  LocalChrRulerPainter({
    required super.trackData,
    required super.scale,
    required super.visibleRange,
    required super.styleConfig,
  }) : super() {
    fillPaint = Paint()
      ..color = styleConfig.tickerColor
      ..strokeWidth = 1;

    bgPaint = Paint()
      ..strokeWidth = 1
      ..color = Colors.blue[100]!
      ..style = PaintingStyle.stroke;
  }

  @override
  initWithSize(Size size) {
    super.initWithSize(size);
  }

  @override
  bool onEmptyPaint(ui.Canvas canvas, ui.Size size) {
    return false;
    // return super.onEmptyPaint(canvas, size);
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
    RulerStyleConfig _styleConfig = styleConfig;
    if (_styleConfig.backgroundColor != null) {
      bgPaint
        ..color = _styleConfig.backgroundColor!
        ..style = PaintingStyle.fill;

      LinearGradient gradient = LinearGradient(colors: [Colors.blue[300]!, Colors.blue[100]!]);
      bgPaint.shader = gradient.createShader(painterRect);

      canvas.drawRect(painterRect, bgPaint);
    }
    if ((_styleConfig.borderWidth ?? 0) > 0) {
      bgPaint
        ..strokeWidth = _styleConfig.borderWidth
        ..style = PaintingStyle.stroke
        ..color = _styleConfig.borderColor!;
      canvas.drawRect(painterRect, bgPaint);
    }

    double tickDistance = TickDistance.toDouble();
    double textTickDistance = TextTickDistance.toDouble();

    double _scale = size.width / visibleRange.size;

    double scaledTickDistance = (tickDistance * _scale);
    // print('scaledTickDistance: ${scaledTickDistance}');
    var n = 5.0;
    if (scaledTickDistance > n * TickDistance) {
      while (scaledTickDistance > n * TickDistance && tickDistance > n) {
        scaledTickDistance = (scaledTickDistance / n);
        tickDistance = (tickDistance / n);
        textTickDistance = (textTickDistance / n);
        if (tickDistance == 2) n = 2;
        // if (tickDistance < 5) n = 1;
        // print('scaledTickDistance: ${scaledTickDistance}, tickDistance: ${tickDistance}, textTickDistance: ${textTickDistance}');
      }
      if (tickDistance < 5.0) {
        tickDistance = 5.0;
        textTickDistance = 25.0;
        scaledTickDistance = tickDistance * _scale;
        if (scaledTickDistance >= 200) {
          tickDistance = 1.0;
          textTickDistance = 5.0;
          scaledTickDistance = tickDistance * _scale;
        }
      }
    } else {
      while (scaledTickDistance < TickDistance) {
        scaledTickDistance *= n;
        tickDistance *= n;
        textTickDistance *= n;
        if (tickDistance == 2) n = 2;
        // print('scaledTickDistance: ${scaledTickDistance}, tickDistance: ${tickDistance}, textTickDistance: ${textTickDistance}');
      }
    }

    /// The number of ticks to draw.
    int numTicks = (size.width / scaledTickDistance).ceil() + 2;
    if (scaledTickDistance > TextTickDistance) {
      textTickDistance = tickDistance;
    }

    double tickStart = visibleRange.start - visibleRange.start % tickDistance;

    double x = scale.scale(tickStart)!;
    // print('x: ${x}, numTicks: $numTicks, tickDistance: $tickDistance, tickStart $tickStart, scaledTickDistance:$scaledTickDistance, ');

    Set<String> usedValues = Set<String>();

    bool bigTicker;
    for (int i = 0; i < numTicks + 1; i++) {
      bigTicker = tickStart % textTickDistance == 0;
      canvas.drawLine(Offset(x, painterRect.top), Offset(x, bigTicker ? tickSize.toDouble() : smallTickSize.toDouble()), fillPaint);
      if (bigTicker) {
        var label = formatTicker(tickStart, usedValues);
        drawText(
          canvas,
          text: label,
          offset: Offset(x + 2, painterRect.bottom - 12.0),
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 10, color: _styleConfig.tickerColor),
        );
      }
      tickStart += tickDistance;
      x += scaledTickDistance;
    }
  }

  NumberFormat labelFormatter = NumberFormat.decimalPattern();

  String formatTicker(num start, Set<String> usedValues) {
    String label;
    if (start < 90000) {
      label = start.toStringAsFixed(0);
    } else {
      label = labelFormatter.format(start);
      // label = labelFormatter.format(start);
      // int digits = labelFormatter.significantDigits;
      // while (usedValues.contains(label) && digits < 10) {
      //   labelFormatter.significantDigits = ++digits;
      //   label = labelFormatter.format(start);
      // }
    }
    usedValues.add(label);
    return label;
  }

  @override
  bool shouldRepaint(LocalChrRulerPainter oldDelegate) {
    return super.shouldRepaint(oldDelegate);
  }
}
