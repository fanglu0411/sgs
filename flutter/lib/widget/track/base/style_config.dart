import 'package:flutter/material.dart';

class StyleConfig {
  EdgeInsets? padding;
  final Color? borderColor;
  final Color? primaryColor;
  final double borderWidth;
  final Color? backgroundColor;
  final double featureWidth;
  final Color? lineColor;
  final Brightness brightness;
  final Color selectedColor;
  final bool fixValue;

  StyleConfig({
    this.padding = EdgeInsets.zero,
    this.borderColor,
    this.borderWidth = 0,
    this.backgroundColor,
    this.featureWidth = .5,
    this.lineColor,
    this.primaryColor,
    this.brightness = Brightness.light,
    this.fixValue = false,
    Color? selectedColor,
  }) : this.selectedColor = selectedColor ?? (brightness == Brightness.dark ? Colors.white : Colors.purpleAccent);

  bool get isDark => this.brightness == Brightness.dark;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleConfig &&
          runtimeType == other.runtimeType &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          backgroundColor == other.backgroundColor &&
          featureWidth == other.featureWidth &&
          lineColor == other.lineColor &&
          padding == other.padding &&
          selectedColor == other.selectedColor &&
          brightness == other.brightness;

  @override
  int get hashCode =>
      borderColor.hashCode ^
      borderWidth.hashCode ^
      backgroundColor.hashCode ^
      featureWidth.hashCode ^
      lineColor.hashCode ^
      brightness.hashCode ^
      padding.hashCode ^
      selectedColor.hashCode ^
      primaryColor.hashCode;
}