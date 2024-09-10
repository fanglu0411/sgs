import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/xy_plot_style_config.dart';

class BarStyleConfig extends XYPlotStyleConfig {
  final Color barColor;

  BarStyleConfig({
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 0,
    this.barColor = Colors.green,
    EdgeInsets padding = EdgeInsets.zero,
    Brightness brightness = Brightness.light,
    Color? primaryColor,
    Color? selectedColor,
    required Map<String, Color> colorMap,
  }) : super(
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          padding: padding,
          brightness: brightness,
          selectedColor: selectedColor,
          primaryColor: primaryColor,
          colorMap: colorMap,
        );

  @override
  bool operator ==(Object other) => identical(this, other) || other is BarStyleConfig && runtimeType == other.runtimeType && padding == other.padding && barColor == other.barColor;

  @override
  int get hashCode => padding.hashCode ^ barColor.hashCode;
}