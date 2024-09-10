import 'dart:ui' show Color;

import 'package:d4/d4.dart' as d4;
import 'package:dartx/dartx.dart' as dx;

extension D4ColorEetension on d4.Color {
  Color get flutterColor {
    d4.Rgb rgba = this.rgb();
    return Color.fromRGBO(rgba.r.toInt(), rgba.g.toInt(), rgba.b.toInt(), rgba.opacity.toDouble());
  }
}

List<Color> generateColors(int count, dx.Function1<num, String> interpolate) {
  var colorScale = d4.ScaleSequential(domain: [-.5, count], interpolator: interpolate);
  return List.generate(count, (index) {
    String c = colorScale.call(index)!;
    return d4.Color.tryParse(c)!.flutterColor;
  });
}
