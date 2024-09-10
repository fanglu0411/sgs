import 'dart:ui';
import 'package:dartx/dartx.dart';
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
class ViolinShape extends Shape {
  /// Creates a candle stick shape.

  ViolinShape({
    this.hollow = true,
    this.strokeWidth = 1,
    required this.max,
    required this.pathPoints,
  });

  /// whether the sticks are hollow.
  final bool hollow;

  /// The stroke width of the stick.
  final double strokeWidth;

  final double max;
  final Map<String, List<Offset>> pathPoints;

  @override
  bool equalTo(Object other) => other is ViolinShape && hollow == other.hollow && strokeWidth == other.strokeWidth;

  @override
  double get defaultSize => 15;

  @override
  List<MarkElement> drawGroupPrimitives(List<Attributes> group, CoordConv coord, Offset origin) {
    assert(coord is RectCoordConv);
    assert(!coord.transposed);

    final primitives = <MarkElement>[];

    for (var item in group) {
      // print('${item.tag} - ${item.index}- ${item.position}');
      assert(item.shape is ViolinShape);

      final style = getPaintStyle(item, hollow, strokeWidth, null, null);

      // Candle stick shape dosen't allow NaN value.
      /// q1, mean, q3, min, max
      final points = item.position.map((p) => coord.convert(p)).toList();
      final x = points.first.dx;
      final ys = points.map((p) => p.dy).toList();
      final bias = (item.size ?? defaultSize) / 5 / 2;
      final width = (item.size ?? defaultSize) / 2;

      final top = ys[3];
      final topEdge = ys[0];
      final mean = ys[1];
      final bottomEdge = ys[2];
      final bottom = ys[4];

      if (hollow) {
        primitives.add(PathElement(segments: [
          MoveSegment(end: Offset(x, top)),
          LineSegment(end: Offset(x, topEdge)),
          MoveSegment(end: Offset(x - bias, topEdge)),
          LineSegment(end: Offset(x + bias, topEdge)),
          LineSegment(end: Offset(x + bias, bottomEdge)),
          LineSegment(end: Offset(x - bias, bottomEdge)),
          CloseSegment(),
          MoveSegment(end: Offset(x, bottomEdge)),
          LineSegment(end: Offset(x, bottom)),
          MoveSegment(end: Offset(x - bias, mean)),
          LineSegment(end: Offset(x + bias, mean)),
        ], style: style, tag: item.tag));
      } else {
        // If the stoke style is fill, the lines created by Path.lineTo will not
        // be rendered.
        final strokeBias = strokeWidth / 2;
        primitives.add(PathElement(segments: [
          MoveSegment(end: Offset(x + strokeBias, top)),
          LineSegment(end: Offset(x + strokeBias, topEdge)),
          LineSegment(end: Offset(x + bias, topEdge)),
          LineSegment(end: Offset(x + bias, bottomEdge)),
          LineSegment(end: Offset(x + strokeBias, bottomEdge)),
          LineSegment(end: Offset(x + strokeBias, bottom)),
          LineSegment(end: Offset(x - strokeBias, bottom)),
          LineSegment(end: Offset(x - strokeBias, bottomEdge)),
          LineSegment(end: Offset(x - bias, bottomEdge)),
          LineSegment(end: Offset(x - bias, topEdge)),
          LineSegment(end: Offset(x - strokeBias, topEdge)),
          LineSegment(end: Offset(x - strokeBias, top)),
          CloseSegment(),
          MoveSegment(end: Offset(x - bias, mean)),
          LineSegment(end: Offset(x + bias, mean)),
        ], style: style, tag: item.tag));
      }

      final _pathPoints = item.tag == null ? pathPoints.values.toList()[item.index] : pathPoints[item.tag];
      final minX = _pathPoints!.map((e) => e.dx).min()!;
      final maxX = _pathPoints.map((e) => e.dx).max()!;
      final deltaX = maxX - minX;

      final minY = _pathPoints.map((e) => e.dy).min()!;
      final maxY = _pathPoints.map((e) => e.dy).max()!;
      final deltaY = maxY - minY;
      // print(deltaY);

      final _points = _pathPoints.map((e) {}).toList();

      List<Offset> _right = [], _left = [];
      for (Offset p in _pathPoints) {
        var _f = Offset(p.dx, (p.dy) / max);
        var f = coord.convert(_f);
        // print('${_f.dy} - ${f.dy}');
        var ro = Offset(x + width * (p.dx - minX) / deltaX, f.dy);
        var lo = Offset(x - width * (p.dx - minX) / deltaX, f.dy);

        if (_right.length > 0 && (ro.dx - _right.last.dx).abs() < .5) continue;

        _right.add(ro);
        _left.add(lo);
      }

      var violinStyle = PaintStyle(
        fillColor: item.color!.withOpacity(.25),
        elevation: item.elevation,
        // gradientBounds: gradientBounds,
        // dash: dash,
      );
      primitives.add(PolygonElement(points: [..._left, ..._right.reversed], style: violinStyle, tag: item.tag));
      primitives.add(PolylineElement(points: [..._left, ..._right.reversed], style: style, tag: item.tag));
      // primitives.add(PolylineElement(points: _right, style: style, tag: item.tag));
      // primitives.add(PolygonElement(points: _points, style: style));
      // No labels.
    }

    return primitives;
  }

  @override
  List<MarkElement> drawGroupLabels(List<Attributes> group, CoordConv coord, Offset origin) => [];

  @override
  Offset representPoint(List<Offset> position) => position[1];
}
