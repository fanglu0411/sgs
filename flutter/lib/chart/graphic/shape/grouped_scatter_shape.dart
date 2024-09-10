import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/graphic/element/points_element.dart';
import 'package:graphic/graphic.dart';

/// A candle stick shape.
///
/// The points order of measure dimension is appointed as:
///
/// ```
/// [star, end, max, min]
/// ```
///
/// And the end point is regarded as represent point.
///
/// ** We insist that the price of a subject matter of investment is determined
/// by its intrinsic value. Too much attention to the short-term fluctuations in
/// prices is harmful. Thus a candlestick chart may misslead your investment decision.**
class GroupedScatterShape extends Shape {
  /// Creates a candle stick shape.

  GroupedScatterShape({
    required this.domainMapper,
    this.strokeWidth = 3,
    required this.pointsMap,
    required this.cordMax,
    this.revertY = false,
  });

  final num Function(num value) domainMapper;

  /// The stroke width of the stick.
  final double strokeWidth;

  final Map<String, List> pointsMap;

  final num cordMax;
  final bool revertY;

  @override
  bool equalTo(Object other) => other is GroupedScatterShape && strokeWidth == other.strokeWidth;

  @override
  double get defaultSize => 15;

  @override
  List<MarkElement> drawGroupPrimitives(List<Attributes> group, CoordConv coord, Offset origin) {
    assert(coord is RectCoordConv);
    assert(!coord.transposed);

    final primitives = <MarkElement>[];

    // for (var item in group) {
    //   print('${item.tag} - ${item.index}- ${item.position}- ${item.color}');
    // }

    for (var item in group) {
      // print('${item.tag} - ${item.index}- ${item.position}- ${item.color}');
      // print('${item.tag} - ${item.index}- ${item.position}');
      // assert(item.shape is GroupedScatterShape);

      List? cords = pointsMap[item.tag];
      if (cords == null) continue;

      final style = getPaintStyle(item, true, strokeWidth, null, null);

      final points = cords
          .map((p) => coord.convert(
                Offset(domainMapper(p[2]) / cordMax, revertY ? (1.0 - domainMapper(p[3]) / cordMax) : domainMapper(p[3]) / cordMax),
              ))
          .toList();

      // print(points);
      var ps = Float32List(points.length * 2);
      int i = 0;
      for (var p in points) {
        ps[i++] = p.dx;
        ps[i] = p.dy;
        i++;
      }
      primitives.add(PointsElement(points: ps, style: style));
    }

    return primitives;
  }

  @override
  List<MarkElement> drawGroupLabels(List<Attributes> group, CoordConv coord, Offset origin) => [];

  @override
  Offset representPoint(List<Offset> position) => position[0];
}
