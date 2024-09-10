import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class RulerStyleConfig extends StyleConfig {
  final Color tickerColor;

  RulerStyleConfig({
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 0,
    required this.tickerColor,
  }) : super(
    backgroundColor: backgroundColor,
    borderColor: borderColor,
    borderWidth: borderWidth,
  );
}