import 'dart:ui';

extension RectExtension on Rect {
  Rect inflateXY(double deltaX, double deltaY) {
    return Rect.fromLTRB(left - deltaX, top - deltaY, right + deltaX, bottom + deltaY);
  }

  Rect deflateXY(double deltaX, double deltaY) => inflateXY(-deltaX, -deltaY);
}
