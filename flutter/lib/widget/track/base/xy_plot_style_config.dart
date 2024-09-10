import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class XYPlotStyleConfig extends StyleConfig {
  Map<String, Color> colorMap;
  Color? blockBgColor;
  Radius radius;

  XYPlotStyleConfig({
    required this.colorMap,
    Color? borderColor,
    double borderWidth = 0,
    Color? backgroundColor,
    required Brightness brightness,
    EdgeInsets? padding,
    this.blockBgColor,
    Color? primaryColor,
    Color? selectedColor,
    this.radius = const Radius.circular(1),
  }) : super(
          backgroundColor: backgroundColor,
          brightness: brightness,
          padding: padding,
          selectedColor: selectedColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          primaryColor: primaryColor,
        );
}