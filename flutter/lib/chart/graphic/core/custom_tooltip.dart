import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:graphic/graphic.dart';

List<MarkElement> simpleTooltip(
  Size size,
  Offset anchor,
  Map<int, Tuple> selectedTuples,
) {
  List<MarkElement> elements;

  // print('anchor: ${anchor}, size: $size, tuples: ${selectedTuples}');

  String textContent = '';
  final selectedTupleList = selectedTuples.values;
  final fields = selectedTupleList.first.keys.toList();
  if (selectedTuples.length == 1) {
    final original = selectedTupleList.single;
    String field = fields.first;
    textContent += '$field: ${original[field]}';
    for (var i = 1; i < fields.length; i++) {
      field = fields[i];
      textContent += '\n${field.padRight(5)}: ${original[field].toStringAsFixed(2)}';
    }
  } else {
    textContent += '${selectedTupleList.first[fields[0]]}';
    for (var original in selectedTupleList) {
      final domainField = fields[1];
      final measureField = fields.last;
      if (original[measureField] == 0) continue;
      textContent += '\n${original[domainField]}: ${original[measureField]}';
    }
  }

  const textStyle = TextStyle(fontSize: 12, color: Colors.white, fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK);
  const padding = EdgeInsets.all(5);
  const align = Alignment.topRight;
  const offset = Offset(5, -5);
  const elevation = 1.0;
  const backgroundColor = Colors.black54;

  final painter = TextPainter(
    text: TextSpan(text: textContent, style: textStyle),
    textDirection: TextDirection.ltr,
  );
  painter.layout();

  final width = padding.left + painter.width + padding.right;
  final height = padding.top + painter.height + padding.bottom;

  final paintPoint = getBlockPaintPoint(
    anchor + offset,
    width,
    height,
    align,
  );

  final window = Rect.fromLTWH(
    paintPoint.dx,
    paintPoint.dy,
    width,
    height,
  );

  var textPaintPoint = paintPoint + padding.topLeft;

  elements = <MarkElement>[
    RectElement(rect: window, borderRadius: BorderRadius.circular(5), style: PaintStyle(fillColor: backgroundColor, elevation: elevation)),
    LabelElement(text: textContent, anchor: textPaintPoint, style: LabelStyle(textStyle: textStyle, align: Alignment.bottomRight)),
  ];

  return elements;
}