import 'dart:ui';
import 'package:d4_scale/d4_scale.dart';

List<Color> colors(String specifier) {
  var n = specifier.length ~/ 6 | 0, i = 0;
  List<Color> colors = List.filled(n, Color(int.tryParse('fff')!));
  while (i < n) colors[i] = Color(int.tryParse('${specifier.substring(i * 6, ++i * 6)}', radix: 16)!);
  return colors;
}
