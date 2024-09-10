import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/base/chart_theme.dart';

abstract class BasePainter extends CustomPainter {
  ChartTheme theme;
  BasePainter({
    required this.theme,
  }) : super();
}