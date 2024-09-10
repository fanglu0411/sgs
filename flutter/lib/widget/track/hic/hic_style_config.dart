import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class HicStyleConfig extends StyleConfig {
  Color color;

  HicStyleConfig({
    super.featureWidth,
    super.lineColor,
    super.backgroundColor,
    super.selectedColor,
    super.brightness,
    Color? textColor,
    super.padding,
    required this.color,
  }) : super(

  );
}