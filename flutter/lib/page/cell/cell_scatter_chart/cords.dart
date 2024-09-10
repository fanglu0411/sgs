import 'dart:typed_data';

class PlotCords {
  late Float32List _cords;

  late int length;

  PlotCords(int length) {
    this.length = length;
    _cords = Float32List(length * 2);
  }

  PlotCords scale(double scale) {
    int _width = 65536 ~/ scale;
    int _height = 65536 ~/ scale;

    var cords = PlotCords(_width * _height);
    List<double> __cords = [];
    int len = _cords.length;

    double x, y;
    int _x, _y;
    for (int i = 0; i < len; i++) {
      x = _cords[2 * i];
      y = _cords[2 * i + 1];

      _x = x ~/ scale;
      _y = y ~/ scale;
      cords._cords[_y * _width + _x] += 1;
    }

    return cords;
  }
}