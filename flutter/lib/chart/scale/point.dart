import 'package:flutter/material.dart';

class Point3<T extends num> {
  late T x;
  late T y;
  late T z;

  Point3(this.x, this.y, this.z) {}

  Point3.xyz(this.x, this.y, this.z);

  operator /(num n) {
    return Point3.xyz(x / n, y / n, z / n);
  }

  Offset get offset {
    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  String toString() {
    return 'Point3{x: $x, y: $y, z: $z}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Point3 && runtimeType == other.runtimeType && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}
