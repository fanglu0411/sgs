import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class LinearStyleConfig extends StyleConfig {
  final Color color;

  LinearStyleConfig({
    super.backgroundColor,
    super.borderColor,
    super.borderWidth = 1.5,
    this.color = Colors.green,
    super.padding,
    super.brightness,
    super.selectedColor,
    super.primaryColor,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || super == other && other is LinearStyleConfig && runtimeType == other.runtimeType && padding == other.padding && color == other.color;

  @override
  int get hashCode => super.hashCode ^ padding.hashCode ^ color.hashCode;
}