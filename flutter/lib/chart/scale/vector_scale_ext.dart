import 'dart:ui';
import 'package:d4/d4.dart';
import 'package:flutter_smart_genome/chart/scale/point.dart';
import 'package:flutter_smart_genome/chart/scale/vector_linear_scale.dart';
import 'package:flutter_smart_genome/extensions/rect_extension.dart';
import 'package:vector_math/vector_math_64.dart' show Quad, Vector3, Matrix4;

extension ScaleMixin on Vector3LinearScale {
  Point3<double> scale(Point3 value) {
    return Point3.xyz(xScale.call(value.x)!.toDouble(), yScale.call(value.y)!.toDouble(), zScale.call(value.z)!.toDouble());
  }

  Offset scaleOffset(Offset offset) {
    return Offset(xScale.call(offset.dx)!.toDouble(), yScale.call(offset.dy)!.toDouble());
  }

  Offset scaleXY(num x, num y) {
    return Offset(xScale.call(x)!.toDouble(), yScale.call(y)!.toDouble());
  }

  Point3 revert(Point3<double> view) {
    return Point3.xyz(xScale.invert(view.x), yScale.invert(view.y), zScale.invert(view.z));
  }

  Offset revertOffset(Offset view) {
    return Offset(xScale.invert(view.dx).toDouble(), yScale.invert(view.dy).toDouble());
  }

  Point3 revertXY(Offset view) {
    return Point3.xyz(xScale.invert(view.dx), yScale.invert(view.dy), 0);
  }

  /// domain range rect
  Rect revertRect(Rect viewRect) {
    return Rect.fromLTRB(
      xScale.invert(viewRect.topLeft.dx).toDouble(),
      yScale.invert(viewRect.topLeft.dy).toDouble(),
      xScale.invert(viewRect.bottomRight.dx).toDouble(),
      yScale.invert(viewRect.bottomRight.dy).toDouble(),
    );
  }

  Offset scaleAndTransform(Point3 value, Matrix4 matrix) {
    Point3<double> offset = scale(value);
    return transform(Offset(offset.x, offset.y), matrix);
  }

  Offset transform(Offset offset, Matrix4 matrix) {
    return offset.transform(matrix);
  }
}
