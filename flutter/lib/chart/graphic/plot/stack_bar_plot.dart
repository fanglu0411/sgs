import 'dart:async';
import 'dart:math' as math;

import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/chart/graphic/element/inline_span_element.dart';
import 'package:get/get.dart';
import 'package:graphic/graphic.dart';

import '../core/custom_annotation.dart';
import '../shape/custom_rect_shape.dart';

class StackBarPlot extends StatelessWidget {
  final List<Map> data;
  final List? types;
  final List<Color>? colors;
  final Map<String, Color>? colorMap;
  final double barWidth;
  final Color? labelColor;
  final ValueChanged<List<Map>>? onItemTap;
  final num? maxValue;
  final String stackAccessKey;
  final bool dark;

  final StreamController<Selected?> selectionStream = StreamController<Selected?>.broadcast();

  StackBarPlot({
    super.key,
    required this.data,
    required this.stackAccessKey,
    this.maxValue,
    this.types,
    this.colors,
    this.colorMap,
    this.barWidth = 20,
    this.onItemTap,
    this.labelColor = Colors.black87,
    this.dark = false,
  }) {
    selectionStream.stream.listen((event) {
      Set dataIndexSet = event![event.keys.first]!;
      var _selectedData = dataIndexSet.map((i) => this.data[i]).toList();
      onItemTap?.call(_selectedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    List<String> xLabels = data.groupBy((e) => '${e['group']}').keys.toList();
    double maxLabelWidth = (xLabels.maxBy((e) => '${e}'.length)?.length ?? 0) * 10 * .65;
    double _barWidth = (constraints.maxWidth / xLabels.length) * .75;

    double? labelRotation = maxLabelWidth > _barWidth ? math.pi * 1.8 : null;
    bool labelAutoHide = constraints.maxWidth < 500;
    double xLabelHeight = labelRotation == null ? 30.0 : (math.sin(math.pi / 4) * maxLabelWidth);
    if (xLabelHeight < 30) xLabelHeight = 30.0;

    // List _types = this.types ?? data.groupBy((e) => '${e['type']}').keys.toList();
    var (double legendHeight, List<Annotation>? legends) = types != null
        ? AnnotationBuilder(
            types: types!,
            textStyle: Defaults.textStyle.copyWith(fontSize: 12, color: labelColor),
            colors: colorMap != null ? colorMap!.values.toList() : (colors ?? Defaults.colors20),
            align: Alignment.topLeft,
            width: constraints.maxWidth - 50,
            padding: EdgeInsets.only(left: 50, top: 20),
          ).build()
        : (0, null);

    num _maxValue = maxValue ?? (data.length > 0 ? data.map((e) => e[stackAccessKey]).sorted().last * 1.2 : null);

    return Chart(
      padding: (s) => EdgeInsets.only(left: 50, bottom: xLabelHeight, top: 20 + legendHeight),
      data: data,
      variables: {
        'group': Variable(
          accessor: (Map map) => map['group'].toString(),
        ),
        'type': Variable(
          accessor: (Map map) => map['type'] as String,
        ),
        '${stackAccessKey}': Variable(
          accessor: (Map map) => map[stackAccessKey] as num,
          scale: LinearScale(min: 0, max: _maxValue),
        ),
      },
      marks: [
        IntervalMark(
          position: Varset('group') * Varset(stackAccessKey) / Varset('type'),
          shape: ShapeEncode(value: CustomRectShape(histogram: false, barWidth: _barWidth)),
          color: colorMap != null
              ? ColorEncode(
                  encoder: (tuple) {
                    return colorMap!['${tuple['type']}'] ?? Color(0xff5A71ED);
                  },
                  updaters: {
                    'hover': {false: (color) => color.withAlpha(100)}
                  },
                )
              : ColorEncode(
                  variable: 'type',
                  values: colors ?? Defaults.colors20,
                  updaters: {
                    'hover': {false: (color) => color.withAlpha(100)}
                  },
                ),
          tag: (t) => t['group'],
          modifiers: [
            StackModifier(),
          ],
          // selectionStream: selectionStream,
        )
      ],
      coord: RectCoord(),
      tooltip: TooltipGuide(renderer: simpleTooltip, followPointer: [false, true], selections: {'hover'}),
      selections: {
        'tap': PointSelection(variable: 'group', on: {GestureType.tap}),
        'hover': PointSelection(
          variable: 'group',
          dim: Dim.x,
          on: {GestureType.hover},
          clear: {GestureType.tap, GestureType.doubleTap, GestureType.mouseExit},
          devices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        // 'hover': PointSelection(variable: 'group', dim: Dim.x),
      },
      axes: [
        // Defaults.horizontalAxis,
        AxisGuide(
            dim: Dim.x,
            labelMapper: (String? text, int index, int total) {
              if (total < 10)
                return LabelStyle(
                  textStyle: TextStyle(fontSize: 10, color: labelColor),
                  offset: const Offset(0, 7.5),
                  rotation: labelRotation,
                  align: labelRotation != null ? Alignment.centerLeft : Alignment.center,
                );
              return labelAutoHide && index % 2 == 0
                  ? null
                  : LabelStyle(
                      textStyle: TextStyle(fontSize: 10, color: labelColor),
                      offset: const Offset(5, 7.5),
                      rotation: labelRotation,
                      align: labelRotation != null ? Alignment.centerLeft : Alignment.center,
                    );
            }),
        AxisGuide(
          dim: Dim.y,
          grid: PaintStyle(strokeWidth: 1.0, strokeColor: labelColor?.withOpacity(.15)),
          // tickLine: TickLine(length: 4, style: PaintStyle(strokeColor: labelColor, strokeWidth: 1)),
          label: LabelStyle(
            textStyle: Defaults.textStyle.copyWith(color: labelColor),
            offset: const Offset(-7.5, 0),
          ),
          // line: PaintStyle(strokeColor: Colors.black54, strokeWidth: 1),
        ),
      ],
      // crosshair: CrosshairGuide(),
      annotations: legends,
    );
  }

  Color? getTypeColor(String type, int index) {
    if (colorMap != null) return colorMap![type];
    if (colors != null) return colors![index];
    return labelColor ?? Colors.grey;
  }

  List<MarkElement> simpleTooltip(
    Size size,
    Offset anchor,
    Map<int, Tuple> selectedTuples,
  ) {
    List<MarkElement> elements;

    String textContent = '';
    final selectedTupleList = selectedTuples.values.toList();
    final fields = selectedTupleList.first.keys.toList();

    List<InlineSpan> spans = [];

    textContent += '${fields[0]}: ${selectedTupleList.first[fields[0]]}\n';

    List<List<String>> rows = [
      ['● ', ...fields.filter((e) => e != 'group')],
    ];

    for (var original in selectedTupleList) {
      if (original[stackAccessKey] == 0.0) continue;
      List<String> row = ['● '];
      for (var field in fields) {
        if (field == 'group') continue;
        row.add('${original[field]}');
      }
      rows.add(row);
    }
    textContent = textContent.trim();

    List<int> columnMaxLength = List.generate(rows[0].length, (index) {
      return rows.map((r) => r[index]).maxBy((e) => e.length)!.length;
    });

    var textStyle = TextStyle(
      fontSize: 13,
      color: dark ? Colors.white : Colors.black87,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );

    spans = [
      TextSpan(text: 'Group: ${selectedTupleList.first['group']}\n'),
      ...rows.mapIndexed((n, row) {
        var _row = row.mapIndexed((i, e) => e.padRight(columnMaxLength[i])).toList();
        var [f, ...a] = _row;
        return TextSpan(
          style: textStyle,
          children: [
            TextSpan(text: f, style: n == 0 ? null : textStyle.copyWith(color: getTypeColor(row[1], n))),
            TextSpan(text: a.join(' ')),
            if (n < rows.length - 1) TextSpan(text: '\n'),
          ],
        );
      })
    ];

    const padding = EdgeInsets.all(10);
    const align = Alignment.centerRight;
    const offset = Offset(15, -5);
    const elevation = 5.0;
    var backgroundColor = dark ? Colors.grey[700] : Colors.grey[100];

    final painter = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    );
    painter.layout();

    final width = padding.left + painter.width + padding.right;
    final height = padding.top + painter.height + padding.bottom;

    final paintPoint = getBlockPaintPoint(anchor + offset, width, height, align);
    final window = Rect.fromLTWH(paintPoint.dx, paintPoint.dy, width, height);
    var textPaintPoint = paintPoint + padding.topLeft;

    elements = <MarkElement>[
      RectElement(rect: window, borderRadius: BorderRadius.circular(5), style: PaintStyle(fillColor: backgroundColor, elevation: elevation)),
      LabelElement(
          text: textContent,
          anchor: textPaintPoint,
          style: LabelStyle(
            align: Alignment.bottomRight,
            span: (String text) {
              return TextSpan(children: spans, style: textStyle);
            },
          )),
    ];

    return elements;
  }
}
