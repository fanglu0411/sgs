import 'dart:ui';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/chart/graphic/shape/violin_shape.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/util/random_color/random_file.dart';
import 'dart:math' as math;

import 'package:graphic/graphic.dart';

class ViolinParser<T> {
  List<T> data;
  Function1<T, double> valueMapper;

  ViolinParser(this.data, {required this.valueMapper});

  Future<Map> computeParse() async {
    List<double> _data = data.map<double>(valueMapper).toList();
    var __d = await compute(_computeFunc, _data);
    return __d;
  }

  Map _computeFunc(List<double> _data) {
    _data.sort();

    final q1 = _quantile(_data, 0.25);
    final q2 = _quantile(_data, 0.5);
    final q3 = _quantile(_data, 0.75);
    final min = _data.min()!;
    final max = _data.max()!;

    // 计算IQR
    final iqr = q3 - q1;

    // 计算核密度估计
    var kde = KernelDensityEstimation();

    int num = 100;
    final step = (max - min) / num;

    List<Offset> _d = [];
    for (int i = 0; i < num; i++) {
      final y = min + step * i;
      // final x = kde.estimate(_data, y);
      final x = _kernelDensityEstimation(y, _data, iqr);
      // print('$x - ${i == 0 ? '' : _d.last.dx}');
      if (_d.length == 0 || _deceimal((_d.last.dx - x).abs())) {
        _d.add(Offset(x, y));
      }
    }

    // print('min:$min, max:$max');
    // print(_d);

    return {
      'q1': q1,
      'mean': q2,
      'q3': q3,
      'min': min,
      'max': max,
      'density': _d,
    };
  }

  Map parse() {
    List<double> _data = data.map<double>(valueMapper).toList();
    return _computeFunc(_data);
  }

  bool _deceimal(double abs) {
    if (abs == 0) return false;
    if (abs > 1) return abs > 1;

    int e = 0;
    var n = abs;
    while (n < 1) {
      n *= 10;
      e++;
    }
    return abs > 1 / math.pow(10, e);
  }

  double _quantile(List<double> data, double fraction) {
    final pos = (data.length - 1) * fraction;
    final base = pos.floor();
    final rest = pos - base;
    if (rest.isNaN || rest == 0) {
      return data[base];
    } else {
      return data[base] + rest * (data[base + 1] - data[base]);
    }
  }

  double _kernelDensityEstimation(double x, List<double> data, double iqr) {
    final n = data.length;
    final bandwidth = 1.5 * iqr / math.pow(n, 1 / 3);

    return (1 / (n * bandwidth)) * data.map((xVal) => math.exp(-math.pow(xVal - x, 2) / math.pow(bandwidth, 2))).reduce((a, b) => a + b);
  }
}

class KernelDensityEstimation {
  // 核密度估计
  double estimate(List<double> data, double x) {
    return _kde(data, x);
  }

  // 高斯核
  double _gaussianKernel(double x, double x0, double h) {
    return (1 / (math.sqrt(2 * math.pi) * h)) * math.exp(-0.5 * math.pow((x - x0) / h, 2));
  }

  double _kde(List<double> data, double x) {
    // 默认使用高斯核
    return _kdeWithKernel(data, x, _gaussianKernel);
  }

  double? _standardDeviation;

  // 通过自定义核函数实现核密度估计
  double _kdeWithKernel(List<double> data, double x, double kernel(double x, double x0, double h)) {
    // 默认窗口宽度是数据标准差
    final n = data.length;
    _standardDeviation ??= standardDeviation(data);
    final h = math.sqrt(n) * _standardDeviation!;

    double density = 0.0;
    for (double x0 in data) {
      density += kernel(x, x0, h);
    }

    return density / (n * h);
  }

  // 计算标准差
  double standardDeviation(List<double> data) {
    final n = data.length;
    final mean = data.reduce((a, b) => a + b) / n;
    return math.sqrt(data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / (n - 1));
  }
}

/// data [{q1, mean, q3, min, max, density}]
class ViolinPlot extends StatelessWidget {
  final List<Map> data;
  final String? label;
  final double? max;
  final double? min;
  final double labelSize;
  final Color? labelColor;
  final List<Color>? colors;
  final bool dark;

