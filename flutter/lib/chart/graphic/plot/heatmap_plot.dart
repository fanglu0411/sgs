import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/chart/graphic/shape/violin_shape.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/util/random_color/random_file.dart';
import 'dart:math' as math;

import 'package:graphic/graphic.dart';

/// data [{q1, mean, q3, min, max, density}]
class HeatmapPlot extends StatelessWidget {
  final List<Map> data;
  final String? label;
  final double? max;
  final double? min;
  final double labelSize;
  final Color? labelColor;
  final List<Color>? colors;
  final bool heatmap;
  final Size? size;
  final Function1<dynamic, String> accessorX;
  final Function1<dynamic, String> accessorY;
  final bool transposed;

  HeatmapPlot({
    super.key,
    required this.data,
    required this.accessorX,
    required this.accessorY,
    this.label,
    this.max,
    this.min,
    this.labelSize = 12,
    this.labelColor = Colors.black87,
    this.colors,
    this.heatmap = true,
    this.size,
    this.transposed = true,
  }) {}

  late bool isDark;

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    double _max = max ?? data.map((e) => e['value']).toList().max() * 1.5;
    double _min = min ?? data.map((e) => e['value']).toList().min() * 1.0;

    List<String> xLabels = data.groupBy(accessorX).keys.toList();
    List<String> yLabels = data.groupBy(accessorY).keys.toList();

    double _xLabelWidthMax = (xLabels.maxBy((e) => '${e}'.length)?.length ?? 0) * 10 * .65;
    double _yLabelWidthMax = (yLabels.maxBy((e) => '${e}'.length)?.length ?? 0) * 10 * .65;

    double xLabelWidth = transposed ? _yLabelWidthMax : _xLabelWidthMax;
    double yLabelWidth = transposed ? _xLabelWidthMax : _yLabelWidthMax;
    // if (yLabelWidth < 50) yLabelWidth = 50;

    double itemSize = 50;
    double? xLabelRotation = xLabelWidth > itemSize ? math.pi * 1.8 : null;
    bool labelAutoHide = constraints.biggest.width < 500;

    double xLabelHeight = xLabelRotation == null ? 20 : xLabelWidth * math.sin(math.pi / 4);

    double w = yLabelWidth + xLabels.length * itemSize + 20;
    double h = xLabelHeight + yLabels.length * itemSize + 40;

    var group = Variable(
      accessor: (Map datumn) => accessorX(datumn),
    );
    var feature = Variable(
      accessor: (Map datumn) => accessorY(datumn),
    );
    var value = Variable(
      accessor: (Map datumn) => (datumn['value'] as num),
    );
    var variables = transposed ? {'Feature': feature, 'Group': group, 'Value': value} : {'Group': group, 'Feature': feature, 'Value': value};

    return SizedBox(
      width: transposed ? h : w,
      height: transposed ? w : h,
      child: Chart(
        data: data,
        padding: (s) => EdgeInsets.only(left: yLabelWidth, bottom: xLabelHeight, top: 20),
        // padding: (s) => EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        variables: variables,
        marks: [
          if (heatmap)
            PolygonMark(
              color: ColorEncode(
                variable: 'Value',
                values: colors ?? [const Color(0xffbae7ff), const Color(0xff1890ff), const Color(0xff0050b3)],
              ),
            ),
          if (!heatmap)
            PointMark(
              size: SizeEncode(variable: 'Value', values: [5, 30]),
              color: ColorEncode(
                variable: 'Value',
                values: colors ?? Defaults.colors10,
                updaters: {
                  'touch': {true: (_) => Colors.red}
                },
              ),
              shape: ShapeEncode(
                value: CircleShape(hollow: false),
                // updaters: {
                //   'touch': {true: (_) => CircleShape(hollow: true)},
                // },
              ),
            )
        ],
        axes: [
          AxisGuide(
              dim: Dim.x,
              variable: transposed ? 'Feature' : 'Group',
              // tickLine: TickLine(length: 4, style: PaintStyle(strokeColor: labelColor, strokeWidth: 1)),
              // line: PaintStyle(strokeColor: labelColor?.withOpacity(.3), strokeWidth: 1),
              grid: heatmap ? null : PaintStyle(strokeColor: labelColor?.withOpacity(.1), strokeWidth: 1),
              labelMapper: (String? text, int index, int total) {
                if (total < 10)
                  return LabelStyle(
                    textStyle: TextStyle(fontSize: 10, color: labelColor),
                    offset: const Offset(0, 7.5),
                    rotation: xLabelRotation,
                    align: xLabelRotation != null ? Alignment.centerLeft : Alignment.center,
                  );
                return labelAutoHide && index % 2 == 0
                    ? null
                    : LabelStyle(
                        textStyle: TextStyle(fontSize: 10, color: labelColor),
                        offset: const Offset(5, 7.5),
                        rotation: xLabelRotation,
                        align: xLabelRotation != null ? Alignment.centerLeft : Alignment.center,
                      );
              }),
          AxisGuide(
            dim: Dim.y,
            variable: transposed ? 'Group' : 'Feature',
            // tickLine: TickLine(length: 4, style: PaintStyle(strokeColor: labelColor, strokeWidth: 1)),
            label: LabelStyle(
              textStyle: Defaults.textStyle.copyWith(color: labelColor),
              offset: const Offset(-7.5, 0),
            ),
            grid: heatmap ? null : PaintStyle(strokeColor: labelColor?.withOpacity(.1), strokeWidth: 1),
            // line: PaintStyle(strokeColor: labelColor?.withOpacity(.3), strokeWidth: 1),
          ),
        ],
        // coord: RectCoord(horizontalRangeUpdater: Defaults.horizontalRangeEvent),
        coord: RectCoord(),
        tooltip: TooltipGuide(
          followPointer: [false, true],
          // align: Alignment.bottomRight,
          // offset: Offset(10, 0),
          renderer: simpleTooltip,
        ),
        selections: {
          'touch': PointSelection(
            on: {GestureType.hover},
            clear: {GestureType.tap, GestureType.doubleTap, GestureType.mouseExit},
            devices: {PointerDeviceKind.mouse},
          ),
          // 'choose': IntervalSelection(),
        },
        crosshair: heatmap ? null : CrosshairGuide(),
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
      ),
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
    final selectedTuple = selectedTuples.values.first;
    final fields = selectedTuple.keys.toList();
    for (var i = 0; i < fields.length; i++) {
      var value = selectedTuple[fields[i]];
      if (value is num) value = value.toStringAsFixed(4);
      textContent += '${fields[i].padRight(7)}: ${value}';
      if (i < fields.length - 1) textContent += '\n';
    }

    var textStyle = TextStyle(
      fontSize: 13,
      color: isDark ? Colors.white : Colors.black87,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );
    const padding = EdgeInsets.all(10);
    const align = Alignment.bottomRight;
    const offset = Offset(15, -5);
    const elevation = 5.0;
    var backgroundColor = isDark ? Colors.grey[700] : Colors.grey[100];

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
