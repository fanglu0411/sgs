import 'package:flutter/material.dart';

import '../scale_chromatic/sequential_single.dart';

List<Color> safeSchemeColor(int count, {double s = 1.0, double v = 1.0}) {
  return schemeRainbow(count, s: s, v: v);
}

List<Color> schemeRainbow(int count, {double s = 1.0, double v = 1.0}) {
  var step = 360 / (count);
  return List.generate(count, (index) => interpolateRainbow(step * index, s: s, v: v));
}

List<Color> schemeRainbowLight(int count) {
  return schemeRainbow(count, s: 1.0, v: .75);
}

List<Color> schemeRainbowDark(int count) {
  return schemeRainbow(count, s: .8, v: .65);
}

List<Color> schemeRed(int count) {
  var step = 1 / (count - 1);
  return List.generate(count, (index) => interpolateRed(step * index));
}

List<Color> schemeGreen(int count) {
  var step = 1 / (count - 1);
  return List.generate(count, (index) => interpolateGreen(step * index));
}

List<Color> schemeBlue(int count) {
  var step = 1 / (count - 1);
  return List.generate(count, (index) => interpolateBlue(step * index));
}

List<Color> schemeOrange(int count) {
  var step = 1 / (count - 1);
  return List.generate(count, (index) => interpolateOrange(step * index));
}

List<Color> schemeTeal(int count) {
  var step = 1 / (count - 1);
  return List.generate(count, (index) => interpolateTeal(step * index));
}

List<Color> schemeColors(List<Color> colors, int count) {
  assert(colors.length == 2);
  var step = 1 / (count - 1);
  return List.generate(count, (index) => interpolateMultiColor(colors.first, colors.last, step * index));
}

List<Color> schemeGreenOrg(int count) {
  return schemeColors([Colors.green, Colors.orange], count);
}

List<Color> schemeBlueOrg(int count) {
  return schemeColors([Colors.blue, Colors.orange], count);
}

List<Color> schemeTealOrg(int count) {
  return schemeColors([Colors.teal, Colors.orange], count);
}

List<Color> schemeGreenRed(int count) {
  return schemeColors([Colors.green, Colors.red], count);
}

List<Color> schemeBlueRed(int count) {
  return schemeColors([Colors.blue, Colors.red], count);
}
