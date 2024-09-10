import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/graphic/shape/grouped_scatter_shape.dart';

import 'package:graphic/graphic.dart';

/// data [{group, color, unit8list }]
class GroupedScatterPlot extends StatelessWidget {
  final Map<String, List> data;
  final String? label;
  final double? dotSize;
  final List<Color>? colors;
  final double? labelSize;
  final Color? labelColor;
  final bool showAxis;
  final num cordMax;
  final bool revertY;
  final num Function(num value) domainMapper;

  const GroupedScatterPlot({
    super.key,
    required this.data,
    this.label,
    this.colors,
    this.dotSize = 3,
    this.showAxis = false,
    this.labelSize = 12,
    this.labelColor = Colors.black87,
    this.cordMax = 65535,
    required this.domainMapper,
    this.revertY = false,
  });

  @override
  Widget build(BuildContext context) {
    // print(widget.data);
    return Chart(
      padding: (s) => EdgeInsets.zero,
      data: data.keys
          .map((e) => ({
                'group': e,
                'x': 65535,
                'y': 65535,
                'cords': data[e],
              }))
          .toList(),
      variables: {
        'group': Variable(
          accessor: (Map datumn) => datumn['group'].toString(),
          scale: OrdinalScale(),
        ),
        'x': Variable(
          accessor: (Map datumn) => datumn['x'] as num,
          scale: LinearScale(min: 0, max: 65535),
        ),
        'y': Variable(
          accessor: (Map datumn) => datumn['y'] as num,
          scale: LinearScale(min: 0, max: 65535),
        ),
      },
      marks: [
        CustomMark(
          shape: ShapeEncode(
            value: GroupedScatterShape(
              domainMapper: domainMapper,
              pointsMap: data,
              strokeWidth: dotSize ?? 3,
              cordMax: cordMax,
              revertY: revertY,
            ),
          ),
          position: Varset('x') * Varset('y'),
          tag: (t) => t['group'],
          color: ColorEncode(
            variable: 'group',
            values: colors ?? Defaults.colors20,
            updaters: {
              'choose': {true: (_) => Colors.red},
              // 'tap': {false: (color) => color.withAlpha(100)}
            },
          ),
        )
      ],
      axes: [
        if (showAxis)
          AxisGuide(
            dim: Dim.x,
            line: Defaults.strokeStyle,
            label: null,
          ),
        if (showAxis)
          AxisGuide(
            dim: Dim.x,
            line: Defaults.strokeStyle,
            label: null,
            position: 1.0,
          ),
        if (showAxis)
          AxisGuide(
            dim: Dim.y,
            line: Defaults.strokeStyle,
            label: null,
          ),
        if (showAxis)
          AxisGuide(
            dim: Dim.y,
            line: Defaults.strokeStyle,
            label: null,
            position: 1.0,
          ),
        // Defaults.horizontalAxis,
        // Defaults.verticalAxis,
      ],
      // coord: RectCoord(horizontalRangeUpdater: Defaults.horizontalRangeEvent),
      coord: RectCoord(
          // horizontalRange: [.1, .9],
          // verticalRange: [0, .9],
          ),
      // tooltip: TooltipGuide(
      //   renderer: simpleTooltip,
      //   followPointer: [true, true],
      // ),
      // tooltip: TooltipGuide(),
      // selections: {
      //   // 'tap': PointSelection(variable: 'group', dim: Dim.x),
      //   'hover': PointSelection(variable: 'group', dim: Dim.x),
      // },
      selections: {
        'tooltipMouse': PointSelection(
          variable: 'x',
          on: {GestureType.tap},
          devices: {PointerDeviceKind.mouse},
          dim: Dim.x,
        ),
        'tooltipTouch': PointSelection(
          variable: 'x',
          on: {GestureType.scaleUpdate, GestureType.tapDown, GestureType.longPressMoveUpdate},
          devices: {PointerDeviceKind.touch},
          dim: Dim.x,
        ),
      },
      // crosshair: CrosshairGuide(followPointer: [true, true]),
      annotations: [
        if (label != null)
          TagAnnotation(
            label: Label(
              label,
              LabelStyle(textStyle: Defaults.textStyle.copyWith(fontSize: labelSize, color: labelColor), align: Alignment.center),
            ),
            anchor: (size) => size.topCenter(Offset(0, 10)),
          ),
      ],
    );
    // return ViolinPlot(data..sort());
//     return const Text('aaa');
  }
}
