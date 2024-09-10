import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/graphic/core/custom_annotation.dart';
import 'package:graphic/graphic.dart';

class SimplePiePlot extends StatelessWidget {
  final List<Map> data;
  final String? typeKey;
  final List? types;
  final Color? labelColor;
  final List<Color>? colors;

  SimplePiePlot({
    super.key,
    required this.data,
    this.types,
    this.colors,
    this.typeKey = 'type',
    this.labelColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Chart(
      padding: (size) => EdgeInsets.all(20.0),
      data: data,
      variables: {
        typeKey!: Variable(
          accessor: (Map map) => map[typeKey!] as String,
        ),
        'value': Variable(
          accessor: (Map map) => map['value'] as num,
        ),
      },
      transforms: [
        Proportion(
          variable: 'value',
          as: 'percent',
        )
      ],
      marks: [
        IntervalMark(
          position: Varset('percent') / Varset(typeKey!),
          label: LabelEncode(
              encoder: (tuple) => Label(
                    tuple['value'].toString(),
                    LabelStyle(textStyle: Defaults.runeStyle),
                  )),
          color: ColorEncode(variable: typeKey, values: colors ?? Defaults.colors20, updaters: {}),
          modifiers: [StackModifier()],
          // transition: Transition(duration: Duration(milliseconds: 800)),
          entrance: {MarkEntrance.y},
        ),
        // IntervalMark(
        //   label: LabelEncode(encoder: (tuple) => Label(tuple[typeKey!].toString())),
        //   shape: ShapeEncode(
        //       value: RectShape(
        //     borderRadius: const BorderRadius.all(Radius.circular(10)),
        //   )),
        //   color: ColorEncode(variable: typeKey!, values: Defaults.colors10),
        //   elevation: ElevationEncode(value: 5),
        // )
      ],
      tooltip: TooltipGuide(followPointer: [true, true], selections: {'hover'}),
      selections: {
        'tap': PointSelection(variable: typeKey, on: {GestureType.tap}),
        'hover': PointSelection(
          // variable: typeKey,
          on: {GestureType.hover},
          clear: {GestureType.tap, GestureType.doubleTap, GestureType.mouseExit},
          devices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        // 'hover': PointSelection(variable: 'group', dim: Dim.x),
      },
      coord: PolarCoord(transposed: true, dimCount: 1, startRadius: .4),
      // coord: PolarCoord(startRadius: 0.15),
      annotations: types != null
          ? AnnotationBuilder(
              textStyle: Defaults.textStyle.copyWith(color: labelColor),
              colors: colors ?? Defaults.colors20,
              align: Alignment(.95, 0.0),
              types: types!,
              width: 400,
            ).build().$2
          : [],
    );
  }
}
