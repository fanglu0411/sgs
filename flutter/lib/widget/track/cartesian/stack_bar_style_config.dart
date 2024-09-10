import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class StackBarStyleConfig extends StyleConfig {
  final Map<String, Color> colorMap;

  StackBarStyleConfig({
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1.0,
    this.colorMap = const {},
    Color? primaryColor,
    EdgeInsets padding = EdgeInsets.zero,
    Brightness brightness = Brightness.light,
    Color? selectedColor,
  }) : super(
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          padding: padding,
          brightness: brightness,
          selectedColor: selectedColor,
          primaryColor: primaryColor,
        );

  @override
  bool operator ==(Object other) => identical(this, other) || other is StackBarStyleConfig && runtimeType == other.runtimeType && padding == other.padding && colorMap == other.colorMap;

  @override
  int get hashCode => padding.hashCode ^ colorMap.hashCode;
}