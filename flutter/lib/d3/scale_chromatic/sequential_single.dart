import 'package:flutter/material.dart';

var c = HSVColor.fromAHSV(1.0, 0, 1.0, 1.0);

final List<Color> rainbowColors = [
  const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
];

Color interpolateRainbow(double hue, {double s = 1.0, double v = 1.0}) {
  return HSVColor.fromAHSV(1.0, hue.clamp(0.0, 360.0), s, v).toColor();
}

Color interpolateBlue(double sat) {
  return interceptSingleColor(Colors.blue.shade900, sat);
}

Color interpolateRed(double t) {
  return interceptSingleColor(Colors.red.shade900, t);
  // return ramp(redSchema);
}

Color interpolateGreen(double sat) {
  return interceptSingleColor(Colors.green.shade900, sat);
}

Color interpolateOrange(double sat) {
  return interceptSingleColor(Colors.orange.shade900, sat);
}

Color interpolateIndigo(double sat) {
  return interceptSingleColor(Colors.indigo.shade900, sat);
}

Color interpolateTeal(double sat) {
  return interceptSingleColor(Colors.teal.shade900, sat);
}

Color interpolateRedBlue(double t) {
  return interpolateMultiColor(Colors.red.shade900, Colors.blue.shade900, t);
}

Color interceptSingleColor(Color color, double t) {
  return HSVColor.fromColor(color).withSaturation(t.clamp(0.0, 1.0)).toColor();
}

Color interpolateMultiColor(Color a, Color b, double t) {
  return Color.lerp(a, b, t)!;
}