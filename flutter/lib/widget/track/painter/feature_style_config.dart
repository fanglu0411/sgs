import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/track/base/style_config.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';

class FeatureStyle {
  Color? color;
  late double height;
  late int alpha;

  late double borderWidth;
  late double radius;
  Color? borderColor;

  late bool visible;
  late String id;
  late String name;
  late bool isCustom;

  FeatureStyle({
    this.color,
    this.height = 1.0,
    this.alpha = 255,
    this.visible = true,
    this.borderColor = Colors.grey,
    this.radius = 0.0,
    this.borderWidth = 0.0,
    this.isCustom = false,
    required this.name,
    required this.id,
  });

  Color get colorWithAlpha => color!.withAlpha(alpha ?? 200);

  bool get hasBorder => borderWidth > 0 && borderColor != Colors.transparent;

  bool get hasRadius => radius > 0;

  static FeatureStyle basic() {
    return FeatureStyle(color: Colors.teal, alpha: 120, name: 'Base', id: 'base');
  }

  FeatureStyle copyWith({
    Color? color,
    double? height,
    int? alpha,
    bool? visible,
    double? radius,
    double? borderWidth,
    Color? borderColor,
    String? name,
    String? id,
  }) {
    return FeatureStyle(
      color: color ?? this.color,
      height: height ?? this.height,
      alpha: alpha ?? this.alpha,
      visible: visible ?? this.visible,
      radius: radius ?? this.radius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'FeatureStyle{color: $color, height: $height, alpha: $alpha, borderWidth: $borderWidth, radius: $radius, borderColor: $borderColor, visible: $visible}';
  }

  FeatureStyle.fromMap(Map map) {
    color = parseColor(map['color']);
    alpha = map['alpha'] ?? 200;
    height = _formatDouble(map['height'] ?? 1.0);
    visible = map['visible'] ?? true;
    borderWidth = _formatDouble(map['borderWidth'] ?? 0.0);
    borderColor = map['borderColor'] != null ? parseColor(map['borderColor']) : null;
    radius = _formatDouble(map['radius'] ?? 0.0);
    name = map['name'];
    id = map['id'];
    isCustom = map['isCustom'] ?? false;
  }

  double _formatDouble(num value) {
    if (value is double) return value;
    return value.toDouble();
  }

  Map toJson() {
    return {
      'color': color,
      'height': height,
      'alpha': alpha,
      'visible': visible,
      'radius': radius,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'id': id,
      'name': name,
      'isCustom': isCustom,
    };
  }

  Map<String, dynamic> toPersistJson() {
    return <String, dynamic>{
      'color': color?.value,
      'height': height,
      'alpha': alpha,
      'visible': visible,
      'radius': radius,
      'borderColor': borderColor?.value,
      'borderWidth': borderWidth,
      'id': id,
      'name': name,
      'isCustom': isCustom,
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is FeatureStyle && runtimeType == other.runtimeType && color == other.color && height == other.height && alpha == other.alpha && borderWidth == other.borderWidth && radius == other.radius && borderColor == other.borderColor && visible == other.visible;

  @override
  int get hashCode => color.hashCode ^ height.hashCode ^ alpha.hashCode ^ borderWidth.hashCode ^ radius.hashCode ^ borderColor.hashCode ^ visible.hashCode;
}

class FeatureStyleConfig extends StyleConfig {
//  final double featureWidth;
  final EdgeInsets padding;
  final Color blockBgColor;
  final Radius radius;
  final double labelFontSize;
  final bool showLabel;
  final bool showChildrenLabel;
  Color? textColor;
  Color? groupColor;
  Map<String, FeatureStyle> featureStyles;

  FeatureStyleConfig({
    required double featureWidth,
    this.padding = EdgeInsets.zero,
    this.blockBgColor = Colors.grey,
    Color? lineColor,
    Color? backgroundColor,
    Color? selectedColor,
    required Brightness brightness,
    this.radius = const Radius.circular(1),
    required this.featureStyles,
    this.labelFontSize = 10,
    this.showLabel = true,
    this.showChildrenLabel = false,
    this.groupColor,
    Color? textColor,
    Color? primaryColor,
  }) : super(
          backgroundColor: backgroundColor,
          featureWidth: featureWidth,
          brightness: brightness,
          lineColor: lineColor,
          selectedColor: selectedColor,
          primaryColor: primaryColor,
        ) {
    this.textColor = textColor ?? (brightness == Brightness.dark ? Colors.white : Colors.black87);
  }

  FeatureStyle operator [](type) {
    return this.featureStyles[type] ?? this.featureStyles['others'] ?? FeatureStyle.basic();
  }

  FeatureStyle? getFeatureStyle(type) {
    return this.featureStyles[type];
  }

  operator []=(String key, FeatureStyle featureStyle) {
    this.featureStyles[key] = featureStyle;
  }

  List<String> visibleFeatureTypes() {
    List<String> _fts = [];
    featureStyles.keys.forEach((element) {
      if (featureStyles[element]!.visible) {
        _fts.add(element);
      }
    });
    return _fts;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || super == other && other is FeatureStyleConfig && runtimeType == other.runtimeType && padding == other.padding && blockBgColor == other.blockBgColor && mapEquals(featureStyles, other.featureStyles);

  @override
  int get hashCode => super.hashCode ^ padding.hashCode ^ blockBgColor.hashCode ^ featureStyles.hashCode;

  @override
  String toString() {
    return 'FeatureStyleConfig{padding: $padding, blockBgColor: $blockBgColor, radius: $radius, labelFontSize: $labelFontSize, showLabel: $showLabel, featureStyles: ${featureStyles.hashCode}';
  }
}
