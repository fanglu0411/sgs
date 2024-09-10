import 'dart:math';

class LRect {
  late double left, right, top, bottom;

  /// The distance between the left and right edges of this rectangle.
  double get width => right - left;

  /// The distance between the top and bottom edges of this rectangle.
  double get height => bottom - top;

  LRect.LTWH(this.left, this.top, double width, double height) {
    this.right = left + width;
    this.bottom = top + height;
  }

  LRect.LTRB(this.left, this.top, this.right, double this.bottom);

  Point<double> get center => Point(left + width / 2.0, top + height / 2.0);

  bool contains(Point offset) {
    return offset.x >= left && offset.x < right && offset.y >= top && offset.y < bottom;
  }

  LRect.fromCenter({required Point center, required double width, required double height})
      : this.LTRB(
          center.x - width / 2,
          center.y - height / 2,
          center.x + width / 2,
          center.y + height / 2,
        );
}
