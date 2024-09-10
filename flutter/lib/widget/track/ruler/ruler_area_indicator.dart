import 'package:flutter/material.dart';
import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/mixin/text_painter_mixin.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'package:intl/intl.dart';

class RulerAreaIndicator extends StatefulWidget {
  final double height;
  final Range range;
  final Scale<num, num>? scale;
  final int pixedRange;

  const RulerAreaIndicator({
    Key? key,
    this.height = 40,
    required this.range,
    required this.scale,
    required this.pixedRange,
  }) : super(key: key);

  @override
  State<RulerAreaIndicator> createState() => _RulerAreaIndicatorState();
}

class _RulerAreaIndicatorState extends State<RulerAreaIndicator> {
  @override
  Widget build(BuildContext context) {
    Range? r = widget.scale != null ? Range(start: widget.scale!.scale(widget.range.start)!, end: widget.scale!.scale(widget.range.end)!) : null;
    return Container(
      constraints: BoxConstraints.expand(height: widget.height),
      child: CustomPaint(painter: RulerAreaIndicatorPainter(widget.range, r!, Theme.of(context).colorScheme.primary, widget.pixedRange)),
    );
  }
}

class RulerAreaIndicatorPainter extends CustomPainter with TextPainterMixin {
  late Range bpRange;
  late Range range;
  late Paint _paint;
  late Color _color;
  late int pixelSize;

  RulerAreaIndicatorPainter(this.bpRange, this.range, this._color, this.pixelSize) {
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _color.withOpacity(.23);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(range.start, 0)
      ..lineTo(range.end, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    _paint
      ..style = PaintingStyle.fill
      ..color = _color.withOpacity(.10);
    canvas.drawPath(path, _paint);
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _color.withOpacity(.45);
    canvas.drawPath(path, _paint);

    var x = range.center - 50;
    drawText(
      canvas,
      text: '${NumberFormat.compact().format(bpRange.size)}bp',
      offset: Offset(x.clamp(0, size.width - 100), 2),
      textAlign: x < 0 ? TextAlign.left : (x > size.width - 100 ? TextAlign.end : TextAlign.center),
      width: 100,
      style: TextStyle(color: _color, fontSize: 12),
    );

    drawText(
      canvas,
      text: '${pixelSize}bp/pixel',
      offset: Offset(0, size.height - 14),
      textAlign: TextAlign.right,
      width: size.width - 5,
      style: TextStyle(color: _color, fontSize: 10),
    );
  }

  @override
  bool shouldRepaint(covariant RulerAreaIndicatorPainter oldDelegate) {
    return range != oldDelegate.range;
  }
}
