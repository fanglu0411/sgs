import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class HeatMapStyleConfig extends StyleConfig {
  final Color lightColor;
  final Color heatColor;

  HeatMapStyleConfig({
    super.backgroundColor,
    super.borderColor,
    super.borderWidth,
    this.lightColor = Colors.yellow,
    this.heatColor = Colors.red,
    super.padding,
    super.brightness,
    super.selectedColor,
    super.primaryColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          super == other && other is HeatMapStyleConfig && runtimeType == other.runtimeType && padding == other.padding && lightColor == other.lightColor && heatColor == other.heatColor;

  @override
  int get hashCode => super.hashCode ^ padding.hashCode ^ lightColor.hashCode ^ heatColor.hashCode;
}