import 'dart:ui';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/extensions/common_extensions.dart';
import 'package:flutter_smart_genome/extensions/d4_extension.dart';
import 'package:flutter_smart_genome/util/random_color/random_file.dart';
import 'package:d4/d4.dart' as d4;

List<LegendColor> legendColors = [
  LegendColor(name: "Rainbow", start: Colors.red, end: Colors.blue, interpolate: d4.interpolateRainbow),
  LegendColor(name: "Sinebow", start: Colors.red, end: Colors.blue, interpolate: d4.interpolateSinebow),
  // LegendColor(name: "RdYlBu", start: Colors.red, end: Colors.blue, interpolate: d4.interpolateRdYlBu),
  // LegendColor(name: "RdYlGn", start: Colors.red, end: Colors.green, interpolate: d4.interpolateRdYlGn),
  LegendColor(name: "Turbo", start: Colors.teal, end: Colors.orange, interpolate: d4.interpolateTurbo),
  LegendColor(name: "Viridis", start: Colors.green, end: Colors.red, interpolate: d4.interpolateViridis),
  LegendColor(name: "Warm", start: Colors.blue, end: Colors.red, interpolate: d4.interpolateWarm),
  LegendColor(name: "Plasma", start: Colors.red, end: Colors.blue, interpolate: d4.interpolatePlasma),
  // LegendColor(name: "Cividis", start: Colors.red, end: Colors.blue, interpolate: d4.interpolateCividis),
];

Color parseColor(String hex) {
  return d4.Color.tryParse(hex)!.flutterColor;
}

List<LegendColor> expressionLegendColors = [
  LegendColor(name: "Reds", start: parseColor(d4.schemeReds.last!.first), end: parseColor(d4.schemeReds.last!.last), interpolate: d4.interpolateReds),
  LegendColor(name: "Blues", start: parseColor(d4.schemeBlues.last!.first), end: parseColor(d4.schemeBlues.last!.last), interpolate: d4.interpolateBlues),
  LegendColor(name: "Greens", start: parseColor(d4.schemeGreens.last!.first), end: parseColor(d4.schemeGreens.last!.last), interpolate: d4.interpolateGreens),
  LegendColor(name: "Oranges", start: parseColor(d4.schemeOranges.last!.first), end: parseColor(d4.schemeOranges.last!.last), interpolate: d4.interpolateOranges),
  LegendColor(name: "Purples", start: parseColor(d4.schemePurples.last!.first), end: parseColor(d4.schemePurples.last!.last), interpolate: d4.interpolatePurples),
  LegendColor(name: "OrRd", start: parseColor(d4.schemeOrRd.last!.first), end: parseColor(d4.schemeOrRd.last!.last), interpolate: d4.interpolateOrRd),
  LegendColor(name: "YlOrRd", start: parseColor(d4.schemeYlOrRd.last!.first), end: parseColor(d4.schemeYlOrRd.last!.last), interpolate: d4.interpolateYlOrRd),
];

class LegendColor {
  late Color start;
  late Color end;

  String get startHex => d4.Rgb(start.red, start.green, start.blue, start.opacity).formatHex8(); // '#${start.hexString}';
  String get endHex => d4.Rgb(end.red, end.green, end.blue, end.opacity).formatHex8(); //'#${end.hexString}';

  late Function1<num, String> interpolate;

  String? name;

  double? min;
  double? max;

  LegendColor({
    required this.start,
    required this.end,
    this.name,
    this.min,
    this.max,
    required this.interpolate,
  });

  @override
  String toString() {
    return name ?? start.toString();
  }

  copyWith({Color? start, Color? end, Function1<num, String>? interpolate, double? min, double? max, String? name}) {
    return LegendColor(
      start: start ?? this.start,
      end: end ?? this.end,
      interpolate: interpolate ?? this.interpolate,
      min: min ?? this.min,
      max: max ?? this.max,
      name: name ?? this.name,
    );
  }
}
