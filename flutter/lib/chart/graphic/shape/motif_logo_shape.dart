import 'dart:ui';

import 'package:flutter_smart_genome/chart/graphic/element/motif_logo_element.dart';
import 'package:graphic/graphic.dart';
import 'package:graphic/src/graffiti/element/element.dart';

class MotifLogoShape extends RectShape {
  bool showBackground = false;

  MotifLogoShape({this.showBackground = false}) {}

  @override
  double get defaultSize => 15;

  @override
  List<MarkElement<ElementStyle>> drawGroupLabels(List<Attributes> group, CoordConv coord, Offset origin) => [];

  @override
  List<MarkElement<ElementStyle>> drawGroupPrimitives(List<Attributes> group, CoordConv coord, Offset origin) {
    assert(coord is RectCoordConv);
    assert(!coord.transposed);

    final rst = <MarkElement>[];

    for (var item in group) {
      // print('${item.index}, ${item.color}, ${item.label}, ${item.tag}, ${item.position}');
      bool nan = false;
      for (var point in item.position) {
        if (!point.dy.isFinite) {
          nan = true;
          break;
        }
      }
      if (nan) {
        continue;
      }
      final start = coord.convert(item.position[0]);
      final end = coord.convert(item.position[1]);
      final size = item.size ?? defaultSize;
      Rect rect;
      if (coord.transposed) {
        rect = Rect.fromLTRB(
          start.dx,
          start.dy - size / 2,
          end.dx,
          start.dy + size / 2,
        );
      } else {
        rect = Rect.fromLTRB(
          end.dx - size / 2,
          end.dy,
          end.dx + size / 2,
          start.dy,
        );
      }

      // final style = getPaintStyle(item, true, 0, coord.region, null);
      // print('${item.tag}, ${item.label}');

      if (showBackground) {
        final backgroundStyle = PaintStyle(
          fillColor: item.color?.withOpacity(.1),
          elevation: item.elevation,
        );
        var background = RectElement(rect: rect, borderRadius: (item.shape as RectShape).borderRadius, style: backgroundStyle, tag: item.tag);
        rst.add(background);
      }
      if (item.tag != null) {
        final styleFill = getPaintStyle(item, false, 0, coord.region, null);
        var logo = MotifLogoElement(rect: rect, style: styleFill, seq: item.tag!);
        rst.add(logo);
      }
    }

    return rst;
    // return super.drawGroupPrimitives(group, coord, origin);
  }

  @override
  bool equalTo(Object other) {
    return other is MotifLogoShape && runtimeType == other.runtimeType;
  }
}
