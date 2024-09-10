import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/mixin/text_painter_mixin.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/legend_colors.dart';
import 'package:flutter_smart_genome/util/debouncer.dart';
import 'package:d4/d4.dart' as d4;

class LinearLegendView extends StatefulWidget {
  final double height;
  final LegendColor color;
  final double width;
  final Axis axis;

  const LinearLegendView({
    super.key,
    this.height = 300,
    this.width = 40,
    this.axis = Axis.vertical,
    required this.color,
  });

  @override
  State<LinearLegendView> createState() => _LinearLegendViewState();
}

class _LinearLegendViewState extends State<LinearLegendView> {
  Offset? _cursor;

  Debounce? _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(milliseconds: 1200);
  }

  _autoResetCursor() {
    _debounce?.run(() {
      _cursor = null;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (v) {
        _cursor = v.localPosition;
        setState(() {});
        _autoResetCursor();
      },
      onPointerMove: _onPointerMove,
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: LinearLegendPaint(
          widget.color,
          axis: widget.axis,
          offset: _cursor,
          barWidth: 20,
          dark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }

  void _onPointerMove(PointerMoveEvent e) {}

  @override
  void dispose() {
    super.dispose();
    _debounce?.dispose();
    _debounce = null;
  }
}

class LinearLegendPaint extends CustomPainter with TextPainterMixin {
  late LegendColor legendColor;
  double barWidth;
  Offset? offset;
  late Paint _paint;
  late bool dark;
  late Axis axis;

  late d4.ScaleSequential _colorScale;

  LinearLegendPaint(
    this.legendColor, {
    this.offset,
    this.barWidth = 20,
    this.dark = false,
    this.axis = Axis.vertical,
  }) {
    _paint = Paint();
    _colorScale = d4.ScaleSequential(domain: [0, 1.0], interpolator: legendColor.interpolate);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (axis == Axis.vertical) {
      paintVertical(canvas, size);
    } else {
      paintHorizontal(canvas, size);
    }
  }

  void paintVertical(Canvas canvas, Size size) {
    _paint..style = PaintingStyle.fill;
    var rect = Rect.fromLTWH(0, 0, barWidth, size.height);
    // _paint..shader = LinearGradient(colors: [legendColor.start, legendColor.end], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(rect);
    // canvas.drawRRect(RRect.fromRectXY(rect, 2, 2), _paint);

    var p = 1 / 10;
    double blockHeight = size.height * p;
    Rect _rect = Rect.fromLTWH(0, size.height - blockHeight, barWidth, blockHeight);
    double i = 0.1;
    do {
      canvas.drawRect(_rect, _paint..color = d4.Color.tryParse(_colorScale.call(i))!.flutterColor);
      _rect = _rect.translate(0, -blockHeight);
      i += p;
    } while (i < 1.0);

    ///draw cursor

    if (null != offset) {
      Path path = Path()
        ..moveTo(0, offset!.dy)
        ..lineTo(-10, offset!.dy - 6)
        ..lineTo(-10, offset!.dy + 6)
        ..close();
      canvas.drawPath(path, _paint..color = d4.Color.tryParse(_colorScale.call(1 - (offset!.dy / size.height)))!.flutterColor);
    }

    final textColor = dark ? Colors.white70 : Colors.black87;
    if (legendColor.min != null)
      drawText(
        canvas,
        text: '${legendColor.min!.toStringAsPrecision(2)}',
        offset: size.bottomLeft(Offset(0, 0)),
        width: barWidth,
        style: TextStyle(color: textColor, fontSize: 12),
        textAlign: TextAlign.center,
      );
    if (legendColor.max != null)
      drawText(
        canvas,
        text: '${legendColor.max! < 1 ? legendColor.max!.toStringAsPrecision(2) : legendColor.max!.toStringAsFixed(1)}',
        offset: size.topLeft(Offset(0, -14)),
        width: barWidth,
        style: TextStyle(color: textColor, fontSize: 12),
        textAlign: TextAlign.center,
      );
  }

  void paintHorizontal(Canvas canvas, Size size) {
    _paint..style = PaintingStyle.fill;
    var rect = Rect.fromLTWH(0, 0, barWidth, size.height);
    // _paint..shader = LinearGradient(colors: [legendColor.start, legendColor.end], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(rect);
    // canvas.drawRRect(RRect.fromRectXY(rect, 2, 2), _paint);

    var p = 1 / 10;
    double blockStep = size.width * p;
    Rect _rect = Rect.fromLTWH(0, 0, blockStep, barWidth);
    double i = 0.1;
    do {
      canvas.drawRect(_rect, _paint..color = d4.Color.tryParse(_colorScale.call(i))!.flutterColor);
      _rect = _rect.translate(blockStep, 0);
      i += p;
    } while (i < 1.0);

    final textColor = dark ? Colors.white70 : Colors.black87;

    ///draw cursor
    if (null != offset) {
      Path path = Path()
        ..moveTo(offset!.dx, barWidth)
        ..lineTo(offset!.dx - 6, barWidth + 10)
        ..lineTo(offset!.dx + 6, barWidth + 10)
        ..close();
      canvas.drawPath(path, _paint..color = d4.Color.tryParse(_colorScale.call((offset!.dx / size.width)))!.flutterColor);

      var value = ((offset!.dx / size.width)) * (legendColor.max! - legendColor.min!) + legendColor.min!;
      drawText(
        canvas,
        text: '${value.toStringAsPrecision(2)}',
        offset: Offset(offset!.dx, (barWidth + 12)),
        width: 1,
        style: TextStyle(color: textColor, fontSize: 12),
        textAlign: TextAlign.center,
      );
    }

    if (legendColor.min != null)
      drawText(
        canvas,
        text: '${legendColor.min!.toStringAsPrecision(2)}',
        offset: Offset(-25, (barWidth - 12) / 2),
        width: 30,
        style: TextStyle(color: textColor, fontSize: 12),
        textAlign: TextAlign.start,
      );
    if (legendColor.max != null)
      drawText(
        canvas,
        text: '${legendColor.max! < 1 ? legendColor.max!.toStringAsPrecision(2) : legendColor.max!.toStringAsFixed(1)}',
        offset: Offset(size.width + 6, (barWidth - 12) / 2),
        width: 0,
        style: TextStyle(color: textColor, fontSize: 12),
        textAlign: TextAlign.end,
      );
  }

  @override
  bool shouldRepaint(covariant LinearLegendPaint oldDelegate) {
    return legendColor != oldDelegate.legendColor || offset != oldDelegate.offset;
  }
}
