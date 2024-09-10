import 'dart:ui';
import 'dart:math';

Color interpolateColor(Color from, Color to, double elapsed) {
  double r, g, b, a;
  double speed = min(1.0, elapsed * 5.0);
  double c = to.alpha.toDouble() - from.alpha.toDouble();
  if (c.abs() < 1.0) {
    a = to.alpha.toDouble();
  } else {
    a = from.alpha + c * speed;
  }

  c = to.red.toDouble() - from.red.toDouble();
  if (c.abs() < 1.0) {
    r = to.red.toDouble();
  } else {
    r = from.red + c * speed;
  }

  c = to.green.toDouble() - from.green.toDouble();
  if (c.abs() < 1.0) {
    g = to.green.toDouble();
  } else {
    g = from.green + c * speed;
  }

  c = to.blue.toDouble() - from.blue.toDouble();
  if (c.abs() < 1.0) {
    b = to.blue.toDouble();
  } else {
    b = from.blue + c * speed;
  }

  return Color.fromARGB(a.round(), r.round(), g.round(), b.round());
}

String formatStart(num start) {
  String label;
  int valueAbs = start.round().abs();
  if (valueAbs > 1000000000) {
    double v = (valueAbs / 100000000.0).floorToDouble() / 10.0;

    label = (valueAbs / 1000000000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) + "B";
  } else if (valueAbs > 1000000) {
    double v = (valueAbs / 100000.0).floorToDouble() / 10.0;
    label = (valueAbs / 1000000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) + "M";
  } else if (valueAbs > 10000) // N.B. < 10,000
      {
    double v = (valueAbs / 100.0).floorToDouble() / 10.0;
    label = (valueAbs / 1000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) + "T";
  } else {
    label = valueAbs.toStringAsFixed(0);
  }
  return label;
}

class TrackLineBackgroundColor {
  Color? color;
  double? start;
}

class TickColors {
  Color? background;
  Color? long;
  Color? short;
  Color? text;
  double? start;
  double? screenY;
}

class HeaderColors {
  Color? background;
  Color? text;
  double? start;
  double? screenY;
}