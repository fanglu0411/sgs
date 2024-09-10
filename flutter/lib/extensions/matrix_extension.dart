import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;

extension MatrixExtension on Matrix4 {
  Vector3 getScale([bool y = false, bool z = false]) {
    final scaleXSq = storage[0] * storage[0] + storage[1] * storage[1] + storage[2] * storage[2];
    final scaleYSq = storage[4] * storage[4] + storage[5] * storage[5] + storage[6] * storage[6];
    final scaleZSq = storage[8] * storage[8] + storage[9] * storage[9] + storage[10] * storage[10];

    final scaleX = math.sqrt(scaleXSq);
    final scaleY = math.sqrt(scaleYSq);
    final scaleZ = math.sqrt(scaleZSq);
    return Vector3(scaleX, scaleY, scaleZ);
  }

  double getScaleX() {
    return getScale(false, true).x;
  }

  double getScaleY() {
    return getScale(false, true).y;
  }

  double getScaleZ() {
    return getScale(false, true).z;
  }
}
