import 'package:d4_scale/d4_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';

import '../common.dart';
import '../base/abstract_track_painter.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';

class GlobalChrRulerPainter extends AbstractTrackPainter<ChromosomeData, StyleConfig> {
  Paint? borderPaint;
  late Paint fillPaint;
  late Paint currentRangePaint;
  Offset? userStart;
  Offset? userDelta;
  late Paint userPaint;

//  double chrWidth = 26;

  Range? currentRange;

  GlobalChrRulerPainter({
    required super.trackData,
    super.panOrigin,
    this.currentRange,
    required super.visibleRange,
    required super.scale,
    required super.styleConfig,
    super.orientation,
    this.userStart,
    this.userDelta,
    super.cursor,
  }) : super() {
    fillPaint = Paint()
      ..color = styleConfig.backgroundColor!
      ..strokeWidth = 2;

    borderPaint = styleConfig.borderColor == null
        ? null
        : (Paint()
          ..strokeWidth = 1.0
          ..color = styleConfig.borderColor!
          ..style = PaintingStyle.stroke);

    currentRangePaint = Paint()
      ..color = styleConfig.selectedColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    userPaint = Paint()
      ..color = Colors.red.withAlpha(80)
      ..style = PaintingStyle.fill;
  }

  @override
  initWithSize(Size size) {
    super.initWithSize(size);
  }

  @override
  void onPaint(Canvas canvas, Size size, Rect painterRect) {
//    print('golbal ruler paint $size scale:$panScale');
    double chrWidth = viewSize;
//    if (styleConfig.borderWidth > 0 && borderPaint != null) {
//      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
//    }
    if (orientation == Axis.vertical) {
      if (trackData.center != null && trackData.center! > 0) {
        Rect topRect = Rect.fromLTRB(0, scale[trackData.rangeStart]!, chrWidth, scale[trackData.center!]!);
        canvas.drawRect(topRect, fillPaint);

        Rect bottomRect = Rect.fromLTRB(0, scale[trackData.center!]!, chrWidth, scale[trackData.rangeEnd]!);
        canvas.drawRect(bottomRect, fillPaint);
      } else {
//        Rect _rect = Rect.fromLTRB(0, 0, chrWidth, size.height);
//        canvas.drawRect(rect, fillPaint);
//        canvas.drawRect(rect, bgPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.width / 2)), fillPaint);
        //canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.width / 2)), borderPaint);
      }

      //draw center indicator
      Path path = Path()
        ..moveTo(rect.width, rect.height / 2)
        ..relativeLineTo(-5, -5)
        ..relativeLineTo(0, 10)
        ..close();
      canvas.drawPath(path, Paint()..color = Brightness.dark == styleConfig.brightness ? Colors.white : Colors.red);

      if (userStart != null && userDelta != null) {
        //logger.i('delta $userDelta');
        Rect rect = Rect.fromLTWH(0, userStart!.dy, size.width, userDelta!.dy);
        canvas.drawRect(rect, userPaint);
      }

      if (null != currentRange) {
        var top = scale[currentRange!.start]!;
        var bottom = scale[currentRange!.end]!;
        if (bottom - top < 1) bottom = top + 1;
        Rect rect = Rect.fromLTRB(0, top, size.width, bottom);
        canvas.drawRect(rect, currentRangePaint);
      }

//      canvas.save();
//      canvas.translate(size.width / 2, size.height / 2);
//      canvas.rotate(-math.pi / 2);
//      drawText(
//        canvas,
//        text: trackData.chrName,
//        style: TextStyle(fontSize: 12, color: Colors.white),
//        textAlign: TextAlign.center,
//        width: size.width * 3,
//        offset: Offset(-size.height / 2 + 5, -6),
//      );
//      canvas.restore();
    } else {
      // horz
//      Rect _rect = Rect.fromLTRB(scale[trackData.rangeStart], 0, scale[trackData.rangeEnd], size.height);
      canvas.drawRect(painterRect, fillPaint);
      var __rect = painterRect.translate(0, -4);
      canvas.drawShadow(
          Path()
            ..moveTo(__rect.left, __rect.top)
            ..lineTo(__rect.right, __rect.top)
            ..lineTo(__rect.right, __rect.bottom)
            ..lineTo(__rect.left, __rect.bottom)
            ..close(),
          styleConfig.borderColor!,
          painterRect.height * .35,
          true);
      // canvas.drawRect(rect, borderPaint);

      //draw position
      if (currentRange != null) {
        var left = scale[currentRange!.start]!;
        var right = scale[currentRange!.end]!;
        if (right - left < 2) {
          right = left + 2;
        }
        Rect rect = Rect.fromLTRB(left, 0, right, size.height);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(2)), currentRangePaint..style = PaintingStyle.fill);
        if (rect.width <= 2) {
          canvas.drawRect(
            rect.inflateXY(4, -4),
            currentRangePaint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }

      //center indicator
      Path path = Path()
        ..moveTo(size.width / 2, size.height)
        ..relativeLineTo(-3, -size.height / 2)
        ..relativeLineTo(6, 0)
        ..close();
      canvas.drawPath(path, Paint()..color = Brightness.dark == styleConfig.brightness ? Colors.white : Colors.red);

      if (userStart != null && userDelta != null) {
        // logger.i('delta $userDelta');
        Rect rect = Rect.fromLTWH(userStart!.dx, 0, userDelta!.dx, size.height);
        canvas.drawRect(rect, userPaint);
      }

      String chr = 'Chr: ${trackData.chrName}';
      TextStyle _chrStyle = TextStyle(fontSize: 10, color: styleConfig.isDark ? Colors.white70 : Colors.black54);
      double _chrWidth = measureText(text: chr, style: _chrStyle);
      if (cursor == null || cursor!.dx > _chrWidth) {
        drawText(
          canvas,
          text: chr,
          style: _chrStyle,
          textAlign: TextAlign.left,
          width: size.width,
          offset: Offset(5, (size.height - 14) / 2),
        );
      }

//      drawText(
//        canvas,
//        text: '${trackData.rangeEnd.toInt()}',
//        style: TextStyle(fontSize: 10, color: styleConfig.isDark ? Colors.white54 : Colors.black38),
//        textAlign: TextAlign.right,
//        width: rect.width - 4,
//        offset: Offset(0, (size.height - 14) / 2),
//      );

      if (cursor != null) {
        String left = numberFormatter.format(scale.invert(cursor!.dx).floor());
        var textStyle = TextStyle(fontSize: 10, color: styleConfig.isDark ? Colors.white70 : Colors.black54);
        double width = measureText(text: left, style: textStyle);
        drawText(
          canvas,
          text: '${left}',
          style: textStyle,
          textAlign: TextAlign.start,
          width: width,
          offset: Offset(cursor!.dx + width <= painterRect.right ? cursor!.dx + 2 : cursor!.dx - width - 2, (painterRect.height - 14) / 2),
        );
      }
    }
  }

  @override
  void drawCursor(Canvas canvas) {
    super.drawCursor(canvas);
    if (currentRange != null) {
      var currentRangeWidth = scale[currentRange!.end - currentRange!.start]!;
      var currentRangeLeft = scale[currentRange!.start]!;
      double x = currentRangeLeft + cursor!.dx * (currentRangeWidth) / size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), cursorPaint);
    }
  }

  @override
  bool shouldRepaint(GlobalChrRulerPainter oldDelegate) {
    return (userStart != oldDelegate.userStart && userDelta != oldDelegate.userDelta) || super.shouldRepaint(oldDelegate);
  }
}
