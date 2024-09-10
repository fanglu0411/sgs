import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/relation/relation_base.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';
import 'dart:math' as math;

class EmptyRelationPainter extends CustomPainter {
  List<RelationPairPosition>? relations;
  late Paint _paint;
  EmptyRelationPainter() {
    // _initRelations();
    _paint = Paint();
  }

  _initRelations(Size size) {
    var random = math.Random();
    relations = List.generate(6, (index) {
      var start1 = size.width * random.nextDouble();
      var start2 = size.width * random.nextDouble();
      return RelationPairPosition(
        range1: Range(start: start1, end: start1 + random.nextDouble().clamp(.2, .6) * size.width * .5),
        range2: Range(start: start2, end: start2 + random.nextDouble().clamp(.2, .6) * size.width * .5),
        value: random.nextDouble().clamp(.1, .6),
      );
    });
  }

  Size? _size;
  double _chrHeight = 20;

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;
    if (null == relations) {
      _initRelations(size);
    }

    Rect chr1 = Rect.fromLTWH(0, 0, size.width, _chrHeight);
    Rect chr2 = Rect.fromLTWH(0, size.height - 20, size.width, _chrHeight);
    canvas.drawRect(chr1, _paint..color = Colors.grey[400]!);
    canvas.drawRect(chr2, _paint..color = Colors.blueGrey[200]!);

    relations!.forEach((r) => _drawRelation(canvas, r));
  }

  void _drawRelation(Canvas canvas, RelationPairPosition relation) {
    Rect chrRect1 = Rect.fromLTRB(relation.range1.start, 0, relation.range1.end, _chrHeight);
    Rect chrRect2 = Rect.fromLTWH(relation.range2.start, _size!.height - _chrHeight, relation.range2.size, _chrHeight);
    Path path = Path()
      ..moveTo(relation.range1.start, _chrHeight)
      ..lineTo(relation.range2.start, _size!.height - _chrHeight)
      ..lineTo(relation.range2.end, _size!.height - _chrHeight)
      ..lineTo(relation.range1.end, _chrHeight)
      ..close();
    _paint.color = Colors.grey.withOpacity(relation.value);

    canvas.drawRect(chrRect1, _paint);
    canvas.drawRect(chrRect2, _paint);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}