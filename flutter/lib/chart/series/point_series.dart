import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_genome/chart/base/chart_theme.dart';
import 'package:flutter_smart_genome/chart/common/common.dart';
import 'package:flutter_smart_genome/chart/scale/vector_scale_ext.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:flutter_smart_genome/chart/series/xy_series.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';

class PointSeries<T, D> extends XySeries<T, D> {
  PointSeries({
    required List<T> dataSource,
    required ChartValueMapper<T, D> xValueMapper,
    required ChartValueMapper<T, num> yValueMapper,
    required ChartValueMapper<T, Color> pointColorMapper,
    required this.scale,
  }) : super(
          dataSource: dataSource,
          xValueMapper: xValueMapper,
          yValueMapper: yValueMapper,
          pointColorMapper: pointColorMapper,
        ) {
    type = 'point';
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
  }

  Vector3LinearScale scale;

  Paint? _paint;

  @override
  List<T> get visibleDataSource {
    var x, y;
    return dataSource!.where((T t) {
      x = xValueMapper(t, 0) as num;
      y = yValueMapper(t, 0);
      // print(Offset(x, y));

      var offset = scale.scaleXY(x, y);
      return visibleRange!.contains(offset);
    }).toList();
  }

  @override
  void render(Canvas canvas, Offset offset, Size size, ChartTheme theme) {
    if (dataSource == null || dataSource!.isEmpty) {
      return;
    }
    double _scale = matrix4!.getMaxScaleOnAxis();
    // canvas.save();
    // Offset trans = offset / scale;
    // print(trans);
    // canvas.translate(trans.dx, trans.dy);

//    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), _paint..color = Colors.grey);

    // Iterable<num> values = dataSource.mapIndexed((i, e) => yValueMapper(e, i));
    // num max = values.reduce(math.max);
    // double yScale = size.height / max;

    double x = 0, y = 0, radius = 1.5, _radius;
    Color color;
    Path path = Path();
    // _paint..color = theme.color;
    // final _start = DateTime.now();
    // print(_start);
    List<T> _visibleDataSource = visibleDataSource;
    Offset _hover = hover!.transformInvert(matrix4!);

    Rect rect;
    Offset point;
    for (int i = 0; i < _visibleDataSource.length; i++) {
      // Color color = pointColorMapper(dataSource[i], i);
      x = xValueMapper(_visibleDataSource[i], i) as double;
      y = yValueMapper(_visibleDataSource[i], i) as double;

      color = pointColorMapper(_visibleDataSource[i], i);

      //这里因为画布已经被painter做了matrix变换，所以只做 value 到 位置映射，不再做matrix变换
      point = scale.scaleXY(x, y);
      // point = point.transform(matrix4);

      // point = Offset(x, y); //.transform(Matrix4.inverted(matrix4));

      if (_scale > 1) {
        _radius = radius / _scale;
      } else if (_scale < 1) {
        _radius = radius * _scale;
      } else {
        _radius = radius;
      }

      rect = Rect.fromCircle(center: point, radius: _radius);
      if (rect.contains(_hover)) {
        canvas.drawCircle(point, _radius * 2, _paint!..color = color);
      } else {
        // canvas.drawCircle(Offset(x, y), radius, _paint..color = color);
        canvas.drawOval(rect, _paint!..color = color);
      }
      // path.addOval(Rect.fromCenter(center: Offset(x, y), width: 4, height: 4));
    }
  }
}
