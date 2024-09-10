import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class HicRelationConfig extends StyleConfig {
  HicRelationConfig({
    double featureWidth = 1.0,
    Color? lineColor,
    Color? backgroundColor,
    Color? selectedColor,
    Color? primaryColor,
    Brightness brightness = Brightness.light,
    Color? textColor,
    EdgeInsets padding = EdgeInsets.zero,
  }) : super(
          padding: padding,
          backgroundColor: backgroundColor,
          featureWidth: featureWidth,
          brightness: brightness,
          lineColor: lineColor,
          selectedColor: selectedColor,
          primaryColor: primaryColor,
        );
}