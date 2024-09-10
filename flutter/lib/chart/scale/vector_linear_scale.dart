import 'dart:math' show Point;

import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_smart_genome/page/cell/cell_scatter_chart/l_rect.dart';
import 'package:vector_math/vector_math_64.dart' show Quad, Vector3, Matrix4;

class Vector3LinearScale {
  late Point3<double> _domainMin;
  late Point3<double> _domainMax;

  late Point3<double> _rangeMin;
  late Point3<double> _rangeMax;

  late ScaleLinear<num> _xScale;
  late ScaleLinear<num> _yScale;
  late ScaleLinear<num> _zScale;

  Vector3LinearScale({required Point3<double> domainMin, required Point3<double> domainMax, required Point3<double> rangeMin, required Point3<double> rangeMax}) {
    _domainMin = domainMin;
    _domainMax = domainMax;
    _rangeMin = rangeMin;
    _rangeMax = rangeMax;

    _xScale = ScaleLinear.number(
      domain: [_domainMin.x, _domainMax.x],
      range: [_rangeMin.x, _rangeMax.x],
    );
    _yScale = ScaleLinear.number(
      domain: [_domainMin.y, _domainMax.y],
      range: [_rangeMin.y, _rangeMax.y],
    );
    _zScale = ScaleLinear.number(
      domain: [_domainMin.z, _domainMax.z],
      range: [_rangeMin.z, _rangeMax.z],
    );
  }

  ScaleLinear<num> get xScale => _xScale;

  ScaleLinear<num> get yScale => _yScale;

  ScaleLinear<num> get zScale => _zScale;

  double get rangeX => _domainMax.x - _domainMin.x;

  double get rangeY => _domainMax.y - _domainMin.y;

  Point<double> scalePoint(num x, num y) {
    return Point(_xScale.scale(x)!, _yScale.scale(y)!);
  }

  Point<num> scaleByPoint(Point point) {
    return Point(_xScale.scale(point.x)!, _yScale.scale(point.y)!);
  }

  double scaleX(num x) {
    return _xScale.scale(x)!;
  }

  double scaleY(num y) {
    return _yScale.scale(y)!;
  }

  LRect revertLRect(LRect viewRect) {
    return LRect.LTRB(
      xScale.invert(viewRect.left).toDouble(),
      yScale.invert(viewRect.top).toDouble(),
      xScale.invert(viewRect.right).toDouble(),
      yScale.invert(viewRect.bottom).toDouble(),
    );
  }
}
