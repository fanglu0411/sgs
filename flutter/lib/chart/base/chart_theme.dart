import 'package:flutter/material.dart';

class ChartTheme {
  final Brightness brightness;
  final Color color;
  final Color backgroundColor;

  const ChartTheme({required this.brightness, required this.color, required this.backgroundColor});

  static ChartTheme light({required Color color}) {
    return ChartTheme(
      brightness: Brightness.light,
      color: color,
      backgroundColor: Colors.white,
    );
  }

  static ChartTheme dark({required Color color}) {
    return ChartTheme(
      brightness: Brightness.dark,
      color: color,
      backgroundColor: Colors.black26,
    );
  }

  @override
  String toString() {
    return 'ChartTheme{brightness: $brightness, color: $color, backgroundColor: $backgroundColor}';
  }
}
