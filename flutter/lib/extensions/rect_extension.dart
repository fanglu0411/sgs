import 'package:flutter/material.dart';
import 'dart:math' show max, min;
import 'package:vector_math/vector_math_64.dart' show Quad, Vector3, Matrix4;

extension RectExtensions on Rect {
  /// Returns a new rectangle with edges moved outwards by the given delta.
  Rect inflateXY(double deltaX, double deltaY) {
    return Rect.fromLTRB(left - deltaX, top - deltaY, right + deltaX, bottom + deltaY);
  }

  /// Returns a new rectangle with edges moved inwards by the given delta.
  Rect deflateXY(double deltaX, double deltaY) => inflateXY(-deltaX, -deltaY);

  Rect intersectHorizontal(Rect other) {
    if (left < other.left || right > other.right) {
      return Rect.fromLTRB(
        max(left, other.left),
        top,
        min(right, other.right),
        bottom,
      );
    }
    return this;
  }

  bool overlapsHorizontal(Rect other) {
    if (right <= other.left || other.right <= left) return false;
    return true;
  }

  Rect transform(Matrix4 matrix) {
    final Matrix4 inverseMatrix = matrix.clone()..invert();
    Quad quad = Quad.points(
      inverseMatrix.transform3(Vector3(
        this.topLeft.dx,
        this.topLeft.dy,
        0.0,
      )),
      inverseMatrix.transform3(Vector3(
        this.topRight.dx,
        this.topRight.dy,
        0.0,
      )),
      inverseMatrix.transform3(Vector3(
        this.bottomRight.dx,
        this.bottomRight.dy,
        0.0,
      )),
      inverseMatrix.transform3(Vector3(
        this.bottomLeft.dx,
        this.bottomLeft.dy,
        0.0,
      )),
    );
    return Rect.fromLTRB(quad.point0.x, quad.point0.y, quad.point2.x, quad.point2.y);
  }
}

extension OffsetExtensions on Offset {
  Offset minLeft([double left = 0]) {
    if (dx < left) return Offset(left, dy);
    return this;
  }

  Offset transform(Matrix4 matrix) {
    final Vector3 untransformed = matrix.transform3(Vector3(
      this.dx,
      this.dy,
      0,
    ));
    return Offset(untransformed.x, untransformed.y);
  }

  Offset transformInvert(Matrix4 matrix) {
    // On viewportPoint, perform the inverse transformation of the scene to get
    // where the point would be in the scene before the transformation.
    // final Matrix4 inverseMatrix = matrix.clone()..invert();
    final Matrix4 inverseMatrix = Matrix4.inverted(matrix);
    final Vector3 untransformed = inverseMatrix.transform3(Vector3(
      this.dx,
      this.dy,
      0,
    ));
    return Offset(untransformed.x, untransformed.y);
  }
}
