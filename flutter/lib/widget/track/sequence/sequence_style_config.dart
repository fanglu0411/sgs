import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';

class SequenceStyleConfig extends StyleConfig {
  final double seqHeight;
  final EdgeInsets padding;
  final Color blockBgColor;
  final Color proteinColor1;
  final Color proteinColor2;
  final double proteinHeight;
  final double seqFontSize;

  final Map<String, Color> seqColor;

  SequenceStyleConfig({
    super.brightness,
    super.backgroundColor,
    this.seqHeight = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.blockBgColor = Colors.grey,
    this.proteinColor1 = Colors.cyan,
    this.proteinColor2 = Colors.cyanAccent,
    this.proteinHeight = 20,
    this.seqFontSize = 14,
    this.seqColor = const <String, Color>{
      'A': Colors.green,
      'T': Colors.red,
      'C': Colors.blue,
      'G': Colors.orange,
    },

  }) : super();
}