import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/chart/graphic/element/seq_path.dart';
import 'package:graphic/graphic.dart';
import 'package:path_drawing/path_drawing.dart';

class MotifLogoElement extends PrimitiveElement {
  String seq;

  TextPainter? _painter;
  Rect rect;

  MotifLogoElement({required this.rect, required super.style, required this.seq}) {}

  @override
  void drawPath(Path path) {
    path.addPath(_transformSeqPath(), rect.topLeft);
  }

  Path _transformSeqPath() {
    Path path = parseSvgPathData(seqPathMap[seq.toUpperCase()]!);
    final ab = path.getBounds();
    // print('$seq ${ab}');
    final scaleX = rect.width / ab.width, scaleY = rect.height / ab.height;
    // print('scale x ${scaleX}, scale y: ${scaleY}');
    var m = Matrix4.identity()
      ..translate(-ab.left * scaleX, -ab.top * scaleY) //先平移，再缩放，顺序不能变
      ..scale(scaleX, scaleY);
    return path.transform(m.storage);
  }

  @override
  void draw(Canvas canvas) {
    super.draw(canvas);
  }

  @override
  PrimitiveElement lerpFrom(covariant PrimitiveElement from, double t) {
    throw UnimplementedError();
  }

  @override
  List<Segment> toSegments() {
    throw UnimplementedError();
  }
}