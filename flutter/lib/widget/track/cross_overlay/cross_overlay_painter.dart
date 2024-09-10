import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/highlight_range.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';
import 'package:flutter_smart_genome/service/sgs_config_service.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

import '../track_group_logic.dart';

class CrossOverlayPainter extends CustomPainter {
  final CursorSelection? selection;
  final Range range;
  final Scale<num, num> scale;
  late Paint _paint;

  final Color? flashColor;
  final Range? flashRange;

  CrossOverlayPainter({
    this.selection,
    required this.range,
    required this.scale,
    this.flashRange,
    this.flashColor,
  }) {
    _paint = Paint()..color = Colors.red;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawHighlightRanges(canvas, size);

    drawFlash(canvas, size);

    if (selection == null) return;

    if (selection!.start != Offset.infinite) {
      _paint
        ..style = PaintingStyle.stroke
        ..color = Color(0xf0ffbe3b)
        ..strokeWidth = .5;

      if (selection!.end == Offset.infinite) {
        canvas.drawLine(Offset(selection!.start.dx, 0), Offset(selection!.start.dx, size.height), _paint);
        return;
      } else {
        Rect rect = Rect.fromLTWH(selection!.start.dx, 0, selection!.width, size.height);

        canvas.drawRect(rect, _paint);

        _paint.style = PaintingStyle.fill;
        _paint..color = Color(0x55ffbe3b);
        canvas.drawRect(rect, _paint);
      }

      // canvas.drawLine(Offset(0, position.dy), Offset(size.width, position.dy), _paint);
    } else if (selection!.hover != Offset.infinite) {
      _paint
        ..color = Colors.grey
        ..strokeWidth = .5;
      canvas.drawLine(
        Offset(selection!.hover.dx, 0),
        Offset(selection!.hover.dx, size.height),
        _paint,
      );
    }
  }

  void _drawHighlightRanges(Canvas canvas, Size size) {
    List<HighlightRange> highlights = SgsConfigService.get()!.getHighlights();
    var chrId = SgsAppService.get()!.chr1?.id;
    var _intersect;
    for (HighlightRange highlight in highlights) {
      if (!highlight.visible || highlight.chrId != chrId) continue;
      _intersect = highlight.range.intersection(range);
      if (null == _intersect) continue;

      double _start = scale.scale(_intersect.start) as double;
      double _end = scale.scale(_intersect.end) as double;
      Rect rect = Rect.fromLTWH(_start, 0, _end - _start, size.height);

      _paint
        ..style = PaintingStyle.fill
        ..color = highlight.color;
      canvas.drawRect(rect, _paint);
    }
  }

  void drawFlash(Canvas canvas, Size size) {
    if (flashRange == null || flashColor == null) return;
    double _start = scale.scale(flashRange!.start)!;
    double _end = scale.scale(flashRange!.end)!;
    Rect rect = Rect.fromLTWH(_start, 0, _end - _start, size.height);
    _paint
      ..style = PaintingStyle.fill
      ..color = flashColor!.withOpacity(.05);
    canvas.drawRect(rect, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is CrossOverlayPainter) {
      return oldDelegate.selection != selection || oldDelegate.flashRange != flashRange || oldDelegate.flashColor != flashColor || oldDelegate.range != range;
    }
    return false;
  }
}