  const ViolinPlot({
    super.key,
    required this.data,
    this.label,
    this.max,
    this.min,
    this.labelSize = 12,
    this.labelColor = Colors.black87,
    this.colors,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    double _max = max ?? data.map((e) => e['max']).toList().max() * 1.2;
    double _min = min ?? data.map((e) => e['min']).toList().min() * 0.8;
    Map<String, List<Offset>> pathPoints = Map.fromIterables(data.map((e) => '${e['group']}'), data.map((e) => e['density']));
    var _colors = colors ?? (pathPoints.length <= 10 ? Defaults.colors10 : (Defaults.colors20));

    List<String> xLabels = data.groupBy((e) => '${e['group']}').keys.toList();
    double maxLabelWidth = (xLabels.maxBy((e) => '${e}'.length)?.length ?? 0) * 10 * .65;

    double _itemWidth = (constraints.biggest.width / xLabels.length) * .9;
    double? labelRotation = maxLabelWidth > _itemWidth ? math.pi * 1.8 : null;

    bool labelAutoHide = constraints.biggest.width < 500;
    double xLabelHeight = labelRotation == null ? 30.0 : (math.sin(math.pi / 4) * maxLabelWidth);
    if (xLabelHeight < 30) xLabelHeight = 30.0;

    return Chart(
      data: data,
      padding: (s) => EdgeInsets.only(left: 40, bottom: xLabelHeight, top: 20),
      variables: {
        'group': Variable(
          accessor: (Map datumn) => datumn['group'].toString(),
          scale: OrdinalScale(),
        ),
        'q1': Variable(
          accessor: (Map datumn) => datumn['q1'] as num,
          scale: LinearScale(min: _min, max: _max),
        ),
        'mean': Variable(
          accessor: (Map datumn) => datumn['mean'] as num,
          scale: LinearScale(min: _min, max: _max),
        ),
        'q3': Variable(
          accessor: (Map datumn) => datumn['q3'] as num,
          scale: LinearScale(min: _min, max: _max),
        ),
        'max': Variable(
          accessor: (Map datumn) => datumn['max'] as num,
          scale: LinearScale(min: _min, max: _max),
        ),
        'min': Variable(
          accessor: (Map datumn) => datumn['min'] as num,
          scale: LinearScale(min: _min, max: _max),
        ),
      },
      marks: [
        CustomMark(
          shape: ShapeEncode(value: ViolinShape(pathPoints: pathPoints, max: _max)),
          position: Varset('group') * (Varset('q1') + Varset('mean') + Varset('q3') + Varset('min') + Varset('max')),
          tag: (t) => t['group'],
          color: ColorEncode(
            // value: Colors.green,
            variable: 'group',
            values: _colors,
            updaters: {
              'hover': {false: (color) => color.withAlpha(100)}
            },
          ),
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
          // tickLine: TickLine(length: 4, style: PaintStyle(strokeColor: labelColor, strokeWidth: 1)),
          grid: PaintStyle(strokeWidth: 1.0, strokeColor: labelColor?.withOpacity(.1)),
          label: LabelStyle(
            textStyle: Defaults.textStyle.copyWith(color: labelColor, fontSize: 10),
            offset: const Offset(-7.5, 0),
          ),
          // line: PaintStyle(strokeColor: Colors.black54, strokeWidth: 1),
        ),
      ],
      coord: RectCoord(),
      tooltip: TooltipGuide(renderer: simpleTooltip, selections: {'hover'}),
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
      crosshair: CrosshairGuide(),
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
      var value;
      for (var i = 0; i < fields.length; i++) {
        value = original[fields[i]];
        if (value is num) value = value.toStringAsFixed(4);
        textContent += '${fields[i].padRight(5)}: ${value}';
        if (i < fields.length - 1) textContent += '\n';
      }
    } else {
      for (var original in selectedTupleList) {
        final domainField = fields.first;
        var measureField = fields.last;
        textContent += '\n${original[domainField]}: ${original[measureField]}';
      }
    }

    var textStyle = TextStyle(
      fontSize: 13,
      color: dark ? Colors.white : Colors.black87,
      fontFamily: MONOSPACED_FONT,
      fontFamilyFallback: MONOSPACED_FONT_BACK,
    );
    const padding = EdgeInsets.all(10);
    const align = Alignment.topRight;
    const offset = Offset(15, -5);
    const elevation = 5.0;
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

class KernelDensityEstimator {
  final double bandwidth;
  final List<double> data;

  KernelDensityEstimator({required this.bandwidth, required this.data});

  double gaussian(double x) {
    return math.exp(-math.pow(x, 2) / 2) / math.sqrt(2 * math.pi);
  }

  double estimateDensity(double point) {
    double sum = 0.0;
    for (var d in data) {
      var dx = d - point;
      sum += gaussian(dx / bandwidth);
    }
    return sum / (data.length * bandwidth);
  }
}
