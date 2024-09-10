import 'dart:math' as math;
import 'package:dartx/dartx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/chart/graphic/shape/motif_logo_shape.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';
import 'package:graphic/graphic.dart';

/// data [{q1, mean, q3, min, max, density}]
class MotifLogoPlot extends StatelessWidget {
  final List<Map> data;
  final String? label;
  final double labelSize;
  final Color? labelColor;
  final bool dark;

  const MotifLogoPlot({
    super.key,
    required this.data,
    this.label,
    this.labelColor = Colors.black87,
    this.labelSize = 12,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    List<String> xLabels = data.groupBy((e) => '${e['type']}').keys.toList();
    double maxLabelWidth = (xLabels.maxBy((e) => '${e}'.length)?.length ?? 0) * 10 * .65;
    double _itemWidth = (constraints.biggest.width / xLabels.length) * .95;
    double? labelRotation = maxLabelWidth > _itemWidth ? math.pi * 1.8 : null;
    bool labelAutoHide = constraints.biggest.width < 500;
    double xLabelHeight = labelRotation == null ? 30.0 : (math.sin(math.pi / 4) * maxLabelWidth);

    return Chart(
      padding: (s) => EdgeInsets.only(left: 40, bottom: xLabelHeight, top: 20),
      data: data,
      variables: {
        'index': Variable(
          accessor: (Map datumn) => (datumn['index']).toString(),
        ),
        'type': Variable(
          accessor: (Map datumn) => datumn['type'] as String,
        ),
        'value': Variable(
          accessor: (Map datumn) => datumn['value'] as num,
          scale: LinearScale(min: 0, max: 1.2),
        ),
        'color': Variable(
          accessor: (Map datumn) => datumn['color'] as String,
        ),
      },
      marks: [
        IntervalMark(
          shape: ShapeEncode(value: MotifLogoShape(showBackground: true)),
          // shape: ShapeEncode(value: RectShape(labelPosition: 0.5)),
          position: Varset('index') * Varset('value') / Varset('type'),
          tag: (t) => t['type'],
          color: ColorEncode(
            // variable: 'type',
            // value: Colors.green,
            // values: Defaults.colors10,
            encoder: (turple) => parseHexColor(turple['color']),
            updaters: {
              'hover': {
                false: (color) {
                  return color.withAlpha(100);
                }
              }
            },
          ),
          // label: LabelEncode(
          //     encoder: (tuple) => Label(
          //           tuple['value'].toStringAsFixed(2),
          //           LabelStyle(
          //               textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          //               strutStyle: StrutStyle(
          //                 forceStrutHeight: true,
          //               )),
          //         )),
          modifiers: [StackModifier()],
        )
      ],
      axes: [
        // Defaults.horizontalAxis,
        AxisGuide(
            dim: Dim.x,
            // line: PaintStyle(strokeColor: Colors.black54, strokeWidth: 1),
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
          tickLine: TickLine(length: 4, style: PaintStyle(strokeColor: labelColor, strokeWidth: 1)),
          label: LabelStyle(
            textStyle: Defaults.textStyle.copyWith(color: labelColor),
            offset: const Offset(-7.5, 0),
          ),
          // line: PaintStyle(strokeColor: Colors.black54, strokeWidth: 1),
        ),
      ],
      coord: RectCoord(),
      // tooltip: TooltipGuide(multiTuples: true),
      tooltip: TooltipGuide(renderer: simpleTooltip, followPointer: [false, true], selections: {'hover'}),
      selections: {
        'tap': PointSelection(variable: 'type', on: {GestureType.tap}),
        'hover': PointSelection(
          variable: 'index',
          dim: Dim.x,
          on: {GestureType.hover},
          clear: {GestureType.tap, GestureType.doubleTap, GestureType.mouseExit},
          devices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        // 'hover': PointSelection(variable: 'group', dim: Dim.x),
      },
      // crosshair: CrosshairGuide(),
      annotations: [
        if (label != null)
          TagAnnotation(
            label: Label(
              label,
              LabelStyle(textStyle: Defaults.textStyle.copyWith(fontSize: labelSize, color: labelColor), align: Alignment.center),
            ),
            anchor: (size) => size.topCenter(Offset(0, 20)),
          ),
      ],
    );
    // return ViolinPlot(data..sort());
//     return const Text('aaa');
  }

  List<MarkElement> simpleTooltip(
    Size size,
    Offset anchor,
    Map<int, Tuple> selectedTuples,
  ) {
    List<MarkElement> elements;

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
      if (selectedTupleList.length > 0) textContent += '${selectedTupleList.first['index']}';
      for (var original in selectedTupleList) {
        textContent += '\n${original['type']}: ${original['value']}';
      }
    }

    var textStyle = TextStyle(
      fontSize: 12,
      color: dark ? Colors.white : Colors.black87,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );
    const padding = EdgeInsets.all(5);
    const align = Alignment.centerRight;
    const offset = Offset(5, -5);
    const elevation = 1.0;
    var backgroundColor = dark ? Colors.grey[700] : Colors.grey[100];

    final painter = TextPainter(
      text: TextSpan(text: textContent, style: textStyle),
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
      LabelElement(text: textContent, anchor: textPaintPoint, style: LabelStyle(textStyle: textStyle, align: Alignment.bottomRight)),
    ];

    return elements;
  }
}
