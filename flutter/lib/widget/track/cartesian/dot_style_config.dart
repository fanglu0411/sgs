import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class DotStyleConfig extends StyleConfig {
  final Color color;

  DotStyleConfig({
    super.backgroundColor,
    super.borderColor,
    super.borderWidth,
    super.padding,
    super.brightness,
    super.selectedColor,
    super.primaryColor,
    this.color = Colors.green,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || super == other && other is DotStyleConfig && runtimeType == other.runtimeType && padding == other.padding && color == other.color;

  @override
  int get hashCode => super.hashCode ^ padding.hashCode ^ color.hashCode;
}