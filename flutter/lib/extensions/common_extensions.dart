import 'dart:math' show min;
import 'package:flutter/material.dart';

Color? parseColor(var value) {
  if (value is int) {
    return Color(value);
  }
  if (value is String) {
    return Color(int.parse(value, radix: 16));
  }
  if (value is Color) {
    return value;
  }
  return null;
}

MaterialColor materialColor(Color color) {
  return MaterialColor(color.value, {
    050: _genColor(color, 0.05),
    100: _genColor(color, 0.2),
    200: _genColor(color, 0.4),
    300: _genColor(color, 0.6),
    400: _genColor(color, 0.8),
    500: _genColor(color, 1.0),
    600: _genColor(color, 1.2),
    700: _genColor(color, 1.4),
    800: _genColor(color, 1.6),
    900: _genColor(color, 1.8),
  });
}

Color _genColor(Color color, double shade) {
  var hue = HSVColor.fromColor(color);
  if (shade > 1.0) {
    return hue.withValue(min(1, (shade - 2).abs())).toColor();
  } else {
    return hue.withSaturation(shade).withValue(1).toColor();
  }
}

Color parseHexColor(String hex) {
  hex = hex.replaceAll('#', '');
  String pad = 'ff';
  if (hex.length == 8) {
    pad = hex.substring(6);
    hex = hex.substring(0, 6);
  }
  return Color(int.tryParse(hex.padLeft(8, pad), radix: 16)!);
}

extension ColorExtensions on Color {
  String get hexString => this.value.toRadixString(16).padLeft(8, '0');

  static Color fromHex(String hex) {
    return Color(int.tryParse('ff${hex.replaceAll('#', '')}', radix: 16)!);
  }
}

extension IteratorExtension<T> on Iterable<T> {
  Iterable<T> divideBy<E extends T>(E divider) {
    if (this.isEmpty || this.length == 1) {
      return this;
    }
    List _list = this.toList();
    List<E> result = [];
    int count = this.length;
    for (int i = 0; i < count; i++) {
      result.add(_list[i]);
      if (i < count - 1) {
        result.add(divider);
      }
    }
    return result;
  }
}