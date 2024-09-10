import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class CellExpStyleConfig extends StyleConfig {
  Map<String, Color> colorMap;
  final double labelFontSize;
  final bool showLabel;
  final Color labelColor;
  final double barWidth;

  CellExpStyleConfig({
    super.featureWidth,
    super.lineColor,
    super.backgroundColor,
    super.selectedColor,
    super.brightness,
    super.primaryColor,
    super.padding,
    this.showLabel = true,
    this.labelFontSize = 12,
    required this.labelColor,
    required this.colorMap,
    this.barWidth = 4.0,
  });
}